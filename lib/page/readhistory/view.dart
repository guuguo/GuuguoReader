import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:read_info/data/rule/app_helper.dart';
import 'package:read_info/global/custom/my_theme.dart';
import 'package:read_info/widget/container.dart';

import '../../bean/book_item_bean.dart';
import 'logic.dart';

class ReadHistoryPage extends StatefulWidget {
  @override
  State<ReadHistoryPage> createState() => _ReadHistoryPageState();
}

class _ReadHistoryPageState extends State<ReadHistoryPage> {
  @override
  Widget build(BuildContext context) {
    Get.put(ReadHistoryLogic());
    return GetBuilder<ReadHistoryLogic>(
      assignId: true,
      builder: (logic) {
        final state=logic.state;
        if(state.books.isEmpty){
         return Center(child:Text("当前还没有阅读历史"));
        }
        return ListView(
        children: state.books.map((e) => BookReadItemWidget(bean:e)).toList());
      },
    );
  }
}

class BookReadItemWidget extends StatelessWidget {
  const BookReadItemWidget({
    Key? key,
    required this.bean,
  }) : super(key: key);

  final BookDetailBean bean;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.find<ReadHistoryLogic>().toReadPage(bean);
      },
      child: Center(
        child: Container(
            constraints: BoxConstraints.loose(Size(MyTheme.contentMaxWidth, double.infinity)),
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: EdgeInsets.symmetric(vertical: 8, horizontal:8),
            decoration: RoundedBoxDecoration(
                radius: 10, color: Theme.of(context).cardColor),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (bean.coverUrl?.isNotEmpty == true)
                  SizedBox(
                      width: 80,
                      height: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          bean.coverUrl!,
                          fit: BoxFit.cover,
                        ),
                      )),
                SizedBox(width:20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(bean.name ?? "",
                          style: Theme.of(context).textTheme.bodyLarge),
                      SizedBox(height: 6),
                      Row(children: [
                        Text(bean.author?.trim() ?? "",
                            style: Theme.of(context).textTheme.bodySmall),
                      ],),
                      if(bean.intro?.isNotEmpty==true)...[
                        SizedBox(height: 2),
                        Text(bean.intro!,style: Theme.of(context).textTheme.bodySmall,maxLines: 3,overflow: TextOverflow.ellipsis),
                      ]
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
