import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'logic.dart';

class Souce_editPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final logic = Get.put(Souce_editLogic());
    final state = Get.find<Souce_editLogic>().state;

    return Container();
  }
}
