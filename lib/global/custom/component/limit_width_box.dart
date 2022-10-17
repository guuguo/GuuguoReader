import 'package:flutter/widgets.dart';
import 'package:read_info/global/custom/my_theme.dart';

class LimitWidthBox extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const LimitWidthBox({Key? key, required this.child,this.maxWidth=MyTheme.contentMaxWidth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
            constraints: BoxConstraints.loose(
                Size(maxWidth, double.infinity)),
            child: child));
  }
}
