import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/meal_planner/presentation/pages/meal_planner_page.dart';
import 'features/converter/presentation/pages/converter_page.dart';
import 'features/shopping_list/presentation/pages/shopping_list_page.dart';
import 'features/guide/presentation/widgets/info_bottom_sheet.dart';
import 'shared/services/update_service.dart';
import 'shared/services/url_launcher_service.dart';

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

  static const _titles = ['Piano Pasti', 'Convertitore', 'Lista della spesa'];
  static const _releasesUrl =
      'https://github.com/davide3011/biteplan/releases/latest';

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
    UpdateService.checkUpdate().then((newVersion) {
      if (newVersion != null && mounted) {
        _showUpdateDialog(newVersion);
      }
    });
  }

  void _showUpdateDialog(String newVersion) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.system_update_outlined, size: 32),
        title: const Text('Aggiornamento disponibile'),
        content: Text(
          'È disponibile la versione $newVersion di BitePlan.\n'
          'Vuoi scaricare il nuovo APK?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Più tardi'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              UrlLauncherService.launch(_releasesUrl);
            },
            child: const Text('Scarica'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Informazioni',
            onPressed: () => showInfoBottomSheet(context),
          ),
        ],
      ),
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
