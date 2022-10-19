import 'package:get/get.dart';

import 'state.dart';

class HomeLogic extends GetxController {
  final HomeState state = HomeState();

  void setIndex(int index) {
    state.currentIndex = index;
    update();
  }
}
