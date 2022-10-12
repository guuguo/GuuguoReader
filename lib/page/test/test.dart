import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:read_info/widget/my_provider.dart';

class TestWidget extends StatefulWidget {
  const TestWidget({Key? key}) : super(key: key);

  @override
  State<TestWidget> createState() => _TestWidgetState();
}
class TestModel extends ChangeNotifier{
  var num=0;

  TestModel() : super();
}

class _TestWidgetState extends State<TestWidget> {
   var model=TestModel();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: MyProvider<TestModel>(
        model:model,
        child: Builder(
          builder: (context) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MyTextWidget(),
                  MaterialButton(
                    color: Colors.blueAccent,
                      elevation: 10,
                      onPressed: () {
                        model.num++;
                        model.notifyListeners();
                      },
                      child: Text("点击加一")),
                ],
              ),
            );
          }
        ),
      ),
    );
  }
}
class MyTextWidget extends StatelessWidget {
  const MyTextWidget ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Customer<TestModel>(builder:(c,value) => Text("${value.num}"));
  }
}