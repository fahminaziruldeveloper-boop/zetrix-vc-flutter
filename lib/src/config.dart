/// A utility class for accessing Zetrix SDK configuration values.
///
/// The `ConfigReader` provides static methods to retrieve environment-specific
/// configuration such as API base URLs and API tokens.
///
/// This class is **not meant to be instantiated.**
/// Instead, access its static methods directly:
///
/// ```dart
/// final baseUrl = ConfigReader.getBaseUrl(true);
/// final apiToken = ConfigReader.getApiToken(false);
/// ```
///
/// Typically used to configure services and HTTP clients in the Zetrix SDK.
class ConfigReader {

  /// Returns the base URL for the Zetrix API.
  static String getBaseUrl(bool isMainnet) {
    return isMainnet ? 'https://api.zetrix.com' : 'https://api-sandbox.zetrix.com';
  }

  /// Returns the fixed Bearer token for authenticating with the Zetrix BaaS API.
  static String getApiToken(bool isMainnet) {
    return isMainnet
        ? 'zetrix_39027bd1-9295-36a9-94af-93f56973e8b4' // Mainnet token
        : 'zetrix_39027bd1-9295-36a9-94af-93f56973e8b4';
  }

  /// Returns the fixed x-api-key header value for the Zetrix BaaS API.
  static String getXApiKey(bool isMainnet) {
    return isMainnet
        ? 'ehg7q2i6aN8jY6BbHqN5q42KsHQFRwl260jqAkAU' //Mainnet x-api-key
        : 'ehg7q2i6aN8jY6BbHqN5q42KsHQFRwl260jqAkAU';
  }

  /// Returns the URL for resolving did DOC from Zetrix Identity Resolver.
  static String getZidResolverUrl(){
    return 'https://zid-resolver.myegdev.com/1.0/identifiers';
  }

  ///Returns publicKey for VC encryption
  static String getRSAPublicKey(bool isMainnet) {
    return isMainnet
    ? '''-----BEGIN PUBLIC KEY-----
    MIIBITANBgkqhkiG9w0BAQEFAAOCAQ4AMIIBCQKCAQB+D4RCzMp1JrhmHV9sYeZg
    lpL2axB1bgwrDSiJSWLLSQqhkU8NMLpQROmTdv8uF9FWmc+LG6e7nXEaptU9C2NH
    DgQpt0D8uyUNCdlL+Sp6+FaSWt+JzBx/wN4TnZ5nYH7IUNmsueN68k210WzpLY/c
    +s7ckebnR4sk9ZM2WfpWEB44bpBldFKw1jKcz40Et2CHowIrzYTlCWViBVNRPwsf
    VWHsQEupuj7+zlpShnMBDq6RixyG6yxYwza0OzpwJd+YPWKKexiS2CWAwebjIGKc
    EmuOu2ln2IApiX0zPM80iyWI6hc5o/vbb6QBBuwpJL5CuSTFA7TjbG7nYvAWk2+D
    AgMBAAE=
    -----END PUBLIC KEY-----'''
    : '''-----BEGIN PUBLIC KEY-----
    MIIBITANBgkqhkiG9w0BAQEFAAOCAQ4AMIIBCQKCAQB+D4RCzMp1JrhmHV9sYeZg
    lpL2axB1bgwrDSiJSWLLSQqhkU8NMLpQROmTdv8uF9FWmc+LG6e7nXEaptU9C2NH
    DgQpt0D8uyUNCdlL+Sp6+FaSWt+JzBx/wN4TnZ5nYH7IUNmsueN68k210WzpLY/c
    +s7ckebnR4sk9ZM2WfpWEB44bpBldFKw1jKcz40Et2CHowIrzYTlCWViBVNRPwsf
    VWHsQEupuj7+zlpShnMBDq6RixyG6yxYwza0OzpwJd+YPWKKexiS2CWAwebjIGKc
    EmuOu2ln2IApiX0zPM80iyWI6hc5o/vbb6QBBuwpJL5CuSTFA7TjbG7nYvAWk2+D
    AgMBAAE=
    -----END PUBLIC KEY-----''';
  }
}
