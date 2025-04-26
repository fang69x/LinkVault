class ApiConstants {
  static const String baseUrl = 'http://localhost:3000'; // For Android emulator
//'http://10.0.2.2:3000'; // For Android emulator
  // API endpoints
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String bookmarks = '/api/bookmarks';
  static const String searchBookmarks = '/api/bookmarks/search';
}

class AppConstants {
  // Default categories for bookmarks
  static const List<String> defaultCategories = [
    'Work',
    'Personal',
    'Education',
    'Entertainment',
    'Shopping',
    'Social Media',
    'Other'
  ];

  // Validation constants
  static const int titleMaxLength = 100;
  static const int noteMaxLength = 500;
}
