import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'logic.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final logic = Get.put(HomeLogic());
    final state = Get.find<HomeLogic>().state;

    var bottomItems = state.pageList.keys
        .map((e) => BottomNavigationBarItem(
              icon: Icon(e.icon),
              activeIcon: Icon(e.iconSelected),
              label: e.label,
            ))
        .toList();

    return Scaffold(
        body: GetBuilder<HomeLogic>(
            assignId: true,
            builder: (logic) {
              return state.pageList.values.toList()[state.currentIndex];
            }),
        bottomNavigationBar: GetBuilder<HomeLogic>(
          assignId: true,
          builder: (logic) {
            return BottomNavigationBar(
              items: bottomItems,
              currentIndex: state.currentIndex,
              onTap: (index) {
                logic.setIndex(index);
              },
            );
          },
        ));
  }
}
