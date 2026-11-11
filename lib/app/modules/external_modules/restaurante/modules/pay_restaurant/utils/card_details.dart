import 'package:flutter/material.dart';

/// Cartão de identificação do pagamento do RU.
///
/// É desenhado no tamanho base ([baseWidth] x [baseHeight]) e escalado por
/// inteiro, mantendo a proporção. Passe [width] ou [height] para encolher
/// (ex.: versão compacta no ticket); sem nenhum dos dois, usa o tamanho base.
class IdCard extends StatelessWidget {
  static const double baseWidth = 340;
  static const double baseHeight = 210;

  final String userImageUrl;
  final String username;
  final String iduff;
  final double? width;
  final double? height;

  const IdCard({
    super.key,
    required this.userImageUrl,
    required this.username,
    required this.iduff,
    this.width,
    this.height,
  });

  void _openPhoto(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.9),
        pageBuilder: (_, _, _) => _PhotoViewer(imageUrl: userImageUrl),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double scale = 1;
    if (width != null) scale = width! / baseWidth;
    if (height != null) scale = height! / baseHeight;
    if (scale <= 0 || scale.isNaN) scale = 1;

    return SizedBox(
      width: baseWidth * scale,
      height: baseHeight * scale,
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: baseWidth,
          height: baseHeight,
          child: _card(context),
        ),
      ),
    );
  }

  Widget _card(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[900],
        image: const DecorationImage(
          image: AssetImage("assets/restaurant/img/studentid_background.png"),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  "assets/restaurant/img/uff_logo.png",
                  color: Colors.white,
                  height: 30,
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => _openPhoto(context),
                        child: Container(
                          height: 90,
                          width: 90,
                          padding: const EdgeInsets.all(3.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.network(
                              userImageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  "assets/images/user_placeholder.jpg",
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              width: 190,
                              height: 66,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: SizedBox(
                                  width: 190,
                                  child: Text(
                                    username.toUpperCase(),
                                    softWrap: true,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                      height: 1.2,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black54,
                                          blurRadius: 2,
                                          offset: Offset(1, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                iduff,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Foto em tela cheia, já abrindo com zoom 2x no centro.
class _PhotoViewer extends StatefulWidget {
  final String imageUrl;

  const _PhotoViewer({required this.imageUrl});

  @override
  State<_PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<_PhotoViewer> {
  static const double _initialScale = 2;

  final TransformationController _transform = TransformationController();
  Size? _lastSize;

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  /// Zoom inicial centrado na área visível.
  void _applyInitialZoom(Size size) {
    if (_lastSize == size) return;
    _lastSize = size;
    final dx = -size.width * (_initialScale - 1) / 2;
    final dy = -size.height * (_initialScale - 1) / 2;
    _transform.value = Matrix4.identity()
      ..translateByDouble(dx, dy, 0, 1)
      ..scaleByDouble(_initialScale, _initialScale, 1, 1);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                _applyInitialZoom(constraints.biggest);
                return InteractiveViewer(
                  transformationController: _transform,
                  minScale: 1,
                  maxScale: 5,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: Image.network(
                      widget.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.white,
                          size: 100,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.close, color: Colors.white, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
