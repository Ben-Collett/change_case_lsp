class ErrorResponse {
  final int code;
  final String message;
  final dynamic data;

  const ErrorResponse({required this.code, required this.message, this.data});
  Map<String, dynamic> toJson() {
    return {"code": code, "message": message, if (data != null) "data": data};
  }
}
