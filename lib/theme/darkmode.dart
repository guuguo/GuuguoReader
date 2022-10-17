import 'dart:ui';

import 'package:flutter/scheduler.dart';

var brightness = SchedulerBinding.instance.window.platformBrightness;
bool isDarkMode = brightness == Brightness.dark;