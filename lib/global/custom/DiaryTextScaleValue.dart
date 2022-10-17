// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

class DiaryTextScaleValue {
  const

    DiaryTextScaleValue(this.scale, this.label);

    final double? scale;
    final String label;

    @override
    bool operator ==(
    dynamic other)

    {
        if (runtimeType != other.runtimeType)
            return false;
        final DiaryTextScaleValue typedOther = other;
        return scale == typedOther.scale && label == typedOther.label;
    }

    @override
    int get
    hashCode =>

    hashValues(scale, label);

    @override
    String toString() {
        return '$runtimeType($label)';
    }

}

///文字缩放比例
const List<DiaryTextScaleValue> kAllDiaryTextScaleValues=<DiaryTextScaleValue>[
        DiaryTextScaleValue(null,'System Default'),
        DiaryTextScaleValue(0.8,'Small'),
        DiaryTextScaleValue(1.0,'Normal'),
        DiaryTextScaleValue(1.3,'Large'),
        DiaryTextScaleValue(2.0,'Huge'),
        ];
