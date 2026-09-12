import 'dart:math' as math;

import 'package:flutter/material.dart';

enum MaringMood {
  neutral,
  joy,
  calm,
  sad,
  anxious,
  angry,
  empathy,
  thinking,
  tired
}

enum MaringGrowthStage { seed, sprout, bloom, companion, guardian }

extension MaringGrowthPresentation on MaringGrowthStage {
  String get asset => switch (this) {
        MaringGrowthStage.seed => 'assets/maring/growth/stage-1-seed.png',
        MaringGrowthStage.sprout => 'assets/maring/growth/stage-2-sprout.png',
        MaringGrowthStage.bloom => 'assets/maring/growth/stage-3-bloom.png',
        MaringGrowthStage.companion =>
          'assets/maring/growth/stage-4-companion.png',
        MaringGrowthStage.guardian =>
          'assets/maring/growth/stage-5-guardian.png',
      };

  String get label => switch (this) {
        MaringGrowthStage.seed => '구름 씨앗',
        MaringGrowthStage.sprout => '마음 새싹',
        MaringGrowthStage.bloom => '마음 몽글',
        MaringGrowthStage.companion => '마음 동행',
        MaringGrowthStage.guardian => '별빛 수호',
      };

  String get colorStory => switch (this) {
        MaringGrowthStage.seed => '진주빛 · 옅은 라일락',
        MaringGrowthStage.sprout => '블러시 핑크 · 연보라',
        MaringGrowthStage.bloom => '로즈 핑크 · 페리윙클',
        MaringGrowthStage.companion => '핑크 라일락 · 딥 바이올렛',
        MaringGrowthStage.guardian => '샴페인 골드 · 로즈 · 바이올렛',
      };

  String get description => switch (this) {
        MaringGrowthStage.seed => '아직 팔과 엔젤링이 없는 작은 구름 씨앗이에요.',
        MaringGrowthStage.sprout => '작은 손과 마음빛이 처음 나타나요.',
        MaringGrowthStage.bloom => '마음 문양이 또렷해지고 보랏빛이 깊어져요.',
        MaringGrowthStage.companion => '몸집과 마음빛이 충분히 자란 든든한 친구예요.',
        MaringGrowthStage.guardian => '금빛 엔젤링과 로즈 망토를 얻은 완성형이에요.',
      };

  int get requiredCheckins => switch (this) {
        MaringGrowthStage.seed => 0,
        MaringGrowthStage.sprout => 3,
        MaringGrowthStage.bloom => 7,
        MaringGrowthStage.companion => 14,
        MaringGrowthStage.guardian => 30,
      };

  int? get nextRequiredCheckins => switch (this) {
        MaringGrowthStage.seed => MaringGrowthStage.sprout.requiredCheckins,
        MaringGrowthStage.sprout => MaringGrowthStage.bloom.requiredCheckins,
        MaringGrowthStage.bloom => MaringGrowthStage.companion.requiredCheckins,
        MaringGrowthStage.companion =>
          MaringGrowthStage.guardian.requiredCheckins,
        MaringGrowthStage.guardian => null,
      };

  Color get glow => switch (this) {
        MaringGrowthStage.seed => const Color(0xFFECE8FF),
        MaringGrowthStage.sprout => const Color(0xFFFFE1F0),
        MaringGrowthStage.bloom => const Color(0xFFE3D8FF),
        MaringGrowthStage.companion => const Color(0xFFD5C8FF),
        MaringGrowthStage.guardian => const Color(0xFFFFDCA8),
      };

  static MaringGrowthStage forCheckinCount(int count) {
    if (count >= MaringGrowthStage.guardian.requiredCheckins) {
      return MaringGrowthStage.guardian;
    }
    if (count >= MaringGrowthStage.companion.requiredCheckins) {
      return MaringGrowthStage.companion;
    }
    if (count >= MaringGrowthStage.bloom.requiredCheckins) {
      return MaringGrowthStage.bloom;
    }
    if (count >= MaringGrowthStage.sprout.requiredCheckins) {
      return MaringGrowthStage.sprout;
    }
    return MaringGrowthStage.seed;
  }

  double progressFor(int checkinCount) {
    final next = nextRequiredCheckins;
    if (next == null) return 1;
    final span = next - requiredCheckins;
    return ((checkinCount - requiredCheckins) / span).clamp(0, 1);
  }

