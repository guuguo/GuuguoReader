import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../global/custom/my_theme.dart';

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  const MyAppBar({
    Key? key,
    this.leading,
    this.middle,
    this.trail,
    this.bottom,
    this.autoImplLeading = true,
  }) : super(key: key);

  @override
  State<MyAppBar> createState() => _MyAppBarState();
  final Widget? leading;
  final Widget? middle;
  final bool autoImplLeading;
  final List<Widget>? trail;
  final PreferredSizeWidget? bottom;
  @override
  Size get preferredSize => Size(double.infinity, 45+(bottom?.preferredSize.height??0));
}

class _MyAppBarState extends State<MyAppBar> {
  @override
  Widget build(BuildContext context) {
    var leading = widget.leading;
    if (widget.autoImplLeading && widget.leading == null && Navigator.canPop(context)) {
      leading = Align(alignment:Alignment.centerLeft,child: MyBackButton());
    }
    leading = leading ?? SizedBox();
    var barChild = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 16),
        Expanded(child: leading),
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
                AppBar(barChild, context),
                if(widget.bottom!=null) widget.bottom!,
                Divider(
                  height: 0.5,
                  thickness: 0.5,
                ),
              ],
            ),
          ),
        ));
  }

  Expanded AppBar(Row barChild, BuildContext context) {
    return Expanded(
                child: widget.middle == null
                    ? Center(child: barChild)
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
                                DefaultTextStyle(style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold), child: widget.middle!),
                                Expanded(
                                  child: SizedBox(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              );
  }
}

class MyBackButton extends StatelessWidget {
  const MyBackButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.symmetric(horizontal:5),
      visualDensity: VisualDensity.compact,
      icon: const BackButtonIcon(),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: () {
        Navigator.maybePop(context);
      },
    );
  }
}
