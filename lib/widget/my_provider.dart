import 'package:flutter/widgets.dart';

///提供状态存储
class MyProvider<T extends ChangeNotifier> extends InheritedWidget {
  T model;
  MyProvider({Key? key,required Widget child,required this.model}) : super(key: key,child:child);

  @override
  Widget build(BuildContext context) {
    return this.child;
  }

  static MyProvider<T>? of<T extends ChangeNotifier>(BuildContext context){
    return context.dependOnInheritedWidgetOfExactType<MyProvider<T>>();
  }

  @override
  bool updateShouldNotify(covariant MyProvider oldWidget) {
    return false;
  }
}
///提供状态消费，在状态ValueNotifier更新的时候，自动刷新Customer组件
class Customer<T extends ChangeNotifier> extends StatefulWidget{
  const Customer({required this.builder,});
  final ProviderBuilder<T> builder;

  @override
  State<Customer<T>> createState() => _CustomerState<T>();
}

class _CustomerState<T extends ChangeNotifier> extends State<Customer<T>> {

  late MyProvider? provider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    provider=MyProvider.of<T>(context);
    if(provider==null) throw "请在祖先节点提供MyProvider<T extends ChangeNotifier>";
    provider!.model.addListener(() {
      setState(()=>{});
    });
  }
  @override
  Widget build(BuildContext context) {
    return widget.builder(context,MyProvider.of<T>(context)!.model);
  }
}
typedef ProviderBuilder<T extends ChangeNotifier> = Widget Function(BuildContext context,T value);