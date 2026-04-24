import 'dart:io';

const _defaultPort = 62225;

Future<void> main(List<String> args) async {
  final port = _parsePort(args);
  final root = Directory('build/web');

  if (!root.existsSync()) {
    stderr.writeln('Missing build/web. Run "flutter build web" first.');
    exitCode = 1;
    return;
  }

  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  stdout.writeln('Serving build/web on http://localhost:$port');

  await for (final request in server) {
    await _handleRequest(request, root);
  }
}

int _parsePort(List<String> args) {
  for (var index = 0; index < args.length; index++) {
    if (args[index] == '--port' && index + 1 < args.length) {
      return int.parse(args[index + 1]);
    }
  }
  return _defaultPort;
}

Future<void> _handleRequest(HttpRequest request, Directory root) async {
  final relativePath = request.uri.path == '/' ? '/index.html' : request.uri.path;
  final candidate = File('${root.path}${relativePath.replaceAll('/', Platform.pathSeparator)}');
  final file = await _resolveFile(candidate, root);

  if (file == null) {
    request.response.statusCode = HttpStatus.notFound;
    await request.response.close();
    return;
  }

  final contentType = _contentTypeFor(file.path);
  if (contentType != null) {
    request.response.headers.contentType = contentType;
  }

  await request.response.addStream(file.openRead());
  await request.response.close();
}

Future<File?> _resolveFile(File candidate, Directory root) async {
  if (await candidate.exists()) {
    return candidate;
  }

  final fallback = File('${root.path}${Platform.pathSeparator}index.html');
  if (await fallback.exists()) {
    return fallback;
  }

  return null;
}

ContentType? _contentTypeFor(String path) {
  final lower = path.toLowerCase();

  if (lower.endsWith('.html')) return ContentType.html;
  if (lower.endsWith('.css')) return ContentType('text', 'css', charset: 'utf-8');
  if (lower.endsWith('.js')) return ContentType('text', 'javascript', charset: 'utf-8');
  if (lower.endsWith('.json')) return ContentType.json;
  if (lower.endsWith('.png')) return ContentType('image', 'png');
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return ContentType('image', 'jpeg');
  if (lower.endsWith('.svg')) return ContentType('image', 'svg+xml');
  if (lower.endsWith('.ico')) return ContentType('image', 'x-icon');
  if (lower.endsWith('.wasm')) {
    return ContentType('application', 'wasm');
  }

  return null;
}
