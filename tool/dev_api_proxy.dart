import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

const _defaultPort = 8080;
const _defaultTarget = 'https://api.genmindz.in';
const _corsMethods = 'GET,POST,PUT,PATCH,DELETE,OPTIONS';
const _corsHeaders = 'Content-Type,Accept,Authorization';

Future<void> main(List<String> args) async {
  final config = _parseArgs(args);

  if (config.showHelp) {
    stdout.writeln(_usage);
    return;
  }

  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, config.port);
  stdout.writeln(
    'GenMindz API proxy listening on http://localhost:${server.port}',
  );
  stdout.writeln('Forwarding requests to ${config.target}');
  stdout.writeln('Press Ctrl+C to stop.');

  await for (final request in server) {
    unawaited(_handleRequest(request, config.target));
  }
}

Future<void> _handleRequest(HttpRequest request, Uri targetBase) async {
  if (request.method == 'OPTIONS') {
    _applyCorsHeaders(request.response);
    request.response.statusCode = HttpStatus.noContent;
    await request.response.close();
    return;
  }

  if (request.uri.path == '/health' || request.uri.path == '/__proxy/health') {
    _applyCorsHeaders(request.response);
    request.response.headers.contentType = ContentType.json;
    request.response.write(
      jsonEncode({
        'ok': true,
        'proxy': 'GenMindz local API proxy',
        'target': targetBase.toString(),
      }),
    );
    await request.response.close();
    return;
  }

  final client = HttpClient()..autoUncompress = false;

  try {
    final upstreamRequest = await client.openUrl(
      request.method,
      targetBase.resolveUri(request.uri),
    );

    _copyRequestHeaders(request.headers, upstreamRequest.headers);

    final bodyBytes = await _readBody(request);
    if (bodyBytes.isNotEmpty) {
      upstreamRequest.contentLength = bodyBytes.length;
      upstreamRequest.add(bodyBytes);
    }

    final upstreamResponse = await upstreamRequest.close();

    request.response.statusCode = upstreamResponse.statusCode;
    _copyResponseHeaders(upstreamResponse.headers, request.response.headers);
    _applyCorsHeaders(request.response);
    await request.response.addStream(upstreamResponse);
  } catch (error) {
    _applyCorsHeaders(request.response);
    request.response.statusCode = HttpStatus.badGateway;
    request.response.headers.contentType = ContentType.json;
    request.response.write(
      jsonEncode({
        'message': 'Proxy request failed.',
        'error': error.toString(),
      }),
    );
  } finally {
    await request.response.close();
    client.close(force: true);
  }
}

void _copyRequestHeaders(HttpHeaders source, HttpHeaders target) {
  const allowedHeaders = {
    HttpHeaders.acceptHeader,
    HttpHeaders.authorizationHeader,
    HttpHeaders.contentTypeHeader,
  };

  source.forEach((name, values) {
    if (!allowedHeaders.contains(name.toLowerCase())) {
      return;
    }

    for (final value in values) {
      target.add(name, value);
    }
  });
}

void _copyResponseHeaders(HttpHeaders source, HttpHeaders target) {
  const blockedHeaders = {
    HttpHeaders.connectionHeader,
    HttpHeaders.contentLengthHeader,
    'transfer-encoding',
    HttpHeaders.accessControlAllowOriginHeader,
    HttpHeaders.accessControlAllowMethodsHeader,
    HttpHeaders.accessControlAllowHeadersHeader,
  };

  source.forEach((name, values) {
    if (blockedHeaders.contains(name.toLowerCase())) {
      return;
    }

    for (final value in values) {
      target.add(name, value);
    }
  });
}

void _applyCorsHeaders(HttpResponse response) {
  response.headers
    ..set(HttpHeaders.accessControlAllowOriginHeader, '*')
    ..set(HttpHeaders.accessControlAllowMethodsHeader, _corsMethods)
    ..set(HttpHeaders.accessControlAllowHeadersHeader, _corsHeaders);
}

Future<List<int>> _readBody(HttpRequest request) async {
  final builder = BytesBuilder(copy: false);
  await for (final chunk in request) {
    builder.add(chunk);
  }
  return builder.takeBytes();
}

_ProxyConfig _parseArgs(List<String> args) {
  var port = _defaultPort;
  var target = _defaultTarget;
  var showHelp = false;

  for (var index = 0; index < args.length; index++) {
    final arg = args[index];

    switch (arg) {
      case '--help':
      case '-h':
        showHelp = true;
        break;
      case '--port':
        if (index + 1 >= args.length) {
          throw ArgumentError('Missing value for --port');
        }
        port = int.parse(args[++index]);
        break;
      case '--target':
        if (index + 1 >= args.length) {
          throw ArgumentError('Missing value for --target');
        }
        target = args[++index];
        break;
      default:
        throw ArgumentError('Unsupported argument: $arg');
    }
  }

  return _ProxyConfig(
    port: port,
    target: _normalizeBaseUri(target),
    showHelp: showHelp,
  );
}

Uri _normalizeBaseUri(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) {
    throw ArgumentError('Target URL cannot be empty.');
  }

  final uri = Uri.parse(trimmed);
  if (!uri.hasScheme || uri.host.isEmpty) {
    throw ArgumentError('Target URL must include a scheme and host.');
  }

  return uri.path.endsWith('/')
      ? uri.replace(path: uri.path.substring(0, uri.path.length - 1))
      : uri;
}

class _ProxyConfig {
  const _ProxyConfig({
    required this.port,
    required this.target,
    required this.showHelp,
  });

  final int port;
  final Uri target;
  final bool showHelp;
}

const _usage = '''
Usage:
  dart run tool/dev_api_proxy.dart [--port 8080] [--target https://api.genmindz.in]

Examples:
  dart run tool/dev_api_proxy.dart
  dart run tool/dev_api_proxy.dart --port 9090 --target https://api.genmindz.in
''';
