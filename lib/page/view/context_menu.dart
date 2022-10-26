import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:read_info/widget/reader/reader_page_progress.dart';

Widget ContextMenu(
{
  required Widget child,
  ContextMenuPreviewBuilder? previewBuilder,
  required List<Pair<dynamic, VoidCallback?>> list,}
) {
  return CupertinoContextMenu(
    previewBuilder:previewBuilder,
    actions: list
        .map((Pair<dynamic, VoidCallback?> e) => CupertinoContextMenuAction(
              onPressed: () {
                if (e.seconed == null) Get.snackbar("提示", "暂未实现");
                e.seconed!();
              },
              child: Text(e.first.toString()),
            ))
        .toList(),
    child: child,
  );
}
