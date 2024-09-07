class RpcException implements Exception {
  final String message;
  RpcException(this.message);

  @override
  String toString() => 'Transaction failed: $message';
}

class GeneralException implements Exception {
  final String message;
  GeneralException(this.message);

  @override
  String toString() => 'GeneralException: $message';
}
