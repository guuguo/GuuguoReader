import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:read_info/page/view/my_appbar.dart';
import 'package:read_info/widget/reader/reder_view.dart';

class ReaderMenu extends StatelessWidget {
  const ReaderMenu({Key? key, this.chapterName}) : super(key: key);
  final String? chapterName;
  final bgColor = Colors.black87;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
        child: DefaultTextStyle(
      style: TextStyle(inherit: false, color: Colors.white),
      child: IconTheme(
          data: IconTheme.of(context).copyWith(color: Colors.white),
          child: Column(
            children: [
              MenuHeader(context),
              Expanded(child: SizedBox()),
              MenuBottom(context),
            ],
          )),
    ));
  }

  Widget MenuHeader(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        width: double.infinity,
        color: bgColor,
        child: Container(
          height: kToolbarHeight,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: MyBackButton(),
              ),
              Text(chapterName ?? "", style: TextStyle(fontSize: 18))
            ],
          ),
        ));
  }

  Widget MenuBottom(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      width: double.infinity,
      color: bgColor,
      child: Container(
        height: 80,
        constraints: BoxConstraints.loose(Size(600, double.infinity)),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IconMenu(Icons.format_list_bulleted, onPressed: () {
              NovelReader.of(context)?.onMenuChange?.call(false);
              NovelReader.of(context)?.showChapterIndex?.call();
            }),
            IconMenu(Icons.format_size),
            IconMenu(Icons.light_mode),
            IconMenu(Icons.search),
            IconMenu(Icons.screen_rotation),
          ],
        ),
      ),
    );
  }

  Widget IconMenu(IconData icon, {VoidCallback? onPressed}) {
    return Expanded(child: GestureDetector(onTap: onPressed, child: Icon(icon)));
  }
}
