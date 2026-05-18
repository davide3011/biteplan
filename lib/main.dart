import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'features/meal_planner/providers/meal_planner_provider.dart';
import 'features/converter/providers/converter_provider.dart';
import 'features/shopping_list/providers/shopping_list_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MealPlannerProvider()..load()),
        ChangeNotifierProvider(create: (_) => ConverterProvider()..loadDb()),
        ChangeNotifierProvider(create: (_) => ShoppingListProvider()..load()),
      ],
      child: const BitePlanApp(),
    ),
  );
}
