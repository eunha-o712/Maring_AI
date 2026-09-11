import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:maring_app/main.dart';
import 'package:maring_app/models/chat_models.dart';
import 'package:maring_app/screens/character_gallery_screen.dart';
import 'package:maring_app/screens/growth_journey_screen.dart';
import 'package:maring_app/widgets/maring_character.dart';
import 'package:maring_app/widgets/safety_overlay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('all expression assets decode with transparent outer corners', () async {
    for (final mood in MaringMood.values) {
      final data = await rootBundle.load(mood.asset);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      final pixels =
          await frame.image.toByteData(format: ui.ImageByteFormat.rawRgba);
      expect(frame.image.width, greaterThanOrEqualTo(1000), reason: mood.name);
      expect(pixels, isNotNull);
      final width = frame.image.width;
      final height = frame.image.height;
      for (final index in [
        3,
        (width - 1) * 4 + 3,
        (height - 1) * width * 4 + 3,
        width * height * 4 - 1
      ]) {
        expect(pixels!.getUint8(index), 0,
            reason: '${mood.name}: corner alpha');
      }
      frame.image.dispose();
      codec.dispose();
    }
  });

  test('growth assets are transparent and become visibly larger', () async {
    final visibleHeights = <int>[];
    for (final stage in MaringGrowthStage.values) {
      final data = await rootBundle.load(stage.asset);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      final pixels =
          await frame.image.toByteData(format: ui.ImageByteFormat.rawRgba);
      expect(frame.image.width, 1024, reason: stage.name);
      expect(frame.image.height, 1024, reason: stage.name);
      expect(pixels, isNotNull);

      var minY = frame.image.height;
      var maxY = -1;
      for (var y = 0; y < frame.image.height; y++) {
        for (var x = 0; x < frame.image.width; x++) {
          final alphaIndex = (y * frame.image.width + x) * 4 + 3;
          if (pixels!.getUint8(alphaIndex) > 8) {
            if (y < minY) minY = y;
            if (y > maxY) maxY = y;
          }
        }
      }

      expect(pixels!.getUint8(3), 0, reason: '${stage.name}: corner alpha');
      visibleHeights.add(maxY - minY + 1);
      frame.image.dispose();
      codec.dispose();
    }

    for (var i = 1; i < visibleHeights.length; i++) {
      expect(
        visibleHeights[i],
        greaterThan(visibleHeights[i - 1]),
        reason: '${MaringGrowthStage.values[i].name} visible height',
      );
    }
  });

  test('check-in days map to all five growth thresholds', () {
    expect(
      MaringGrowthPresentation.forCheckinCount(0),
      MaringGrowthStage.seed,
    );
    expect(
      MaringGrowthPresentation.forCheckinCount(3),
      MaringGrowthStage.sprout,
    );
    expect(
      MaringGrowthPresentation.forCheckinCount(7),
      MaringGrowthStage.bloom,
    );
    expect(
      MaringGrowthPresentation.forCheckinCount(14),
      MaringGrowthStage.companion,
    );
    expect(
      MaringGrowthPresentation.forCheckinCount(30),
      MaringGrowthStage.guardian,
    );
  });

  testWidgets('fresh session shows usable onboarding on a small phone',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
      home: const SessionGate(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: child!,
      ),
    )));
    await tester.pumpAndSettle();
    expect(find.text('안녕, 나는 마링이야'), findsOneWidget);
    expect(find.byType(MaringCharacter), findsOneWidget);
    await tester.ensureVisible(find.text('시작하기'));
    await tester.tap(find.text('시작하기'));
    await tester.pumpAndSettle();
    expect(find.text('닉네임을 입력해줘.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('gallery switches the hero expression with reduced motion',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: const CharacterGalleryScreen(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: child!,
      ),
    ));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('슬픔'), 180);
    await tester.pumpAndSettle();
    await tester.tap(find.text('슬픔'));
    await tester.pumpAndSettle();
    final characters =
        tester.widgetList<MaringCharacter>(find.byType(MaringCharacter));
    expect(characters.first.mood, MaringMood.sad);
    expect(tester.binding.transientCallbackCount, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('growth journey highlights the stage for accumulated check-ins',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: const GrowthJourneyScreen(checkinCount: 14),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: child!,
      ),
    ));
    await tester.pumpAndSettle();

    final hero = tester.widget<MaringCharacter>(
      find.byType(MaringCharacter).first,
    );
    expect(hero.growthStage, MaringGrowthStage.companion);
    expect(find.text('마음 동행'), findsOneWidget);
    expect(find.text('다음 성장까지 16일'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('small character requests a device-sized decoded image',
      (tester) async {
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(
      home: MaringCharacter(
        mood: MaringMood.sad,
        size: 30,
        animate: false,
        showGlow: false,
      ),
    ));

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<ResizeImage>());
    final resized = image.image as ResizeImage;
    expect(resized.width, 90);
    expect(resized.height, 90);
  });

  testWidgets('safety overlay renders every crisis resource as a call action',
      (tester) async {
    const response = ChatResponse(
      reply: '안전 안내',
      riskLevel: 'HIGH',
      safetyTriggered: true,
      crisisResources: [
        CrisisResource(name: '자살예방상담전화', number: '109', hours: '24시간'),
        CrisisResource(
          name: '정신건강상담전화',
          number: '1577-0199',
          hours: '24시간',
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => FilledButton(
            onPressed: () => showSafetyOverlay(context, response),
            child: const Text('안전 안내 열기'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('안전 안내 열기'));
    await tester.pumpAndSettle();

    expect(find.text('지금 많이 힘드시군요'), findsOneWidget);
    expect(find.text('자살예방상담전화'), findsOneWidget);
    expect(find.text('109 · 24시간'), findsOneWidget);
    expect(find.text('정신건강상담전화'), findsOneWidget);
    expect(find.byIcon(Icons.call_outlined), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}
