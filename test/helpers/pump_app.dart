import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:biteplan/core/theme/app_theme.dart';

extension PumpApp on WidgetTester {
  Future<void> pumpApp(Widget widget) => pumpWidget(
        MaterialApp(theme: AppTheme.light(), home: widget),
      );
}
