import 'package:flutter_kata/http/HttpManager.dart';
import 'package:flutter_kata/http/HttpCallback.dart';
import 'package:flutter_kata/viewable/BaseDataViewable.dart';

abstract class BaseDataPresenter<V extends BaseDataViewable>{
  V viewable;
  //刷新状态
  bool refreshing = false;
  //空数据状态
  bool statusEmpty = false;
  //加载中状态
  bool statusLoading = false;
  //错误状态
  bool statusError = false;
  //网络异常状态
  bool statusNetworkError = false;
  //控制loading状态只有一次,对于列表的loading概念，就是首次加载数据，其余加载是刷新
  bool once = false;

  BaseDataPresenter(this.viewable);

  bool isOnce() {
    return once;
  }

  void setOnce(bool once) {
    this.once = once;
  }

  bool isRefreshing() {
    return refreshing;
  }

  void setRefreshing(bool refreshing) {
    this.refreshing = refreshing;
    viewable.onRefreshing(refreshing);
  }

  void setRefreshingWithOutViewRefresh(bool refreshing) {
    this.refreshing = refreshing;
  }

  bool isStatusEmpty() {
    return statusEmpty;
  }

  void setStatusEmpty(String msg) {
    this.statusEmpty = true;
    viewable.onStatusEmpty(msg);
  }

  bool isStatusLoading() {
    return statusLoading;
  }

  void setStatusLoading() {
    this.statusLoading = true;
    viewable.onStatusLoading();
  }

  bool isStatusError() {
    return statusError;
  }

  void setStatusError(int code, String msg, Object data) {
    this.statusError = true;
    viewable.onStatusError(code,msg, data);
  }

  bool isStatusNetworkError() {
    return statusNetworkError;
  }

  void setStatusNetworkError(String msg) {
    this.statusNetworkError = true;
    viewable.onStatusNetworkError(msg);
  }

  void onLoadComplete(){
    viewable.onLoadComplete();
  }

  void dispose() {
    viewable = null;
    HttpManager.instance.cancel(getTagName());
  }

  HttpCallback callBack;
  /// 网络请求
  Future onLoadDataHttpRequest();
  void onLoadData();

  void onCallHttpRequest(Future future, [HttpCallback httpCallback]) async {
    await future.then((value) => httpCallback?.onResponse(value)).catchError((e){httpCallback?.onException(e);}).whenComplete(() => httpCallback?.onComplete());
  }

  String getTagName(){
    return runtimeType.toString();
  }
}