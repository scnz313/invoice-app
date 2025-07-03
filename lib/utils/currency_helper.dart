import 'package:intl/intl.dart';

class CurrencyHelper {
  static const String _currencySymbol = '₹';
  static const String _pdfCurrencySymbol = 'Rs.'; // PDF-safe rupee symbol
  static const String _currencyCode = 'INR';
  static const String _locale = 'en_IN';
  
  /// Format amount with Indian Rupee symbol
  static String formatAmount(double amount, {bool showSymbol = true, int decimalPlaces = 0}) {
    final formatter = NumberFormat.currency(
      locale: _locale,
      symbol: showSymbol ? _currencySymbol : '',
      decimalDigits: decimalPlaces,
    );
    return formatter.format(amount);
  }
  
  /// Format amount for PDF with safe rupee symbol
  static String formatAmountForPdf(double amount, {bool showSymbol = true, int decimalPlaces = 2}) {
    if (!showSymbol) {
      return NumberFormat('#,##,##0.${'0' * decimalPlaces}', 'en_IN').format(amount);
    }
    final formattedNumber = NumberFormat('#,##,##0.${'0' * decimalPlaces}', 'en_IN').format(amount);
    return '$_pdfCurrencySymbol$formattedNumber';
  }
  
  /// Format amount with compact notation (1K, 1L, etc.)
  static String formatCompactAmount(double amount, {bool showSymbol = true}) {
    if (amount >= 10000000) { // 1 Crore
      return '${showSymbol ? _currencySymbol : ''}${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) { // 1 Lakh
      return '${showSymbol ? _currencySymbol : ''}${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) { // 1 Thousand
      return '${showSymbol ? _currencySymbol : ''}${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return formatAmount(amount, showSymbol: showSymbol);
    }
  }
  
  /// Format amount for display in invoices (with 2 decimal places)
  static String formatInvoiceAmount(double amount) {
    return formatAmount(amount, decimalPlaces: 2);
  }
  
  /// Get currency symbol only
  static String get currencySymbol => _currencySymbol;
  
  /// Get PDF-safe currency symbol
  static String get pdfCurrencySymbol => _pdfCurrencySymbol;
  
  /// Get currency code
  static String get currencyCode => _currencyCode;
  
  /// Parse amount from string (removes currency symbols)
  static double parseAmount(String amountString) {
    // Remove currency symbols and spaces
    final cleanString = amountString
        .replaceAll(_currencySymbol, '')
        .replaceAll(_pdfCurrencySymbol, '')
        .replaceAll('Rs.', '')
        .replaceAll('Rs', '')
        .replaceAll(',', '')
        .trim();
    
    return double.tryParse(cleanString) ?? 0.0;
  }
  
  /// Format amount for input fields (no symbol, with decimal places)
  static String formatForInput(double amount) {
    return amount.toStringAsFixed(2);
  }
  
  /// Indian number formatting with commas
  static String formatIndianNumber(double number) {
    final formatter = NumberFormat('#,##,###', 'en_IN');
    return formatter.format(number);
  }
} 