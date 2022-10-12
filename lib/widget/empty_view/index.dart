import 'package:flutter/material.dart';
import 'package:read_info/r.dart';

class EmptyView extends StatelessWidget {
  const EmptyView({
    Key? key,
    this.desc = "",
  }) : super(key: key);

  final String desc;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: 150,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            R.assetsImagesMessageEmpty,
            width: 47,
            fit: BoxFit.fitWidth,
          ),
          SizedBox(
            height: 4,
          ),
          Text(
            (desc.isNotEmpty) ? desc : '暂无数据',
            style: Theme.of(context).textTheme.caption,
          )
        ],
      ),
    );
  }
}
