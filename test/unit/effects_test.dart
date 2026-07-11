import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/features/gameplay/flame/effects.dart';

const Color _c = Color(0xFF00BDF2);

void main() {
  test('burst never exceeds the pool size', () {
    final EffectsLayer fx = EffectsLayer(maxParticles: 4);
    fx.burst(const Offset(10, 10), _c, 100);
    expect(fx.activeParticleCount, 4);
  });

  test('particles retire after their lifetime', () {
    final EffectsLayer fx = EffectsLayer(maxParticles: 8);
    fx.burst(const Offset(0, 0), _c, 8);
    expect(fx.activeParticleCount, 8);
    // Advance well past the maximum particle lifetime (~0.8s).
    for (int i = 0; i < 60; i++) {
      fx.update(0.02);
    }
    expect(fx.activeParticleCount, 0);
  });

  test('a wave lives then clears', () {
    final EffectsLayer fx = EffectsLayer();
    fx.wave(const Offset(5, 5), _c);
    expect(fx.hasActiveEffects, isTrue);
    for (int i = 0; i < 40; i++) {
      fx.update(0.02);
    }
    expect(fx.hasActiveEffects, isFalse);
  });

  test('shake jitters then decays to exactly zero', () {
    final EffectsLayer fx = EffectsLayer();
    fx.shake(10, 0.2);
    fx.update(0.05);
    expect(fx.shakeOffset, isNot(Offset.zero));
    // Past the shake duration it returns precisely to rest.
    fx.update(0.25);
    expect(fx.shakeOffset, Offset.zero);
  });

  test('clear cancels every active effect', () {
    final EffectsLayer fx = EffectsLayer(maxParticles: 8);
    fx.burst(const Offset(0, 0), _c, 8);
    fx.wave(const Offset(0, 0), _c);
    fx.shake(8, 0.4);
    fx.clear();
    expect(fx.hasActiveEffects, isFalse);
    expect(fx.shakeOffset, Offset.zero);
  });
}
