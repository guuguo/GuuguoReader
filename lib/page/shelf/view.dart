import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'logic.dart';

class ShelfPage extends StatefulWidget {
  @override
  State<ShelfPage> createState() => _ShelfPageState();
}

class _ShelfPageState extends State<ShelfPage>  with AutomaticKeepAliveClientMixin{
  @override
  Widget build(BuildContext context) {
    final logic = Get.put(ShelfLogic());
    final state = Get.find<ShelfLogic>().state;

    return Container();
  }

  @override
  bool get wantKeepAlive => true;
}
