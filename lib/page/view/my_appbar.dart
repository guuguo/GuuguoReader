import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../global/custom/my_theme.dart';

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  const MyAppBar({
    Key? key,
    this.leading,
    this.middle,
    this.trail,
  }) : super(key: key);

  @override
  State<MyAppBar> createState() => _MyAppBarState();
  final Widget? leading;
  final Widget? middle;
  final List<Widget>? trail;

  @override
  Size get preferredSize => Size(double.infinity, kToolbarHeight);
}

class _MyAppBarState extends State<MyAppBar> {
  @override
  Widget build(BuildContext context) {
    var barChild = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 16),
        Expanded(
          child: widget.leading ?? SizedBox(),
        ),
        SizedBox(width: 10),
        if (widget.trail != null) ...[...widget.trail!, SizedBox(width: 6)] else SizedBox(width: 16)
      ],
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppBarTheme.of(context).systemOverlayStyle ?? (Theme.of(context).brightness == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark),
        child: Container(
          color: Theme.of(context).appBarTheme.backgroundColor,
          child: Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(child: SizedBox()),
                widget.middle == null
                    ? barChild
                    : Stack(
                        children: [
                          Positioned.fill(
                            child: barChild,
                          ),
                          Positioned.fill(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: SizedBox(),
                                ),
                                widget.middle!,
                                Expanded(
                                  child: SizedBox(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                Expanded(child: SizedBox()),
                Divider(
                  height: 0.5,
                  thickness: 0.5,
                ),
              ],
            ),
          ),
        ));
  }
}
