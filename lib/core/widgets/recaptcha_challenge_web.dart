// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

import '../services/recaptcha_service.dart';

class RecaptchaChallenge extends StatefulWidget {
  const RecaptchaChallenge({
    super.key,
    required this.controller,
    required this.hasError,
    required this.onTokenChanged,
  });

  final TextEditingController controller;
  final bool hasError;
  final ValueChanged<String> onTokenChanged;

  @override
  State<RecaptchaChallenge> createState() => _RecaptchaChallengeState();
}

class _RecaptchaChallengeState extends State<RecaptchaChallenge> {
  static int _nextId = 0;

  late final String _viewType = 'genmindz-recaptcha-${_nextId++}';
  late final String _containerId = '$_viewType-container';
  late final String _tokenCallbackName = '$_viewType-token';
  late final String _expiredCallbackName = '$_viewType-expired';
  late final String _errorCallbackName = '$_viewType-error';
  Timer? _renderTimer;
  bool _isRendered = false;

  @override
  void initState() {
    super.initState();
    _registerViewFactory();
    _registerCallbacks();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startRenderLoop());
  }

  void _registerViewFactory() {
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int _) {
      final container = html.DivElement()
        ..id = _containerId
        ..style.width = '100%'
        ..style.minHeight = '78px';
      return container;
    });
  }

  void _registerCallbacks() {
    js.context[_tokenCallbackName] = (String token) {
      widget.controller.text = token;
      widget.onTokenChanged(token);
    };
    js.context[_expiredCallbackName] = () {
      widget.controller.clear();
      widget.onTokenChanged('');
    };
    js.context[_errorCallbackName] = () {
      widget.controller.clear();
      widget.onTokenChanged('');
      if (mounted) {
        setState(() => _isRendered = false);
        _startRenderLoop();
      }
    };
  }

  void _startRenderLoop() {
    _renderTimer?.cancel();
    if (_tryRender()) {
      return;
    }

    _renderTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      if (_tryRender()) {
        timer.cancel();
      }
    });
  }

  bool _tryRender() {
    if (!mounted || !RecaptchaService.isConfigured) {
      return false;
    }

    if (!js.context.hasProperty('__genmindzRecaptcha')) {
      return false;
    }

    final api = js.context['__genmindzRecaptcha'];
    if (api is! js.JsObject) {
      return false;
    }

    try {
      final widgetId = api.callMethod('render', [
        _containerId,
        RecaptchaService.siteKeyValue,
        _tokenCallbackName,
        _expiredCallbackName,
        _errorCallbackName,
      ]);
      final rendered = widgetId != null;
      if (rendered != _isRendered && mounted) {
        setState(() => _isRendered = rendered);
      } else {
        _isRendered = rendered;
      }
      return rendered;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _renderTimer?.cancel();
    if (js.context.hasProperty('__genmindzRecaptcha')) {
      final api = js.context['__genmindzRecaptcha'];
      if (api is js.JsObject) {
        try {
          api.callMethod('reset', [_containerId]);
        } catch (_) {}
      }
    }
    js.context[_tokenCallbackName] = null;
    js.context[_expiredCallbackName] = null;
    js.context[_errorCallbackName] = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.hasError ? Colors.red : const Color(0xFF4f46e5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CAPTCHA',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF7F8AA3),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF4f46e5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4f46e5).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(1),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF0f172a),
              borderRadius: BorderRadius.circular(13),
            ),
            child: RecaptchaService.isConfigured
                ? SizedBox(
                    height: 78,
                    child: HtmlElementView(
                      key: ValueKey(_viewType),
                      viewType: _viewType,
                    ),
                  )
                : const Text(
                    'reCAPTCHA site key is not configured.',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isRendered
              ? 'Complete the reCAPTCHA challenge to continue.'
              : 'Loading reCAPTCHA widget...',
          style: const TextStyle(color: Color(0xFF7F8AA3), fontSize: 12),
        ),
        if (widget.hasError)
          const Padding(
            padding: EdgeInsets.only(top: 6, left: 4),
            child: Text(
              'Please complete the captcha challenge',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
