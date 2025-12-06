/// Centralized application configuration
/// 
/// This file contains all app-wide constants that should not change during runtime.
/// Avoid hardcoding values directly in widgets - use these constants instead.
class AppConfig {
  /// Private constructor - this is a utility class
  AppConfig._();

  // ==================== App Identity ====================
  static const String appName = 'MyRenesca';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.myrenesca.aquarium';

  // ==================== Theme Colors ====================
  /// Primary brand color - Teal
  static const int primaryColor = 0xFF00838F;
  
  /// Secondary accent color - Cyan
  static const int secondaryColor = 0xFF00BCD4;
  
  /// Success color - Green
  static const int successColor = 0xFF4CAF50;
  
  /// Error color - Red
  static const int errorColor = 0xFFF44336;
  
  /// Warning color - Orange
  static const int warningColor = 0xFFFFA726;
  
  /// Background light color
  static const int bgLightColor = 0xFFFAFAFA;

  // ==================== Typography ====================
  static const String fontFamily = 'Poppins';
  static const double fontSizeSmall = 12.0;
  static const double fontSizeNormal = 14.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeXLarge = 24.0;
  static const double fontSizeTitle = 28.0;

  // ==================== Padding & Margins ====================
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // ==================== Border Radius ====================
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;

  // ==================== App Timeouts ====================
  /// Default timeout for API requests (in seconds)
  static const int apiTimeoutSeconds = 30;
  
  /// Debounce duration for search inputs (in milliseconds)
  static const int searchDebounceMs = 500;
  
  /// Animation duration for transitions (in milliseconds)
  static const int animationDurationMs = 300;

  // ==================== API Configuration ====================
  /// Default page size for paginated queries
  static const int defaultPageSize = 20;
  
  /// Maximum file upload size in bytes (10 MB)
  static const int maxFileUploadBytes = 10 * 1024 * 1024;
  
  /// Supported image formats
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png', 'gif'];

  // ==================== User Roles ====================
  static const String roleAdmin = 'admin';
  static const String roleCustomer = 'customer';

  // ==================== Feature Flags ====================
  /// Enable debug logging throughout the app
  static const bool enableDebugLogging = true;
  
  /// Enable network request logging
  static const bool enableNetworkLogging = true;
  
  /// Enable security event logging
  static const bool enableSecurityLogging = true;

  // ==================== Supabase Tables ====================
  static const String tableUsers = 'users';
  static const String tableProducts = 'products';
  static const String tableOrders = 'orders';
  static const String tableOrderItems = 'order_items';
  static const String tableCategories = 'categories';
  static const String tableBrands = 'brands';
  static const String tableCart = 'cart';
  static const String tableBankAccounts = 'bank_accounts';

  // ==================== Storage Buckets ====================
  static const String bucketProductImages = 'product-images';
  static const String bucketUserAvatars = 'user-avatars';

  // ==================== Utility Methods ====================
  
  /// Get human-readable app version string
  static String getVersionString() => 'v$appVersion';
  
  /// Check if a string is a valid email format
  static bool isValidEmail(String email) {
    const emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    return RegExp(emailRegex).hasMatch(email);
  }
  
  /// Check if a string is a valid phone number format (Indonesian)
  static bool isValidPhoneNumber(String phone) {
    // Indonesian phone numbers: 08xx... or +628xx...
    const phoneRegex = r'^(\+62|0)[0-9]{9,12}$';
    return RegExp(phoneRegex).hasMatch(phone);
  }
  
  /// Check if a string is a valid password (minimum 8 characters)
  static bool isValidPassword(String password) {
    return password.length >= 8;
  }
  
  /// Format currency value to IDR (Indonesian Rupiah)
  static String formatCurrency(num value) {
    return 'Rp ${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match.group(1)},')}';
  }
}
