class RecaptchaService {
  static const String initialToken = String.fromEnvironment(
    'RECAPTCHA_TEST_TOKEN',
    defaultValue: '',
  );

  static String _token = initialToken;

  static Future<void> init() async {
    _token = initialToken.trim();
  }

  static Future<String> getToken() async {
    return _token.trim();
  }

  static void setToken(String token) {
    _token = token.trim();
  }
}
