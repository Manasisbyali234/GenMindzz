class RecaptchaService {
  static const String siteKey = String.fromEnvironment(
    'RECAPTCHA_SITE_KEY',
    defaultValue: '6LdsZ40sAAAAAMkUqj1TvN0EHTzswGzvjnSTrcqQ',
  );
  static const String initialToken = String.fromEnvironment(
    'RECAPTCHA_TEST_TOKEN',
    defaultValue: '',
  );

  static String _token = initialToken;

  static String get siteKeyValue => siteKey.trim();
  static bool get isConfigured => siteKeyValue.isNotEmpty;

  static Future<void> init() async {
    _token = initialToken.trim();
  }

  static Future<String> getToken() async {
    return _token.trim();
  }

  static void setToken(String token) {
    _token = token.trim();
  }

  static void clearToken() {
    _token = '';
  }
}
