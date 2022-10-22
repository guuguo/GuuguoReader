import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:read_info/global/constant.dart';
import 'package:read_info/page/view/my_appbar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../bean/book_item_bean.dart';
import 'logic.dart';

class DetailSmsPage extends StatefulWidget {
  @override
  State<DetailSmsPage> createState() => _DetailSmsPageState();
}

class _DetailSmsPageState extends State<DetailSmsPage> {
  late BookItemBean itemBean;

  @override
  initState() {
    super.initState();
    itemBean = Get.arguments[ARG_BOOK_ITEM_BEAN];
    Get.find<DetailLogic>().init(itemBean);
  }

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<DetailLogic>();
    return Scaffold(
      appBar: MyAppBar(middle: Text("${itemBean.name}")),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: GetX<DetailLogic>(
          builder: (DetailLogic logic) {
            final bean = logic.detail.value;
            if (logic.refreshing.value) {
              return Center(child: CupertinoActivityIndicator());
            } else {
              return SingleChildScrollView(
                child: Center(
                  child: Container(
                    constraints: BoxConstraints.loose(
                        Size(800, double.infinity)),
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SizedBox(height: 10),
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: ShapeDecoration(
                            shadows: [
                              BoxShadow(
                                color: Theme.of(context).dividerColor,
                                offset: Offset(0, 3),
                                blurRadius: 10,
                              )
                            ],
                            color: Theme.of(context).cardColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Html(
                            onLinkTap: (url, context, attr, ele) {
                              launchUrl(
                                Uri.parse(url ?? ""),
                                mode: LaunchMode.externalApplication,
                              );
                            },
                            data: logic.detail.value?.intro ?? "",
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
