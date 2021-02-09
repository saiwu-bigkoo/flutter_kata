import 'package:kata/http/HttpCallback.dart';
import 'package:kata/viewable/BaseListViewable.dart';

import 'BaseDataPresenter.dart';

abstract class BaseListPresenter<T extends BaseListViewable> extends BaseDataPresenter<T>{
  List<dynamic> dataList = [];
  bool dataEmpty;
  static const int firstPage = 1;
  //分页页码
  int page = firstPage;
  //分页每页Item数量
  static const int PAGESIZE_DEFULT = 20;
  int pageSize = PAGESIZE_DEFULT;
  bool isHasMore = true;
  bool isLoadingMore = false;

  BaseListPresenter(BaseListViewable viewable) : super(viewable){
    callBack = new HttpCallback(
        onHttpSuccessCallback:(dynamic resultData, String msg) {
          //如果是第一页就清空旧数据再加入新数据
          if (isFirstPage()) {
            clearDatas();
          }
          if (resultData != null) {
            addData(resultData, msg);
          } else {
            setHasMore(false);
            if (isDataEmpty()) {
              setStatusEmpty(msg);
            }
          }
        },
        onHttpFailCallback:(int code, String msg, [dynamic data]) {
          setStatusError(code, msg, data);
        },
        onNetWorkErrorCallback: (String msg) {
          setStatusNetworkError(msg);
        },
        onCompleteCallback: () {
          setOnce(true);
          setRefreshing(false);
          if (isFirstPage())//因为在刷新之前已经把page设为了firstPage，所以可以判断isFirstPage()来判断当前是否刷新
            setRefreshing(false);
          else
            setLoadingMore(false);
          onLoadComplete();
        }
    );
  }

  int getFirstPage() {
    return firstPage;
  }

  bool isFirstPage() {
    return firstPage == page;
  }

  int getPage() {
    return page;
  }

  void setPage(int page) {
    this.page = page;
  }

  int getPageSize() {
    return pageSize;
  }

  void setPageSize(int pageSize) {
    this.pageSize = pageSize;
  }

  void setHasMore(bool hasMore) {
    isHasMore = hasMore;
  }

  void setLoadingMore(bool loadingMore) {
    isLoadingMore = loadingMore;
    viewable.onLoadingMore(loadingMore);
  }

  void setPageAdd() {
    page++;
  }

  void addData(dynamic data, String msg) {
    if (data == null) {
      if(dataEmpty) {
        viewable.onStatusEmpty(msg);
      }
    }
    else  {
      dataEmpty = false;
      if (data != null) {
        viewable.onDataSetChange(data, msg);
      }
    }
  }

  bool isDataEmpty() {
    return dataEmpty;
  }

  void clearDatas() {
    dataEmpty = true;
  }

  /// 这里重写onLoadData，列表不能直接onLoadData，而是刷新
  void onLoadData() {
    onListRefresh();
  }

  /// 加载更多
  void onLoadMore() {
    onListLoadMore();
  }

  /// 刷新数据
  void onListRefresh() {
    setRefreshing(true);
    //把分页配置还原成加载第一页状态
    setPage(getFirstPage());
    setHasMore(true);
    setLoadingMore(false);
    if (!isOnce())
      setStatusLoading();
    onCallHttpRequest(onLoadDataHttpRequest(), callBack);
  }

  void onRefreshWithOutViewRefresh(){
    setRefreshingWithOutViewRefresh(true);
    //把分页配置还原成加载第一页状态
    setPage(getFirstPage());
    setHasMore(true);
    setLoadingMore(false);
    onCallHttpRequest(onLoadDataHttpRequest(), callBack);
  }


  /// 加载数据
  void onListLoadMore() {
    //判断是否已经在进行加载更多 或 没有更多了，是则直接返回等待加载完成。
    if (isLoadingMore || !isHasMore) return;
    //刷新中也直接返回不加载更多
    if (isRefreshing()) return;
    setLoadingMore(true);
    //分页增加
    setPageAdd();

    onCallHttpRequest(onLoadDataHttpRequest(), callBack);
  }



}