import 'package:flutter/material.dart';

import 'custom/DiaryTextScaleValue.dart';
import 'custom/my_theme.dart';

///久忆日记设置相关类
class OptionsModel extends ChangeNotifier {
  OptionsModel() {
    _instance = this;
  }

  static OptionsModel? _instance;

  static OptionsModel? get() => _instance;

  DiaryTheme? _theme;
  DiaryTextScaleValue? _textScaleFactor;
  TextDirection? _textDirection;
  double? _timeDilation;
  TargetPlatform? _platform;
  bool? _showPerformanceOverlay;
  bool? _showRasterCacheImagesCheckerboard;
  bool? _showOffscreenLayersCheckerboard;

  /// 如果[isLightTheme] 切为明亮主题
  refreshLightTheme(bool isLightTheme, {bool save = true}) {
    final theme = isLightTheme ? kLightDiaryTheme : kDarkDiaryTheme;
    this._theme = theme;
    notifyListeners();
    if (save) _saveTheme(theme.data.brightness == Brightness.light);
  }

  Future _saveTheme(bool isLightTheme) async {
//    final prefs = await SharedPreferences.getInstance();
//    await prefs.setBool('isLightTheme', isLightTheme);
  }

  DiaryTheme? get theme => _theme;

  DiaryTextScaleValue? get textScaleFactor => _textScaleFactor;

  TextDirection? get textDirection => _textDirection;

  double? get timeDilation => _timeDilation;

  TargetPlatform? get platform => _platform;

  bool? get showPerformanceOverlay => _showPerformanceOverlay;

  bool? get showRasterCacheImagesCheckerboard =>
      _showRasterCacheImagesCheckerboard;

  bool? get showOffscreenLayersCheckerboard => _showOffscreenLayersCheckerboard;
}
