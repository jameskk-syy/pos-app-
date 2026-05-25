class AppConstants {
  AppConstants._();
 
  //Base URLs 
  static const String saasApiBaseUrl =
      'https://api.saas.techsavanna.technology';
 
  static const String signUpBaseUrl =
      'http://savannapaypos.saas.techsavanna.technology';
 
  // WebView URLs
  static const String signUpUrl = '$signUpBaseUrl/signup';
 
  // API Endpoints
  static String tenantStatus(String tenantId) =>
      '$saasApiBaseUrl/api/v1/tenants/$tenantId/status';
 
  static String tenantBySubdomain(String slug) =>
      '$saasApiBaseUrl/api/v1/tenants/by-subdomain/$slug';
 
  // URL Path Segments 
  static const String loginPath     = '/login';
  static const String dashboardPath = '/dashboard';
  static const String successPath   = '/success';
 
  //Domain Patterns
  static const String posSaasDomain = '.pos.saas.techsavanna.technology';
}