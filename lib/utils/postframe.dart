import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

mixin PostFrameMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance?.addPostFrameCallback((_) => postFrame());
  }

  void postFrame();
}
