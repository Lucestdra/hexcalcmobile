import 'dart:math' as math;
import 'dart:ui';

import '../../../core/design_system/app_colors.dart';

/// A single pooled particle. Reused in place — never allocated per spawn — so a
/// long run does not churn the heap (see the "unbounded particles" prohibition).
class _Particle {
  double x = 0;
  double y = 0;
  double vx = 0;
  double vy = 0;
  double life = 0;
  double maxLife = 1;
  double size = 2;
  Color color = AppColors.primaryText;
  bool active = false;
}

/// An expanding ring (energy wave) or a soft filled pop.
class _Wave {
  _Wave(
    this.center,
    this.color,
    this.maxRadius,
    this.maxLife, {
    this.filled = false,
  });

  final Offset center;
  final Color color;
  final double maxRadius;
  final double maxLife;
  final bool filled;
  double life = 0;
}

/// Owns all transient gameplay visuals: a fixed particle pool, expanding waves,
/// and a decaying screen shake. Purely additive over the board render; the board
/// game asks it to [update] each frame, applies [shakeOffset], then [render]s it.
///
/// Deterministic RNG (fixed seed) so particle spread is reproducible in tests and
/// never depends on wall-clock entropy.
class EffectsLayer {
  EffectsLayer({this.maxParticles = 120})
    : _pool = List<_Particle>.generate(
        maxParticles,
        (_) => _Particle(),
        growable: false,
      );

  final int maxParticles;
  final List<_Particle> _pool;
  final List<_Wave> _waves = <_Wave>[];
  final math.Random _rng = math.Random(0x0FED);

  double _shakeTime = 0;
  double _shakeDuration = 0;
  double _shakeMag = 0;
  double _shakeX = 0;
  double _shakeY = 0;

  bool get hasActiveEffects =>
      _waves.isNotEmpty || _shakeTime > 0 || _pool.any((p) => p.active);

  int get activeParticleCount => _pool.where((_Particle p) => p.active).length;

  /// The current frame's shake translation (zero when not shaking).
  Offset get shakeOffset => Offset(_shakeX, _shakeY);

  /// Spawns up to [count] particles bursting outward from [center]. Capped by the
  /// pool size, so requesting more than is free simply fills what remains.
  void burst(Offset center, Color color, int count, {double speed = 90}) {
    int spawned = 0;
    for (final _Particle p in _pool) {
      if (spawned >= count) {
        break;
      }
      if (p.active) {
        continue;
      }
      final double angle = _rng.nextDouble() * math.pi * 2;
      final double v = speed * (0.4 + _rng.nextDouble() * 0.8);
      p
        ..x = center.dx
        ..y = center.dy
        ..vx = math.cos(angle) * v
        ..vy = math.sin(angle) * v
        ..life = 0
        ..maxLife = 0.45 + _rng.nextDouble() * 0.35
        ..size = 2 + _rng.nextDouble() * 2.5
        ..color = color
        ..active = true;
      spawned++;
    }
  }

  /// An expanding ring emanating from [center].
  void wave(Offset center, Color color, {double maxRadius = 90}) {
    _waves.add(_Wave(center, color, maxRadius, 0.5));
  }

  /// A soft filled pop (used for the result cell on a correct equation).
  void pop(Offset center, Color color, {double maxRadius = 46}) {
    _waves.add(_Wave(center, color, maxRadius, 0.34, filled: true));
  }

  /// Starts (or refreshes) a decaying screen shake.
  void shake(double magnitude, double durationSec) {
    _shakeMag = magnitude;
    _shakeDuration = durationSec;
    _shakeTime = durationSec;
  }

  /// Clears every effect immediately (e.g. on pause or level swap).
  void clear() {
    for (final _Particle p in _pool) {
      p.active = false;
    }
    _waves.clear();
    _shakeTime = 0;
    _shakeX = 0;
    _shakeY = 0;
  }

  void update(double dt) {
    // Particles: integrate, apply gentle drag + gravity, retire when spent.
    for (final _Particle p in _pool) {
      if (!p.active) {
        continue;
      }
      p.life += dt;
      if (p.life >= p.maxLife) {
        p.active = false;
        continue;
      }
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.vx *= 1 - (2.2 * dt); // drag
      p.vy = p.vy * (1 - (2.2 * dt)) + 60 * dt; // drag + slight gravity
    }

    // Waves: advance life, drop finished ones (iterate backwards for removal).
    for (int i = _waves.length - 1; i >= 0; i--) {
      _waves[i].life += dt;
      if (_waves[i].life >= _waves[i].maxLife) {
        _waves.removeAt(i);
      }
    }

    // Shake: decay toward zero and jitter within the remaining magnitude.
    if (_shakeTime > 0) {
      _shakeTime -= dt;
      if (_shakeTime <= 0 || _shakeDuration <= 0) {
        _shakeTime = 0;
        _shakeX = 0;
        _shakeY = 0;
      } else {
        final double amt = _shakeMag * (_shakeTime / _shakeDuration);
        _shakeX = (_rng.nextDouble() * 2 - 1) * amt;
        _shakeY = (_rng.nextDouble() * 2 - 1) * amt;
      }
    }
  }

  void render(Canvas canvas) {
    // Waves under particles.
    for (final _Wave w in _waves) {
      final double t = (w.life / w.maxLife).clamp(0.0, 1.0);
      final double radius = w.maxRadius * (w.filled ? _easeOut(t) : t);
      final double alpha = (1 - t) * (w.filled ? 0.5 : 0.7);
      final Paint paint = Paint()
        ..color = w.color.withValues(alpha: alpha)
        ..style = w.filled ? PaintingStyle.fill : PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(w.center, radius, paint);
    }

    for (final _Particle p in _pool) {
      if (!p.active) {
        continue;
      }
      final double t = (p.life / p.maxLife).clamp(0.0, 1.0);
      final Paint paint = Paint()..color = p.color.withValues(alpha: 1 - t);
      canvas.drawCircle(Offset(p.x, p.y), p.size * (1 - t * 0.5), paint);
    }
  }
}

/// A tiny ease-out used for the filled pop growth (avoids importing the widgets
/// animation library into a pure-render file).
double _easeOut(double t) => 1 - (1 - t) * (1 - t);
