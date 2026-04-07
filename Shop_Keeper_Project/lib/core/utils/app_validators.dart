/// Input validators for forms
class AppValidators {
  /// Product name must not be empty
  static String? productName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Product name is required';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  /// Positive number required
  static String? positiveNumber(String? value, {String field = 'Value'}) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    final num = double.tryParse(value);
    if (num == null) return 'Enter a valid number';
    if (num < 0) return '$field must be positive';
    return null;
  }

  /// Price must be > 0
  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) return 'Price is required';
    final num = double.tryParse(value);
    if (num == null) return 'Enter a valid price';
    if (num <= 0) return 'Price must be greater than 0';
    return null;
  }

  /// Stock quantity (integer ≥ 0)
  static String? stockQuantity(String? value) {
    if (value == null || value.trim().isEmpty) return 'Quantity is required';
    final num = int.tryParse(value);
    if (num == null) return 'Enter a whole number';
    if (num < 0) return 'Quantity cannot be negative';
    return null;
  }

  /// Phone number (10 digits for India)
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
    final clean = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length < 10) return 'Enter a valid 10-digit number';
    return null;
  }

  /// Customer name
  static String? customerName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Customer name is required';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  /// Amount (for credit/payment)
  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) return 'Amount is required';
    final num = double.tryParse(value);
    if (num == null) return 'Enter a valid amount';
    if (num <= 0) return 'Amount must be greater than 0';
    return null;
  }

  /// Optional email
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Optional
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }
}
