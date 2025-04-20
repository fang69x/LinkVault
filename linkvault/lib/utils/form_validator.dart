class FormValidators {
  // Email validator
  static String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    // Fixed email regex pattern
    final emailRegex = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$");

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // Password validator
  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Name validator
  static String? nameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  // URL validator
  static String? urlValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL is required';
    }
    // URL regex pattern
    final urlRegex =
        RegExp(r'^(https?:\/\/)?([\da-z.-]+)\.([a-z.]{2,6})([\/\w .-]*)*\/?$');
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  // Title validator
  static String? titleValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Title is required';
    }
    if (value.length > 100) {
      return 'Title must be less than 100 characters';
    }
    return null;
  }

  // Note validator (optional field)
  static String? noteValidator(String? value) {
    if (value != null && value.length > 500) {
      return 'Note must be less than 500 characters';
    }
    return null;
  }

  // Category validator
  static String? categoryValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Category is required';
    }
    return null;
  }
}
