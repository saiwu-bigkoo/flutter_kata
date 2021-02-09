
import 'package:flutter/widgets.dart';
import 'package:kata/presenter/BaseListPresenter.dart';
import 'package:kata/viewable/BaseListViewable.dart';

import 'BaseDataWidget.dart';

abstract class BaseListWidget extends BaseDataWidget{
  BaseListWidget({ Key key }) : super(key: key);
  @override
  State createState(){
    return getState() ;
  }

  State getState();
}

abstract class BaseListWidgetState<W extends BaseListWidget, P extends BaseListPresenter> extends BaseDataWidgetState<W, P> implements BaseListViewable {
  @override
  void onLoadingMore(bool isLoadingMore) {
  }

  /// 返回数据回调，封装了是否有更多的逻辑，如果data不直接是列表而是被其他对象包裹住了，则自己把列表抽出来传到super里面,或自己重写整个逻辑
  @override
  void onDataSetChange(data, String msg) {
    super.onDataSetChange(data, msg);
    // 为什么要在这里判断而不是在presenter逻辑里判断？有些请求接口返回的不一定是数组，可能外面还要包一层对象，我们通过重写此方法来把外面一层剥离后再做此操作，重写这个方法比重写presenter里面的逻辑方便得多
    int size = 0;
    try {
      size = (data as List).length;
    }catch(e){}
    //如果列表没有数据，同时之前也没有数据，则回调空状态
    if (size == 0){
        if(presenter.dataEmpty) {
          onStatusEmpty(msg);
        }
    }
    else if (size < presenter.getPageSize()) {
      presenter.setHasMore(false);
    }

    setState(() {
      //刷新回来先清空旧数据
      if (presenter.isFirstPage())
        presenter.dataList.clear();
      presenter.dataList.addAll(data);
    });

  }
}