import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semarewards/features/video_clipping/presentation/widgets/trim_range_strip.dart';

void main() {
  // Mirrors IMG_6260.MOV: 12.03s, 1280x720.
  const duration = Duration(milliseconds: 12033);

  Future<({List<(Duration, Duration)> changes, List<Duration> scrubs})> pump(
    WidgetTester tester, {
    Duration start = Duration.zero,
    Duration end = duration,
  }) async {
    final changes = <(Duration, Duration)>[];
    final scrubs = <Duration>[];
    var s = start;
    var e = end;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              child: StatefulBuilder(
                builder: (context, setState) => TrimRangeStrip(
                  videoDuration: duration,
                  start: s,
                  end: e,
                  playhead: s,
                  onChanged: (r) {
                    changes.add(r);
                    setState(() {
                      s = r.$1;
                      e = r.$2;
                    });
                  },
                  onScrub: scrubs.add,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return (changes: changes, scrubs: scrubs);
  }

  testWidgets('dragging the start handle trims the start and scrubs to it', (tester) async {
    final r = await pump(tester);
    final handle = tester.getCenter(find.byType(TrimRangeStrip)) - const Offset(200 - 9, 0);
    final gesture = await tester.startGesture(handle);
    for (var i = 0; i < 10; i++) {
      await gesture.moveBy(const Offset(10, 0));
      await tester.pump();
    }
    await gesture.up();

    expect(r.changes, isNotEmpty);
    expect(r.changes.last.$1, greaterThan(Duration.zero));
    expect(r.changes.last.$2, duration);
    expect(r.scrubs.last, r.changes.last.$1);
    // Monotonic: no jitter while moving one direction.
    for (var i = 1; i < r.changes.length; i++) {
      expect(r.changes[i].$1, greaterThanOrEqualTo(r.changes[i - 1].$1));
    }
  });

  testWidgets('overshooting then reversing does not lose travel (no drift)', (tester) async {
    final r = await pump(tester, start: const Duration(seconds: 2), end: const Duration(seconds: 6));
    final strip = tester.getTopLeft(find.byType(TrimRangeStrip));
    const track = 400 - 36.0;
    final endX = strip.dx + 18 + 6000 / 12033 * track + 8;
    final gesture = await tester.startGesture(Offset(endX, strip.dy + 28));
    await gesture.moveBy(const Offset(2000, 0)); // far past the end
    await tester.pump();
    expect(r.changes.last.$2, duration);
    await gesture.moveBy(const Offset(-2000, 0)); // back to exactly where it began
    await tester.pump();
    await gesture.up();
    expect(r.changes.last.$2.inMilliseconds, closeTo(6000, 5));
  });

  testWidgets('dragging the range keeps its length', (tester) async {
    final r = await pump(tester, start: const Duration(seconds: 1), end: const Duration(seconds: 4));
    final strip = tester.getTopLeft(find.byType(TrimRangeStrip));
    const track = 400 - 36.0;
    final midX = strip.dx + 18 + 2500 / 12033 * track;
    final gesture = await tester.startGesture(Offset(midX, strip.dy + 28));
    await gesture.moveBy(const Offset(60, 0));
    await tester.pump();
    await gesture.up();
    final last = r.changes.last;
    expect((last.$2 - last.$1).inMilliseconds, 3000);
    expect(last.$1, greaterThan(const Duration(seconds: 1)));
  });
}
