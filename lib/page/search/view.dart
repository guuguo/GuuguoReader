import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/src/rendering/sliver.dart';
import 'package:flutter/src/rendering/sliver_grid.dart';
import 'package:get/get.dart';
import 'package:read_info/global/custom/my_theme.dart';
import 'package:read_info/utils/ext/list_ext.dart';
import 'package:read_info/widget/container.dart';

import '../view/my_appbar.dart';
import 'logic.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final logic = Get.put(SearchLogic());
    final state = Get.find<SearchLogic>().state;

    return Scaffold(
        appBar: MyAppBar(
          leading: SearchEditItem(onSearch: (value) async {
            await Get.find<SearchLogic>().toSearchResultPage(value);
            await logic.saveHistory(value);
          }),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text("历史搜索", style: TextStyle(color: MyTheme.of(context).hintTextColor)),
              ]),
              SizedBox(height: 10),
              GetBuilder<SearchLogic>(
                assignId: true,
                builder: (logic) {
                  return LayoutBuilder(builder: (context, ct) {
                    final space = 10.0;
                    final count = 4;
                    final width = (ct.maxWidth - space * (count - 1)) / count;
                    final histories = logic.state.historys;
                    return Column(
                      children: [
                        Row(children: histories.take(count).map((e) => Container(width: width, child: HistoryItem(e))).separated<Widget>((i) => SizedBox(width: space)).toList()),
                        if (histories.length > 4) ...[
                          SizedBox(height: 10),
                          Row(
                            children: histories.getRange(count, min(histories.length,count * 2)).map((e) => Container(width: width, child: HistoryItem(e))).separated<Widget>((i) => SizedBox(width: space)).toList(),
                          ),
                        ]
                      ],
                    );
                  });
                },
              )
            ],
          ),
        ));
  }

  Widget HistoryItem(String his) {
    final logic = Get.find<SearchLogic>();
    return Builder(builder: (context) {
      return GestureDetector(
        onTap: () async {
          await logic.saveHistory(his);
          logic.toSearchResultPage(his);
        },
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(his, style: Theme.of(context).textTheme.caption?.copyWith(height: 1)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: MyTheme.of(context).hintTextColor, width: 0.5),
          ),
        ),
      );
    });
  }
}

class SearchEditItem extends StatefulWidget {
  const SearchEditItem({Key? key, required this.onSearch}) : super(key: key);
  final ValueChanged<String> onSearch;

  @override
  State<SearchEditItem> createState() => _SearchEditItemState();
}

class _SearchEditItemState extends State<SearchEditItem> {
  var value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 33,
      decoration: RoundedBoxDecoration(radius: 20, color: MyTheme(context).searchBarColor),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        textBaseline: TextBaseline.ideographic,
        children: [
          Expanded(
            child: SizedBox(
              child: TextField(
                onSubmitted: widget.onSearch,
                textAlignVertical: TextAlignVertical.center,
                maxLines: 1,
                onChanged: (value) {
                  this.value = value;
                },
                textInputAction: TextInputAction.search,
                style: Theme.of(context).textTheme.caption,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: MyTheme(context).searchBarColor,
                    prefixIcon: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.arrow_back,
                          size: 18,
                          color: MyTheme(context).searchTextColor,
                        ),
                        onPressed: () {
                          Get.back();
                        }),
                    suffixIcon: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.search,
                          size: 18,
                          color: MyTheme(context).searchTextColor,
                        ),
                        onPressed: () {
                          if (value != null) widget.onSearch(value);
                        }),
                    hintText: "输入书名或作者名",
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    )),
              ),
            ),
          )
        ],
      ),
    );
  }
}
