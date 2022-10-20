import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:read_info/page/view/my_appbar.dart';

import '../../../global/constant.dart';
import 'logic.dart';

class SearchResultPage extends StatelessWidget {
  String searchKey = "";

  @override
  Widget build(BuildContext context) {
    final logic = Get.put(SearchResultLogic());
    final state = Get.find<SearchResultLogic>().state;
    searchKey = Get.arguments[ARG_SEARCH_KEY];

    return Scaffold(
        appBar: MyAppBar(
            leading: Row(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  icon: const BackButtonIcon(),
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  onPressed: () {
                    Navigator.maybePop(context);
                  },
                ),
                SizedBox(width: 6),
                Text(searchKey),
              ],
            ),
            trail: [
              SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2)),
              IconButton(
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.stop),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () {
                },
              ),
            ]),
        body: Container());
  }
}
