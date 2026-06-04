import 'package:flutter_test/flutter_test.dart';
import 'package:biteplan/shared/services/update_service.dart';

void main() {
  group('UpdateService.parseVersion', () {
    test('parses standard semver', () {
      expect(UpdateService.parseVersion('2.1.3'), [2, 1, 3]);
    });

    test('pads missing parts with zeros', () {
      expect(UpdateService.parseVersion('2.1'), [2, 1, 0]);
      expect(UpdateService.parseVersion('2'), [2, 0, 0]);
    });

    test('handles non-numeric parts as zero', () {
      expect(UpdateService.parseVersion('2.x.3'), [2, 0, 3]);
    });
  });

  group('UpdateService.isNewer', () {
    test('patch bump is newer', () {
      expect(UpdateService.isNewer('2.0.1', '2.0.0'), isTrue);
    });

    test('minor bump is newer', () {
      expect(UpdateService.isNewer('2.1.0', '2.0.9'), isTrue);
    });

    test('major bump is newer', () {
      expect(UpdateService.isNewer('3.0.0', '2.9.9'), isTrue);
    });

    test('same version is not newer', () {
      expect(UpdateService.isNewer('2.0.0', '2.0.0'), isFalse);
    });

    test('older remote is not newer', () {
      expect(UpdateService.isNewer('1.9.9', '2.0.0'), isFalse);
    });

    test('remote with v-prefix stripped is handled correctly', () {
      // tag_name comes in already stripped of 'v' by checkUpdate
      expect(UpdateService.isNewer('2.0.1', '2.0.0'), isTrue);
    });

    test('multi-digit version components', () {
      expect(UpdateService.isNewer('2.0.10', '2.0.9'), isTrue);
      expect(UpdateService.isNewer('2.10.0', '2.9.0'), isTrue);
    });
  });
}
