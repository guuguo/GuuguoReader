import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:read_info/bean/book_item_bean.dart';
import 'package:read_info/data/rule/RuleUtil.dart';
import 'package:read_info/widget/container.dart';

import 'logic.dart';

class ExplorePage extends StatefulWidget {
  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<ExploreLogic>();
    return Scaffold(
      appBar: CupertinoNavigationBar(
          middle: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(logic.source.bookSourceName ?? ""),
      )),
      backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
      body: GetX<ExploreLogic>(
        builder: (ExploreLogic logic) {
          if (logic.refreshing.value) {
            return Center(child: CupertinoActivityIndicator(radius: 15));
          } else {
            var itemCount = logic.books.length + 1;
            return ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (c, i) {
                    if (i == itemCount - 1) {
                      if(!logic.loadEnd.value){
                        logic.loadMore();
                      }
                      return Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: logic.loadEnd.value?Text("已经到底了"):CupertinoActivityIndicator(),
                      );
                    }
                    var bean = logic.books[i];
                    return BookItemWidget(bean: bean);
                  },
                  itemCount: itemCount,
                );
          }
        },
      ),
    );
  }
}

class BookItemWidget extends StatelessWidget {
  const BookItemWidget({
    Key? key,
    required this.bean,
  }) : super(key: key);

  final BookItemBean bean;

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<ExploreLogic>();
    return GestureDetector(
      onTap: () {
        logic.toDetailPage(bean);
      },
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: EdgeInsets.all(15),
          decoration: RoundedBoxDecoration(
              radius: 10, color: Theme.of(context).cardColor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(bean.name ?? "",
                  style: Theme.of(context).textTheme.bodyLarge),
              SizedBox(height: 6),
              Text(bean.intro ?? "",
                  style: Theme.of(context).textTheme.bodySmall),
              SizedBox(height: 8),
              if (bean.coverUrl?.isNotEmpty == true)
                SizedBox(
                    width: double.infinity,
                    height: 180,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        urlFix(bean.coverUrl!,logic.source.bookSourceUrl!),
                        fit: BoxFit.cover,
                      ),
                    ))
            ],
          )),
    );
  }
}
