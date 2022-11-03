// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:read_info/main.dart';

void main() {
  // final arrayNumsReg=RegExp(r"\[((\d+),?)+\]");
  // final res=arrayNumsReg.firstMatch(" .hot_sale[12,2,3,4,5]  AS大S大赛[1:] asdasd[:99]");
  // var i=0;
  // while(true){
  //   final group=res?.group(i);
  //   if(group==null) break;
  //   print(group);
  //   i++;
  // }
  final url = "/kanshu/a/105978_1.html";
  final uri = Uri.parse(url);
  var newPathSegments = uri.pathSegments;
  if (uri.pathSegments.last.contains(".")) {
    newPathSegments = [...uri.pathSegments]..remove(uri.pathSegments.last);
  }
  print(uri.replace(
    pathSegments: newPathSegments,
    host: uri.hasAuthority ? null : "www.baidu.com",
    scheme: uri.hasScheme ? null : "https",
  ));
  // testWidgets('Counter increments smoke test', (WidgetTester tester) async {
  //   // Build our app and trigger a frame.
  //   await tester.pumpWidget(MyApp());
  //
  //   // Verify that our counter starts at 0.
  //   expect(find.text('0'), findsOneWidget);
  //   expect(find.text('1'), findsNothing);
  //
  //   // Tap the '+' icon and trigger a frame.
  //   await tester.tap(find.byIcon(Icons.add));
  //   await tester.pump();
  //
  //   // Verify that our counter has incremented.
  //   expect(find.text('0'), findsNothing);
  //   expect(find.text('1'), findsOneWidget);
  // });
}
