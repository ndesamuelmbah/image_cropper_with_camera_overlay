import 'package:flutter/material.dart';
import 'package:image_cropper_with_camera_overlay/card_overlay.dart';

class OverlayShape extends StatelessWidget {
  const OverlayShape(this.cardOverlay, this.overlayKey, {Key? key})
      : super(key: key);

  final GlobalKey overlayKey;
  final CardOverlay cardOverlay;

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context);
    var size = media.size;
    double width = media.orientation == Orientation.portrait
        ? size.shortestSide * .9 * cardOverlay.widthFraction
        : size.longestSide * .5 * cardOverlay.widthFraction;
    double ratio = cardOverlay.ratio;
    double radius = cardOverlay.cornerRadius;
    if (media.orientation == Orientation.portrait) {}
    return Stack(
      children: [
        Align(
            alignment: Alignment.center,
            child: Container(
              key: overlayKey,
              width: width,
              height: width / ratio,
              decoration: ShapeDecoration(
                  color: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(radius),
                      side: const BorderSide(width: 1, color: Colors.white))),
            )),
        ColorFiltered(
          colorFilter: const ColorFilter.mode(Colors.black54, BlendMode.srcOut),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: width,
                    height: width / ratio,
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(radius)),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
