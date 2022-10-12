import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:read_info/widget/empty_view/index.dart';

import '../loading_view.dart';

class StateView extends StatelessWidget {
  StateView({
    this.state = WidgetState.content,
    this.emptyView = const EmptyView(desc: "暂无数据"),
    this.errorView = const EmptyView(
      desc: "出错了",
    ),
    this.loadingView = const Expanded(child: Center(child: CupertinoActivityIndicator())),
    required this.child,
  }) {}

  Widget errorView;
  Widget loadingView;
  Widget child;
  Widget emptyView;
  WidgetState state;

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case WidgetState.loading:
        return loadingView;
      case WidgetState.error:
        return errorView;
      case WidgetState.empty:
        return emptyView;
      case WidgetState.diaLoading:
        return LoadingView(
          child: child,
          isLoading: true,
        );
      case WidgetState.content:
        return child;
    }
  }
}

enum WidgetState { loading, diaLoading, content, error, empty }
