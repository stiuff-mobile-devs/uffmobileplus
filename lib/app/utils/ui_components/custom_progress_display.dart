import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;
import 'package:uffmobileplus/app/utils/color_pallete.dart';

class CustomProgressDisplay extends StatefulWidget {
  const CustomProgressDisplay({
    super.key,
    this.height = 50.0,
    this.brightMode = false,
  });

  final double height;
  final bool brightMode;

  @override
  State<CustomProgressDisplay> createState() => _CustomProgressDisplayState();
}

class _CustomProgressDisplayState extends State<CustomProgressDisplay> {
  late Future<rive.File> _fileFuture;
  late final _LoopingAnimationPainter _painter;

  @override
  void initState() {
    super.initState();
    _fileFuture = _loadFile(_assetPath());
    _painter = _LoopingAnimationPainter(
      'Animation 1',
      fit: rive.Fit.contain,
      alignment: Alignment.center,
    );
  }

  @override
  void didUpdateWidget(covariant CustomProgressDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.brightMode != widget.brightMode) {
      _fileFuture = _loadFile(_assetPath());
    }
  }

  String _assetPath() {
    return widget.brightMode
        ? 'assets/animations/logo_uff_animado_white.riv'
        : 'assets/animations/logo_uff_animado.riv';
  }

  Future<rive.File> _loadFile(String asset) async {
    final file = await rive.File.asset(
      asset,
      riveFactory: rive.Factory.flutter,
    );
    if (file == null) {
      throw Exception('Failed to load Rive asset: $asset');
    }
    return file;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: AppColors.darkBlueToBlackGradient()),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SizedBox(
            height: widget.height,
            child: FutureBuilder<rive.File>(
              future: _fileFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  );
                }

                final file = snapshot.data;
                if (file == null) return const SizedBox.shrink();

                final artboard = file.artboardAt(0);
                if (artboard == null) {
                  return const SizedBox.shrink();
                }

                return rive.RiveArtboardWidget(
                  artboard: artboard,
                  painter: _painter,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

base class _LoopingAnimationPainter extends rive.BasicArtboardPainter {
  _LoopingAnimationPainter(
    this.animationName, {
    super.fit,
    super.alignment,
  });

  final String animationName;
  rive.Animation? _animation;

  @override
  void artboardChanged(rive.Artboard artboard) {
    super.artboardChanged(artboard);
    _animation?.dispose();
    _animation = artboard.animationNamed(animationName);
    _animation?.time = 0;
    _animation?.apply();
    notifyListeners();
  }

  @override
  bool advance(double elapsedSeconds) {
    final animation = _animation;
    if (animation == null) return false;

    final playing = animation.advanceAndApply(elapsedSeconds);
    if (!playing) {
      animation.time = 0;
      animation.apply();
      return true;
    }
    return true;
  }

  @override
  void dispose() {
    _animation?.dispose();
    super.dispose();
  }
}
