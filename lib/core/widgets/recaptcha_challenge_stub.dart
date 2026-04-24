import 'package:flutter/material.dart';

class RecaptchaChallenge extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CAPTCHA TOKEN',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF7F8AA3),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF4f46e5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasError ? Colors.red : const Color(0xFF4f46e5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4f46e5).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            minLines: 3,
            maxLines: 5,
            style: const TextStyle(color: Color(0xFFA7B0C0)),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF0f172a),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 48),
                child: Icon(
                  Icons.verified_user_outlined,
                  color: Color(0xFF7F8AA3),
                ),
              ),
              hintText: 'Paste the reCAPTCHA token returned by your web flow',
              hintStyle: const TextStyle(color: Color(0xFF6B7280)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
            validator: (value) {
              if (value?.trim().isEmpty ?? true) {
                return 'Captcha token is required';
              }
              return null;
            },
            onChanged: onTokenChanged,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Use the token from your reCAPTCHA flow. These tokens expire quickly.',
          style: TextStyle(color: Color(0xFF7F8AA3), fontSize: 12),
        ),
        if (hasError)
          const Padding(
            padding: EdgeInsets.only(top: 6, left: 4),
            child: Text(
              'Please provide a valid captcha token',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
