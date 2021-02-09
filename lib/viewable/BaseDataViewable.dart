abstract class BaseDataViewable{
  void onRefreshing(bool refreshing);

  void onStatusEmpty(String msg);

  void onStatusLoading();

  void onStatusError(int code, String msg, dynamic data);

  void onStatusNetworkError(String msg);

  /// 数据回调，如果是列表页并且data不是直接列表数据而是先包裹一层或几层需要自己刨开拿到列表的请参考BaseListWideget的该方法逻辑再重写该方法
  void onDataSetChange(dynamic data, String msg);

  void onLoadComplete();

  dynamic returnBindingPresenter();
}