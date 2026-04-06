class ServerException implements Exception {
  final String message;
  final int statusCode;

  const ServerException({required this.message, required this.statusCode});

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({this.message = 'Tidak ada koneksi internet.'});

  @override
  String toString() => message;
}
