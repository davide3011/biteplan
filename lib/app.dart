import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/meal_planner/presentation/pages/meal_planner_page.dart';
import 'features/converter/presentation/pages/converter_page.dart';
import 'features/shopping_list/presentation/pages/shopping_list_page.dart';

class BitePlanApp extends StatelessWidget {
  const BitePlanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BitePlan',
      theme: AppTheme.light(),
      debugShowCheckedModeBanner: false,
      home: const _MainScaffold(),
    );
  }
}

class _MainScaffold extends StatefulWidget {
  const _MainScaffold();

  @override
  State<_MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<_MainScaffold> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      MealPlannerPage(
        onGoShopping: () => setState(() => _currentIndex = 2),
      ),
      const ConverterPage(),
      const ShoppingListPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Pasti',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz_outlined),
            selectedIcon: Icon(Icons.swap_horiz),
            label: 'Converti',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Spesa',
          ),
        ],
      ),
    );
  }
}
