import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/src/toast_widget/toast_widget.dart';

extension LoadingExt on String {
  CancelFunc showLoading() {
    return BotToast.showCustomLoading(
        wrapAnimation: loadingAnimation,
        align: Alignment.center,
        enableKeyboardSafeArea: true,
        toastBuilder: (_) => LoadingWidget(text: this),
        clickClose: true,
        allowClick: false,
        crossPage: true,
        ignoreContentClick: true,
        backButtonBehavior: BackButtonBehavior.close,
        backgroundColor: Colors.black26);
  }

  CancelFunc showMessage() {
    return BotToast.showText(text: this);
  }
}

//加载提示的Widget
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key? key, this.text}) : super(key: key);
  final String? text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: const BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.all(Radius.circular(8))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            backgroundColor: Colors.white,
          ),
          if (text != null) ...[SizedBox(height:10),Text(text!,style:TextStyle(color:Colors.white))]
        ],
      ),
    );
  }
}
