class AuthCodeRequestResult {
  const AuthCodeRequestResult({
    required this.message,
    this.debugCode,
    this.mailDelivery,
  });

  final String message;
  final String? debugCode;
  final String? mailDelivery;
}
