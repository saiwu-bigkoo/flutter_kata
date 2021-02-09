import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Dio 请求方法的枚举
enum DioMethod {
  get,
  post,
  delete,
  put,
  path,
  head,
  upload,
  download,
}

class DioManager {
  //同一个CancelToken可以用于多个请求，当一个CancelToken取消时，所有使用该CancelToken的请求都会被取消，一个页面对应一个CancelToken。
  Map<String, CancelToken> _cancelTokens =  Map<String, CancelToken>();

  //超时时间
  static const int CONNECT_TIMEOUT = 30000;
  static const int RECEIVE_TIMEOUT = 30000;

  Dio _dio;
  // 无论是new还是_getInstance都是返回同一个实例
  factory DioManager() =>getInstance();
  static DioManager get instance => getInstance();
  static DioManager _instance;

  /// 初始化
  DioManager._internal() {
    if (_dio == null) {
      // 设置 Dio 默认配置
      _dio = Dio(BaseOptions(
        // 连接服务器超时时间，单位是毫秒
        connectTimeout: CONNECT_TIMEOUT,
        // 接收数据的最长时限
        receiveTimeout: RECEIVE_TIMEOUT,
        headers: {},
      ));
    }
  }

  static DioManager getInstance() {
    if (_instance == null) {
      _instance = new DioManager._internal();
    }
    return _instance;
  }

  Dio getDio() {
    return _dio;
  }

  /// 设置 请求 通用配置
  /// The common config for the Dio instance.
  DioManager setOptions({BaseOptions options, List<Interceptor> interceptors}){
    if (options != null)
      _dio.options = options;

    if (interceptors != null && interceptors.isNotEmpty) {
      _dio.interceptors..addAll(interceptors);
    }
    return _instance;
  }

  /// 加入拦截器，也可以通过 setOptions 来设置
  /// Dio instance may have interceptor(s) by which you can intercept, also can use setOptions( )
  DioManager addInterceptors(List<Interceptor> interceptors){
    if (interceptors != null && interceptors.isNotEmpty) {
      _dio.interceptors..addAll(interceptors);
    }
    return _instance;
  }

  /// 加入统一请求头, 相同key存在则会替换
  /// add request header
  DioManager addHeader(Map<String, dynamic> headers){
    _dio.options.headers.addEntries(headers.entries);
    return _instance;
  }

  /// 移除请求头, 相同key存在则会替换
  /// remove request header of the key
  DioManager removeHeader(String headerKey){
    _dio.options.headers.remove(headerKey);
    return _instance;
  }


  /// 加入baseUrl，也可以通过 setOptions 来设置
  /// add request baseUrl, also can use setOptions( )
  DioManager setBaseUrl(String baseUrl){
    _dio.options.baseUrl = baseUrl;
    return _instance;
  }

  /// get 请求
  Future<Response<T>> get<T>({@required String url, Options option, Map params, String tag}) {
    return requestHttp(url, option: option, method: DioMethod.get, params: params, tag: tag);
  }

  /// post 请求
  Future<Response<T>> post<T>({@required String url, Options option, Map params, String tag}) {
    return requestHttp(url, option: option, method: DioMethod.post, params: params, tag: tag);
  }

  /// put 请求
  Future<Response<T>> put<T>({@required String url, Options option, Map params, String tag}) {
    return requestHttp(url, option: option, method: DioMethod.put, params: params, tag: tag);
  }

  /// delete 请求
  Future<Response<T>> delete<T>({@required String url, Options option, Map params, String tag}) {
    return requestHttp(url, option: option, method: DioMethod.delete, params: params, tag: tag);
  }

  /// path 请求
  Future<Response<T>> path<T>({@required String url, Options option, Map params, String tag}) {
    return requestHttp(url, option: option, method: DioMethod.path, params: params, tag: tag);
  }

  /// head 请求
  Future<Response<T>> head<T>({@required String url, Options option, Map params, String tag}) {
    return requestHttp(url, option: option, method: DioMethod.head, params: params, tag: tag);
  }

  /// 上传文件
  Future<Response<T>> upload<T>({@required String url, Options option, FormData data, Map params, String tag, ProgressCallback onProgress}) {
    return requestHttp(url, option: option, method: DioMethod.upload, data: data, params: params, tag: tag, onProgress: onProgress);
  }

  /// 下载文件
  Future<Response<T>> download<T>({@required String url, Options option, String savePath, FormData data, Map params, String tag, ProgressCallback onProgress}) {
    return requestHttp(url, option: option, savePath: savePath, method: DioMethod.download, data: data, params: params, tag: tag, onProgress: onProgress);
  }

  /// Dio request 方法
  /// data Only available in upload/download
  Future<Response<T>> requestHttp<T>(String url, {DioMethod method = DioMethod.get, Options option,String savePath, FormData data, Map params, String tag, ProgressCallback onProgress}) {
    const methodValues = {
      DioMethod.get: 'get',
      DioMethod.post: 'post',
      DioMethod.delete: 'delete',
      DioMethod.put: 'put',
      DioMethod.path: 'path',
      DioMethod.head: 'head',
      DioMethod.upload: 'upload',
      DioMethod.download: 'download',
    };
    CancelToken cancelToken;
    if (tag != null) {
      cancelToken =
      _cancelTokens[tag] == null ? CancelToken() : _cancelTokens[tag];
      _cancelTokens[tag] = cancelToken;
    }

    option ??= Options(method: methodValues[method]);
    if (method == DioMethod.upload) {
      option.method = methodValues[DioMethod.post];
    }

    // 不同请求方法，不同的请求参数。按实际项目需求分，这里 get 是 queryParameters，其它用 data. FormData 也是 data
    // 注意: 只有 post 方法支持发送 FormData.
    switch (method) {
      case DioMethod.get:
        return _dio.request(url, queryParameters: params, options: Options(method: methodValues[method]), cancelToken: cancelToken);
      case DioMethod.upload:
        return _dio.request(url, onSendProgress: onProgress, data: data, queryParameters: params, options: Options(method: methodValues[DioMethod.post]), cancelToken: cancelToken);
      case DioMethod.download:
        return _dio.download(url,savePath, onReceiveProgress: onProgress, data: data, queryParameters: params, cancelToken: cancelToken);
      default:
        return _dio.request(url, data: params, options: Options(method: methodValues[method]), cancelToken: cancelToken);
    }
  }

  ///取消网络请求
  void cancel(String tag) {
    if (_cancelTokens.containsKey(tag)) {
      if (!_cancelTokens[tag].isCancelled) {
        _cancelTokens[tag].cancel();
      }
      _cancelTokens.remove(tag);
    }
  }

}
