// Importa tutti i file di lib/ così il report di coverage include anche
// i file non toccati da alcun test (altrimenti lcov li ignora del tutto).
// ignore_for_file: unused_import
import 'package:biteplan/app.dart';
import 'package:biteplan/core/constants/app_constants.dart';
import 'package:biteplan/core/theme/app_theme.dart';
import 'package:biteplan/features/converter/models/conversion_entry.dart';
import 'package:biteplan/features/converter/presentation/pages/converter_page.dart';
import 'package:biteplan/features/converter/providers/converter_provider.dart';
import 'package:biteplan/features/guide/presentation/pages/guide_page.dart';
import 'package:biteplan/features/guide/presentation/widgets/info_bottom_sheet.dart';
import 'package:biteplan/features/meal_planner/models/meal_plan.dart';
import 'package:biteplan/features/meal_planner/presentation/pages/meal_planner_page.dart';
import 'package:biteplan/features/meal_planner/presentation/pages/qr_scan_page.dart';
import 'package:biteplan/features/meal_planner/presentation/widgets/meal_card.dart';
import 'package:biteplan/features/meal_planner/presentation/widgets/qr_share_sheet.dart';
import 'package:biteplan/features/meal_planner/providers/meal_planner_provider.dart';
import 'package:biteplan/features/meal_planner/qr_codec.dart';
import 'package:biteplan/features/shopping_list/models/shopping_item.dart';
import 'package:biteplan/features/shopping_list/presentation/pages/shopping_list_page.dart';
import 'package:biteplan/features/shopping_list/presentation/widgets/shopping_item_tile.dart';
import 'package:biteplan/features/shopping_list/providers/shopping_list_provider.dart';
import 'package:biteplan/main.dart';
import 'package:biteplan/shared/services/storage_service.dart';
import 'package:biteplan/shared/services/update_service.dart';
import 'package:biteplan/shared/services/url_launcher_service.dart';
import 'package:biteplan/shared/widgets/empty_state.dart';
import 'package:biteplan/shared/widgets/update_dialog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('coverage helper', () {
    expect(true, isTrue);
  });
}
