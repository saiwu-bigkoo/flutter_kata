import 'package:kata/http/HttpCallback.dart';
import 'package:kata/viewable/BaseDataViewable.dart';
import 'BaseDataPresenter.dart';

abstract class BaseDetailPresenter<V extends BaseDataViewable> extends BaseDataPresenter<V>{

  BaseDetailPresenter(BaseDataViewable viewable) : super(viewable){
    callBack = new HttpCallback(
      onHttpSuccessCallback: (dynamic resultData, String msg) {
        if (resultData != null) {
          viewable.onDataSetChange(resultData, msg);
        } else {
          setStatusEmpty(msg);
        }
      },
      onHttpFailCallback: (int code, String msg, [dynamic data]) {
        setStatusError(code, msg, data);
      },
      onNetWorkErrorCallback: (String msg) {
        setStatusNetworkError(msg);
      },
      onCompleteCallback: () {
        setOnce(true);
        setRefreshing(false);
        onLoadComplete();
      }
    );
  }


  /// 刷新/加载数据
  void onLoadData() {
    setRefreshing(true);
    //这里考虑到首次加载是 loading，以后加载是refresh 模式
    if (!isOnce())
      setStatusLoading();
    onRefreshWithOutViewRefresh();
  }

  void onRefreshWithOutViewRefresh(){
    setRefreshingWithOutViewRefresh(true);
    onCallHttpRequest(onLoadDataHttpRequest(), callBack);
  }


}