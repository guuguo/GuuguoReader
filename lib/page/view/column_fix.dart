
import 'package:flutter/widgets.dart';
import 'package:read_info/utils/ext/list_ext.dart';
import 'package:quiver/iterables.dart';

class ColumnFix extends StatelessWidget {
  const ColumnFix({
    Key? key,
    required this.children,
    required this.rowCount,
    this.rowSpan = 30,
    this.columnSpan = 10,
    this.crossAxisAlignment=CrossAxisAlignment.start,
  }) : super(key: key);
  final List<Widget> children;
  final int rowCount;
  final double rowSpan;
  final double columnSpan;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final spanLength = (children.length + 1) ~/ rowCount;
    Iterable<List<Widget>> columns = partition(children, spanLength);
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: columns
            .map((list) => Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: crossAxisAlignment,
            children: list.separated((index) => SizedBox(height: columnSpan)),
          ),
        ))
            .separated((i) => SizedBox(width: rowSpan)));
  }
}
