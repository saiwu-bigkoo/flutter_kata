import 'package:flutter/widgets.dart';
import 'package:kata/presenter/BaseDataPresenter.dart';
import 'package:kata/viewable/BaseDataViewable.dart';

abstract class BaseDataWidget extends StatefulWidget{
  BaseDataWidget({ Key key }) : super(key: key);
  @override
  State createState(){
    return getState() ;
  }

  State getState();
}

abstract class BaseDataWidgetState<W extends BaseDataWidget, P extends BaseDataPresenter> extends State<W> implements BaseDataViewable {

  P presenter;

  @override
  void initState() {
    presenter = returnBindingPresenter();
    super.initState();
  }

  void onRefreshing(bool refreshing){}

  void onStatusEmpty(String msg){}

  void onStatusLoading(){}

  void onStatusError(int code, String msg, dynamic data){}

  void onStatusNetworkError(String msg){}

  void onDataSetChange(dynamic data, String msg){}

  void onLoadComplete(){}

  @override
  void dispose() {
    presenter.dispose();
    super.dispose();
  }
}