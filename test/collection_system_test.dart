import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diggle/game/systems/collection_system.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('catalog covers all four biomes with 5 artifacts each', () {
    for (final biome in [
      'Topsoil',
      'Permafrost',
      'Crystal Caverns',
      'Magma Core'
    ]) {
      expect(CollectionSystem.catalogForBiome(biome).length, 5,
          reason: '$biome should have 5 artifacts');
    }
    expect(CollectionSystem.catalog.length, 20);
  });

  test('resolveArtifact is deterministic and biome-scoped', () async {
    final system = CollectionSystem();
    await system.initialize();

    final a = system.resolveArtifact(10, 200, 150, 42);
    final b = system.resolveArtifact(10, 200, 150, 42);
    expect(a.id, b.id);
    expect(a.biomeName, 'Permafrost'); // depth 150 → Permafrost

    final deep = system.resolveArtifact(10, 200, 400, 42);
    expect(deep.biomeName, 'Magma Core');
  });

  test('collect awards new finds once and duplicates as consolation',
      () async {
    final system = CollectionSystem();
    await system.initialize();

    final rewards = <String>[];
    system.onAwardReward = (xp, points, desc) => rewards.add(desc);

    final first = system.collect(10, 200, 150, 42);
    expect(first.isNew, true);
    expect(system.foundCount, 1);
    // New finds are awarded by the caller, not the callback
    expect(rewards, isEmpty);

    final dup = system.collect(10, 200, 150, 42);
    expect(dup.isNew, false);
    expect(system.foundCount, 1);
    expect(rewards.length, 1);
    expect(rewards.first, contains('Duplicate'));
  });

  test('completing a biome set fires the set bonus', () async {
    final system = CollectionSystem();
    await system.initialize();

    final rewards = <String>[];
    system.onAwardReward = (xp, points, desc) => rewards.add(desc);

    // Find coordinates that resolve to each Topsoil artifact
    final needed = CollectionSystem.catalogForBiome('Topsoil')
        .map((a) => a.id)
        .toSet();
    int x = 0;
    while (needed.isNotEmpty && x < 10000) {
      final artifact = system.resolveArtifact(x, 50, 10, 42);
      if (needed.contains(artifact.id)) {
        needed.remove(artifact.id);
        system.collect(x, 50, 10, 42);
      }
      x++;
    }

    expect(needed, isEmpty, reason: 'could not resolve all Topsoil artifacts');
    expect(system.isSetComplete('Topsoil'), true);
    expect(rewards.any((r) => r.contains('collection complete')), true);
  });

  test('found artifacts persist across instances', () async {
    final system = CollectionSystem();
    await system.initialize();
    final result = system.collect(10, 200, 150, 42);

    final reloaded = CollectionSystem();
    await reloaded.initialize();
    expect(reloaded.isFound(result.artifact.id), true);
  });
}
