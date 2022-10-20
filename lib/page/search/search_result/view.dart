import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:read_info/page/explore/view.dart';
import 'package:read_info/page/view/my_appbar.dart';

import '../../../global/constant.dart';
import 'logic.dart';

class SearchResultPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final logic = Get.put(SearchResultLogic());
    final state = Get
        .find<SearchResultLogic>()
        .state;

    return Scaffold(
        appBar: MyAppBar(
            leading: Row(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  icon: const BackButtonIcon(),
                  tooltip: MaterialLocalizations
                      .of(context)
                      .backButtonTooltip,
                  onPressed: () {
                    Navigator.maybePop(context);
                  },
                ),
                SizedBox(width: 6),
                GetBuilder<SearchResultLogic>(
                  assignId: true,
                  builder: (logic) {
                    return Text("${state.searchKey}" + (state.donnSourceCount > 0 ? "(${state.donnSourceCount})" : ""));
                  },
                ),
              ],
            ),
            trail: [
              SizedBox(
                  width: 15,
                  height: 15,
                  child: GetBuilder<SearchResultLogic>(
                    assignId: true,
                    builder: (logic) {
                      if (state.loading)
                        return CircularProgressIndicator(strokeWidth: 2);
                      else
                        return SizedBox();
                    },
                  )),
              IconButton(
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.stop),
                tooltip: MaterialLocalizations
                    .of(context)
                    .backButtonTooltip,
                onPressed: () {},
              ),
            ]),
        body: GetBuilder<SearchResultLogic>(
          assignId: true,
          builder: (logic) {
            return ListView(
                children: state.books
                    .map((e) => BookItemWidget(
                          bean: e,
                        ))
                    .toList());
          },
        ));
  }
}
