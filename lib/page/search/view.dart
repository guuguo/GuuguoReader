import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:read_info/global/custom/my_theme.dart';
import 'package:read_info/page/view/icon.dart';
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
          leading: SearchEditItem(onSearch: (value) {
            Get.find<SearchLogic>().toSearchResultPage(value);
          }),
        ),
        body: Container(
          padding:EdgeInsets.symmetric(horizontal:16),
          child: Column(
            children: [
              Row(children: [
                Text("历史搜索",style:TextStyle(color:MyTheme.of(context).hintTextColor)),
                Expanded(child: SizedBox()),
              ])
            ],
          ),
        ));
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
                onChanged: (value){
                  this.value=value;
                },
                textInputAction: TextInputAction.search,
                style:  Theme.of(context).textTheme.caption,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: MyTheme(context).searchBarColor,
                    prefixIcon: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.arrow_back,
                          size:18,
                          color: MyTheme(context).searchTextColor,
                        ),
                        onPressed: () {
                          Get.back();
                        }),
                    suffixIcon: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.search,
                          size:18,
                          color:  MyTheme(context).searchTextColor,
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
