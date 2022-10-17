import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String loadingText;
  LoadingView({
    Key? key,
    required this.child,
    this.isLoading = false,
    this.loadingText = '加载中...',
  }) : super(key: key);

  List<Widget> _buildSpin(BuildContext context) {
    return [
      child,
      isLoading
          ? Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Colors.black.withOpacity(0.4),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 100,
                      height: 100,
                      padding: const EdgeInsets.only(top: 15, bottom: 10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CupertinoActivityIndicator(),
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            color: Colors.white,
                            child: Text(
                              loadingText,
                              style: Theme.of(context).textTheme.bodyText1?.copyWith(fontSize: 10,fontWeight: FontWeight.w400),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          : Container(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _buildSpin(context),
    );
  }
}
