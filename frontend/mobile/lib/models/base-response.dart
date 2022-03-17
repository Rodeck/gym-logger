class BaseResponse<TResponse> {
  final TResponse? result;
  final bool success;
  final String? message;

  BaseResponse({required this.success, this.message, this.result});
}
