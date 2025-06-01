class QrValidationService {
  static Future<String?> validateQrCode(String qrCode) async {
    try {
      // Clean and validate QR code value
      final cleanQrCode = qrCode.trim();
      if (cleanQrCode.isEmpty) return null;

      // Try to parse as integer if possible
      int? bookId;
      try {
        bookId = int.parse(cleanQrCode);
        return cleanQrCode; // Return the QR code value if it's a valid integer
      } catch (e) {
        print('QR code is not a valid integer: $cleanQrCode');
        return null;
      }
    } catch (e) {
      print('Error validating QR code: $e');
      return null;
    }
  }
}
