import 'package:flutter/widgets.dart';
import 'package:flutter_kata/presenter/BaseDataPresenter.dart';
import 'package:flutter_kata/viewable/BaseDataViewable.dart';

abstract class BaseDataWidgetState<W extends StatefulWidget, P extends BaseDataPresenter> extends State<W> implements BaseDataViewable {

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