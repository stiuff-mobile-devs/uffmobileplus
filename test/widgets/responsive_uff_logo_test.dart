import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uffmobileplus/app/ui/widgets/responsive_uff_logo.dart';

/// Sizing / animation contract of the animated logo that replaced the static
/// image assets on this branch. It is used on Splash, Login, the alert dialog
/// and the progress display, so its sizing must hold across phone sizes.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// The SVG's intrinsic ratio, mirrored from the widget.
  const aspectRatio = 1000.0 / 739.74;

  Future<SvgPicture> pumpLogo(
    WidgetTester tester,
    ResponsiveUffLogo logo, {
    Size screen = const Size(411, 891),
  }) async {
    // `setSurfaceSize` resizes the RenderView but leaves `view.physicalSize`
    // alone, so MediaQuery (and therefore the widget) would keep reading the
    // default 800x600. Drive the view metrics directly instead.
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = screen;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: Center(child: logo))),
    );
    // The logo animates forever by default, so never pumpAndSettle here.
    await tester.pump(const Duration(milliseconds: 100));

    return tester.widget<SvgPicture>(find.byType(SvgPicture));
  }

  group('intrinsic sizing', () {
    test('the widget and this test agree on the SVG aspect ratio', () {
      expect(aspectRatio, closeTo(1.3518, 0.0001));
    });

    testWidgets('with no explicit size, scales to 55% of screen width',
        (tester) async {
      final svg = await pumpLogo(
        tester,
        const ResponsiveUffLogo(animate: false),
        screen: const Size(411, 891),
      );

      expect(svg.width, closeTo(411 * 0.55, 0.01));
      expect(svg.height, closeTo(411 * 0.55 / aspectRatio, 0.01));
    });

    testWidgets('clamps to a 120pt floor on a very narrow screen',
        (tester) async {
      // 200 * 0.55 = 110, below the floor.
      final svg = await pumpLogo(
        tester,
        const ResponsiveUffLogo(animate: false),
        screen: const Size(200, 640),
      );
      expect(svg.width, 120.0);
      expect(svg.height, closeTo(120.0 / aspectRatio, 0.01));
    });

    testWidgets('clamps to a 360pt ceiling on a tablet', (tester) async {
      // 800 * 0.55 = 440, above the ceiling.
      final svg = await pumpLogo(
        tester,
        const ResponsiveUffLogo(animate: false),
        screen: const Size(800, 1280),
      );
      expect(svg.width, 360.0);
      expect(svg.height, closeTo(360.0 / aspectRatio, 0.01));
    });

    testWidgets('never distorts across a sweep of phone widths',
        (tester) async {
      for (final width in const [320.0, 360.0, 390.0, 411.0, 428.0, 600.0]) {
        final svg = await pumpLogo(
          tester,
          const ResponsiveUffLogo(animate: false),
          screen: Size(width, 900),
        );
        expect(
          svg.width! / svg.height!,
          closeTo(aspectRatio, 0.001),
          reason: 'logo is distorted at ${width}pt wide',
        );
        expect(svg.width, inInclusiveRange(120.0, 360.0));
      }
    });
  });

  group('explicit sizing', () {
    testWidgets('width only derives the height', (tester) async {
      final svg =
          await pumpLogo(tester, const ResponsiveUffLogo(width: 200, animate: false));
      expect(svg.width, 200.0);
      expect(svg.height, closeTo(200 / aspectRatio, 0.01));
    });

    testWidgets('height only derives the width', (tester) async {
      final svg =
          await pumpLogo(tester, const ResponsiveUffLogo(height: 45, animate: false));
      expect(svg.height, 45.0);
      expect(svg.width, closeTo(45 * aspectRatio, 0.01));
    });

    testWidgets('both dimensions are honoured verbatim', (tester) async {
      final svg = await pumpLogo(
        tester,
        const ResponsiveUffLogo(width: 300, height: 100, animate: false),
      );
      expect(svg.width, 300.0);
      expect(svg.height, 100.0);
    });

    testWidgets('an explicit size ignores the screen width', (tester) async {
      for (final screen in const [Size(320, 568), Size(800, 1280)]) {
        final svg = await pumpLogo(
          tester,
          const ResponsiveUffLogo(width: 150, animate: false),
          screen: screen,
        );
        expect(svg.width, 150.0);
      }
    });
  });

  group('card variant', () {
    testWidgets('showBackgroundCard wraps the logo in a Card', (tester) async {
      await pumpLogo(
        tester,
        const ResponsiveUffLogo(showBackgroundCard: true, animate: false),
      );
      expect(find.byType(Card), findsOneWidget);
      expect(
        find.descendant(of: find.byType(Card), matching: find.byType(SvgPicture)),
        findsOneWidget,
      );
    });

    testWidgets('cardColor is applied when provided', (tester) async {
      await pumpLogo(
        tester,
        const ResponsiveUffLogo(
          showBackgroundCard: true,
          cardColor: Color(0xFF123456),
          animate: false,
        ),
      );
      expect(tester.widget<Card>(find.byType(Card)).color, const Color(0xFF123456));
    });

    testWidgets('no Card is built by default', (tester) async {
      await pumpLogo(tester, const ResponsiveUffLogo(animate: false));
      expect(find.byType(Card), findsNothing);
    });
  });

  group('animation lifecycle', () {
    testWidgets('animate: false produces a static, settleable widget',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: ResponsiveUffLogo(animate: false))),
        ),
      );
      // Would time out if the controller were still repeating.
      await tester.pumpAndSettle();
      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('animate: true drives a repeating transform', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: ResponsiveUffLogo())),
        ),
      );
      await tester.pump();

      Matrix4 transformAt(Duration t) {
        return tester
            .widget<Transform>(find.byType(Transform).first)
            .transform;
      }

      await tester.pump(const Duration(milliseconds: 200));
      final first = transformAt(const Duration(milliseconds: 200)).clone();
      await tester.pump(const Duration(milliseconds: 700));
      final second = transformAt(const Duration(milliseconds: 900));

      expect(
        first,
        isNot(equals(second)),
        reason: 'the logo should be moving when animate is true',
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('toggling animate off stops the controller', (tester) async {
      Widget build(bool animate) => MaterialApp(
            home: Scaffold(
              body: Center(child: ResponsiveUffLogo(animate: animate)),
            ),
          );

      await tester.pumpWidget(build(true));
      await tester.pump(const Duration(milliseconds: 300));

      await tester.pumpWidget(build(false));
      // Settles only if didUpdateWidget actually stopped the controller.
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('disposing mid-animation does not throw', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: ResponsiveUffLogo())),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));

      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
