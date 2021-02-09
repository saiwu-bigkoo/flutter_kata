class HttpResult{
  int code;
  String msg;
  dynamic data;

  HttpResult({this.code, this.msg, this.data});

  factory HttpResult.fromJson(Map<String, dynamic> json) {
    return HttpResult(
      code: json['code'],
      msg: json['msg'],
      data: json['data'],
    );
  }
}