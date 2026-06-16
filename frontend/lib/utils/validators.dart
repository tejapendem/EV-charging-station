class Validators {
  Validators._();

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final email = value.trim();
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (value.length > 128) {
      return 'Password must not exceed 128 characters';
    }

    final hasUppercase = value.contains(RegExp(r'[A-Z]'));
    final hasLowercase = value.contains(RegExp(r'[a-z]'));
    final hasDigit = value.contains(RegExp(r'[0-9]'));
    final hasSpecial = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (!hasUppercase) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!hasLowercase) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!hasDigit) {
      return 'Password must contain at least one digit';
    }
    if (!hasSpecial) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final phone = value.trim().replaceAll(RegExp(r'[\s\-]'), '');

    if (phone.startsWith('+91')) {
      if (phone.length != 13) {
        return 'Please enter a valid 10-digit Indian phone number';
      }
    } else if (phone.length != 10) {
      return 'Please enter a valid 10-digit phone number';
    }

    if (!RegExp(r'^\+?[0-9]{10,13}$').hasMatch(phone)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  static String? validateOtp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'OTP is required';
    }

    final otp = value.trim();

    if (otp.length != 6) {
      return 'OTP must be 6 digits';
    }

    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      return 'OTP must contain only digits';
    }

    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }

    final name = value.trim();

    if (name.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (name.length > 50) {
      return 'Name must not exceed 50 characters';
    }

    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
      return 'Name should contain only letters and spaces';
    }

    return null;
  }

  static String? validateRequired(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateStationName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Station name is required';
    }

    final name = value.trim();

    if (name.length < 3) {
      return 'Station name must be at least 3 characters';
    }

    if (name.length > 100) {
      return 'Station name must not exceed 100 characters';
    }

    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required';
    }

    final address = value.trim();

    if (address.length < 10) {
      return 'Please enter a complete address';
    }

    if (address.length > 500) {
      return 'Address must not exceed 500 characters';
    }

    return null;
  }

  static String? validatePincode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Pincode is required';
    }

    final pincode = value.trim();

    if (!RegExp(r'^\d{6}$').hasMatch(pincode)) {
      return 'Please enter a valid 6-digit pincode';
    }

    return null;
  }

  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // URL is optional
    }

    final url = value.trim();
    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\w\-])+\.{1}([a-zA-Z]{2,63})([\/\w\-\.~]*)*\/?$',
    );

    if (!urlRegex.hasMatch(url)) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  static String? validateRating(int? value) {
    if (value == null) {
      return 'Please select a rating';
    }

    if (value < 1 || value > 5) {
      return 'Rating must be between 1 and 5';
    }

    return null;
  }

  static String? validateReview(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please write a review';
    }

    final review = value.trim();

    if (review.length < 10) {
      return 'Review must be at least 10 characters';
    }

    if (review.length > 1000) {
      return 'Review must not exceed 1000 characters';
    }

    return null;
  }

  static String? validateVehicleNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Vehicle number is optional
    }

    final number = value.trim().toUpperCase();
    // Indian vehicle number format: XX 00 XX 0000
    final vehicleRegex = RegExp(
      r'^[A-Z]{2}\s?\d{1,2}\s?[A-Z]{1,2}\s?\d{1,4}$',
    );

    if (!vehicleRegex.hasMatch(number)) {
      return 'Please enter a valid vehicle number (e.g., KA 01 AB 1234)';
    }

    return null;
  }

  static String? validatePositiveNumber(String? value, [String fieldName = 'Value']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    final number = double.tryParse(value.trim());
    if (number == null) {
      return 'Please enter a valid number';
    }

    if (number <= 0) {
      return 'Please enter a positive number';
    }

    return null;
  }

  static String? validatePercentage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final percentage = double.tryParse(value.trim());
    if (percentage == null) {
      return 'Please enter a valid percentage';
    }

    if (percentage < 0 || percentage > 100) {
      return 'Percentage must be between 0 and 100';
    }

    return null;
  }

  static String? validateSearchQuery(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Search can be empty
    }

    if (value.trim().length > 100) {
      return 'Search query too long';
    }

    return null;
  }
}
