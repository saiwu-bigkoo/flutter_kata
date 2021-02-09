import 'package:dio/dio.dart';
import 'HttpResult.dart';
import 'HttpStatusConstants.dart';

typedef OnHttpSuccessFunction = void Function(dynamic data,String msg);
typedef OnHttpFailFunction = void Function(int code, String msg, [dynamic data]);
typedef OnNetWorkErrorFunction = void Function(String msg);
typedef OnCompleteFunction = void Function();

class HttpCallback{
  OnHttpSuccessFunction onHttpSuccessCallback;
  OnHttpFailFunction onHttpFailCallback;
  OnNetWorkErrorFunction onNetWorkErrorCallback;
  OnCompleteFunction onCompleteCallback;

  HttpCallback({this.onHttpSuccessCallback, this.onHttpFailCallback, this.onNetWorkErrorCallback, this.onCompleteCallback});
  void onResponse(Response response){
    try {
      HttpResult httpResult = HttpResult.fromJson(response.data);
      if (httpResult.code != null && httpResult.code == HttpStatusConstants.CODE_SUCCESS)
        onHttpSuccess(httpResult.data, httpResult.msg);
      else
        onHttpFail(httpResult.code, httpResult.msg, httpResult.data);
    }catch(e){
      //fromJson failed
      onHttpFail(HttpStatusConstants.CODE_ERROR_SERIALIZATION, "Serialization exception");
    }
  }

  void onException(DioError dioError){
    switch (dioError.type) {
      case DioErrorType.CANCEL:
        break;
      case DioErrorType.RECEIVE_TIMEOUT:
      case DioErrorType.CONNECT_TIMEOUT:
      case DioErrorType.SEND_TIMEOUT:
        onHttpFail(dioError.response.statusCode, handleError(dioError));
        break;
      case DioErrorType.DEFAULT:
      case DioErrorType.RESPONSE:
      //把它们归类为网络异常便于显示异常界面
        onNetWorkError(dioError.message);
        break;
    }
  }

  String handleError(DioError dioError) {
    String errorDescription = "";
    switch (dioError.type) {
      case DioErrorType.CANCEL:
        errorDescription = "Request to API server was cancelled";
        break;
      case DioErrorType.CONNECT_TIMEOUT:
        errorDescription = "Connection timeout with API server";
        break;
      case DioErrorType.DEFAULT:
        errorDescription =
        "Connection to API server failed due to internet connection";
        break;
      case DioErrorType.RECEIVE_TIMEOUT:
        errorDescription = "Receive timeout in connection with API server";
        break;
      case DioErrorType.RESPONSE:
        errorDescription =
        "Received invalid status code: ${dioError.response.statusCode}";
        break;
      case DioErrorType.SEND_TIMEOUT:
        errorDescription = "Send timeout in connection with API server";
        break;
    }
    return errorDescription;
  }


  /// 正常返回结果
  /// @param result 结果
  /// @param msg 附带消息
  void onHttpSuccess(dynamic result,String msg){
    if (onHttpSuccessCallback != null)
      onHttpSuccessCallback(result, msg);
  }

  /// 正常返回但code不是CODE_SUCCESS
  /// @param code 约定的错误码
  /// @param msg 附带消息
  void onHttpFail(int code, String msg, [dynamic result]){
    if (onHttpFailCallback != null)
      onHttpFailCallback(code, msg, result);
  }

  /// 非正常返回，通常是网络异常问题
  /// @param msg 异常描述
  void onNetWorkError(String msg){
    if (onNetWorkErrorCallback != null)
      onNetWorkErrorCallback(msg);
  }

  void onComplete(){
    if (onCompleteCallback != null)
      onCompleteCallback();
  }
}