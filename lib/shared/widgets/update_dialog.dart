import 'package:flutter/material.dart';
import '../services/url_launcher_service.dart';

const _releasesUrl = 'https://github.com/davide3011/biteplan/releases/latest';

void showUpdateDialog(BuildContext context, String newVersion) {
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