  int checkinsUntilNext(int checkinCount) {
    final next = nextRequiredCheckins;
    return next == null ? 0 : (next - checkinCount).clamp(0, next);
  }
}

extension MaringMoodPresentation on MaringMood {
  String get asset => 'assets/maring/$name.png';

  String get label => switch (this) {
        MaringMood.neutral => '반가워',
        MaringMood.joy => '기쁨',
        MaringMood.calm => '평온',
        MaringMood.sad => '슬픔',
        MaringMood.anxious => '불안',
        MaringMood.angry => '화남',
        MaringMood.empathy => '공감',
        MaringMood.thinking => '생각 중',
        MaringMood.tired => '지침',
      };

  Color get glow => switch (this) {
        MaringMood.joy => const Color(0xFFFFDEAE),
        MaringMood.sad => const Color(0xFFCBDEFF),
        MaringMood.anxious => const Color(0xFFBDEDE7),
        MaringMood.angry => const Color(0xFFFFCEE3),
        _ => const Color(0xFFE4D8FF),
      };

  static MaringMood forEmotion(String? key) => switch (key) {
        'joy' => MaringMood.joy,
        'calm' => MaringMood.calm,
        'sad' => MaringMood.sad,
        'anxious' => MaringMood.anxious,
        'angry' => MaringMood.angry,
        'lonely' => MaringMood.empathy,
        'confused' => MaringMood.thinking,
        'tired' => MaringMood.tired,
        _ => MaringMood.neutral,
      };
}

/// A transparent 2.5D sprite with restrained breathing and a soft stage glow.
/// Motion is disabled for accessibility, hidden tabs, and small static icons.
class MaringCharacter extends StatefulWidget {
  final MaringMood mood;
  final MaringGrowthStage? growthStage;
  final double size;
  final bool animate;
  final bool showGlow;
  final bool excludeSemantics;

  const MaringCharacter({
    super.key,
    this.mood = MaringMood.neutral,
    this.growthStage,
    this.size = 240,
    this.animate = true,
    this.showGlow = true,
    this.excludeSemantics = false,
  });

  @override
  State<MaringCharacter> createState() => _MaringCharacterState();
}

class _MaringCharacterState extends State<MaringCharacter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3600),
  );
  bool _moving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMotion();
  }

  @override
  void didUpdateWidget(MaringCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncMotion();
  }

  void _syncMotion() {
    _moving = widget.animate &&
        !MediaQuery.disableAnimationsOf(context) &&
        TickerMode.valuesOf(context).enabled;
    if (_moving && !_breath.isAnimating) {
      _breath.repeat();
    } else if (!_moving) {
      _breath.stop();
      _breath.value = 0;
    }
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final asset = widget.growthStage?.asset ?? widget.mood.asset;
    final label = widget.growthStage?.label ?? widget.mood.label;
    final glow = widget.growthStage?.glow ?? widget.mood.glow;
    final cacheDimension =
        (widget.size * MediaQuery.devicePixelRatioOf(context))
            .ceil()
            .clamp(64, 1024)
            .toInt();
    return Semantics(
      label: widget.excludeSemantics ? null : '마링이, $label',
      image: !widget.excludeSemantics,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: widget.size,
        child: RepaintBoundary(
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (widget.showGlow)
                AnimatedContainer(
                  duration: reducedMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 400),
                  width: widget.size * .92,
                  height: widget.size * .92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      glow.withValues(alpha: .55),
                      glow.withValues(alpha: 0),
                    ]),
                  ),
                ),
              AnimatedBuilder(
                animation: _breath,
                builder: (context, child) {
                  final wave =
                      _moving ? math.sin(_breath.value * math.pi * 2) : 0.0;
                  return Transform.translate(
                    offset: Offset(0, wave * widget.size * .012),
                    child:
                        Transform.scale(scale: .94 + wave * .008, child: child),
                  );
                },
                child: AnimatedSwitcher(
                  duration: reducedMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 320),
                  child: Image.asset(
                    asset,
                    key: ValueKey(asset),
                    width: widget.size,
                    height: widget.size,
                    cacheWidth: cacheDimension,
                    cacheHeight: cacheDimension,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.medium,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
