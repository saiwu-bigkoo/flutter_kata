import 'BaseDataViewable.dart';

abstract class BaseListViewable extends BaseDataViewable{
  void onLoadingMore(bool isLoadingMore);
}