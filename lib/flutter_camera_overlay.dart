import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper_with_camera_overlay/card_overlay.dart';
//import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper_with_camera_overlay/overlay_shape.dart';

typedef XFileCallback = void Function(XFile file);

class CameraOverlay extends StatefulWidget {
  const CameraOverlay(
    this.cardOverlay,
    this.resolution,
    this.onCapture, {
    Key? key,
    this.onVideoCapture, // = null,
    this.flash = false,
    this.enableCaptureButton = true,
    this.label = '',
    this.info = '',
    this.loadingWidget,
    this.infoMargin,
    this.takePictureWidget,
    this.controlOptionsBuilder,
    required this.cameras,
    required this.applicationDocumentsDirectoryPath,
    this.useFullScreen = true,
  }) : super(key: key);
  final CardOverlay cardOverlay;
  final bool flash;
  final bool enableCaptureButton;
  final XFileCallback onCapture;
  final XFileCallback? onVideoCapture;
  final Widget? Function(List<CameraDescription>, CameraController)?
      controlOptionsBuilder;
  final String label;
  final String info;
  final Widget? loadingWidget;
  final EdgeInsets? infoMargin;
  final ResolutionPreset resolution;
  final Widget? takePictureWidget;
  final List<CameraDescription> cameras;
  final bool useFullScreen;
  final String applicationDocumentsDirectoryPath;

  @override
  _FlutterCameraOverlayState createState() => _FlutterCameraOverlayState();
}

class _FlutterCameraOverlayState extends State<CameraOverlay> {
  _FlutterCameraOverlayState();
  bool showFlash = false;
  int numberOfCameras = 0;
  bool isTakingVideo = false;
  late CameraController controller;
  late CameraDescription currentCamera;
  bool isProcessingImage = false;
  static final GlobalKey downloadObjectKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    showFlash = widget.flash;
    currentCamera = widget.cameras.first;
    controller = CameraController(
      currentCamera,
      widget.resolution,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });

    // didChangeAppLifecycleState(AppLifecycleState.detached);
  }

  @override
  void dispose() {
    WidgetsFlutterBinding.ensureInitialized();
    controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // App state changed before we got the chance to initialize.
    if (!controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(controller.description);
    }
  }

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    final CameraController oldController = controller;
    if (oldController != null) {
      // `controller` needs to be set to null before getting disposed,
      // to avoid a race condition when we use the controller that is being
      // disposed. This happens when camera permission dialog shows up,
      // which triggers `didChangeAppLifecycleState`, which disposes and
      // re-creates the controller.
      await oldController.dispose();
    }

    final CameraController cameraController = CameraController(
      cameraDescription,
      widget.resolution,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
      //TODO
      // if (cameraController.value.hasError) {
      //   showInSnackBar(
      //       'Camera error ${cameraController.value.errorDescription}');
      // }
    });

    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      // switch (e.code) {
      //   case 'CameraAccessDenied':
      //     showInSnackBar('You have denied camera access.');
      //     break;
      //   case 'CameraAccessDeniedWithoutPrompt':
      //     // iOS only
      //     showInSnackBar('Please go to Settings app to enable camera access.');
      //     break;
      //   case 'CameraAccessRestricted':
      //     // iOS only
      //     showInSnackBar('Camera access is restricted.');
      //     break;
      //   case 'AudioAccessDenied':
      //     showInSnackBar('You have denied audio access.');
      //     break;
      //   case 'AudioAccessDeniedWithoutPrompt':
      //     // iOS only
      //     showInSnackBar('Please go to Settings app to enable audio access.');
      //     break;
      //   case 'AudioAccessRestricted':
      //     // iOS only
      //     showInSnackBar('Audio access is restricted.');
      //     break;
      //   default:
      //     _showCameraException(e);
      //     break;
      // }
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<String> cropImageAndSave(String file, Size screenSize) async {
    final path = file;
    String ext = path.split('.').last.split('/').last.toLowerCase();
    final img.Image? image = path.toLowerCase().endsWith('png')
        ? img.decodePng(File(path).readAsBytesSync())
        : img.decodeJpg(File(path).readAsBytesSync());
    final box = downloadObjectKey.currentContext?.findRenderObject()!
        as RenderConstrainedBox;
    final localBounds = box.paintBounds;
    Offset globalOffset = box.localToGlobal(Offset.zero);
    Rect globalBounds = localBounds.shift(globalOffset);
    double widthFactor = image!.width / screenSize.width;
    double heightFactor = image.height / screenSize.height;
    final picture = img.copyCrop(image,
        x: (widthFactor * globalBounds.left).toInt(),
        y: (heightFactor * globalBounds.top).toInt(),
        width: ((localBounds.right - localBounds.left) * widthFactor).toInt(),
        height:
            ((localBounds.bottom - localBounds.top) * heightFactor).toInt());

    final newPath =
        '${widget.applicationDocumentsDirectoryPath}${DateTime.now().millisecondsSinceEpoch}.$ext';
    final jpgImage = img.encodeJpg(picture);
    File outputFile = File(newPath);
    await outputFile.writeAsBytes(jpgImage, flush: true);
    return outputFile.path;
  }

  // Future<String> cropImageAndSave(XFile file, Size screenSize) async {
  //   final path = file.path;
  //   String ext = path.split('.').last.split('/').last.toLowerCase();
  //   final img.Image? image = path.toLowerCase().endsWith('png')
  //       ? img.decodePng(File(path).readAsBytesSync())
  //       : img.decodeJpg(File(path).readAsBytesSync());
  //   final offset = downloadObjectKey.currentContext?.findRenderObject()!
  //       as RenderConstrainedBox;
  //   final bounds = offset.paintBounds;
  //   Offset globalOffset = offset.localToGlobal(Offset.zero);
  //   Rect globalBounds = bounds.shift(globalOffset);
  //   double widthFactor = image!.width / screenSize.width;
  //   double heightFactor = image.height / screenSize.height;
  //   final picture = img.copyCrop(image,
  //       x: 0.33 *
  //           (screenSize.width - (bounds.right - bounds.left)) *
  //           image.width ~/
  //           screenSize.width,
  //       y: (0.5 *
  //               (screenSize.height - bounds.right) *
  //               (image.width / screenSize.width))
  //           .toInt(),
  //       width: image.width * (bounds.right - bounds.left) ~/ screenSize.width,
  //       height:
  //           50 + (bounds.bottom * (image.height / screenSize.height)).toInt());
  //   final dir = await getApplicationDocumentsDirectory();
  //   final newPath = '${dir.path}${DateTime.now().millisecondsSinceEpoch}.$ext';
  //   final jpg = img.encodeJpg(picture);
  //   File pip = File(newPath);
  //   await pip.writeAsBytes(jpg, flush: true);
  //   return pip.path;
  // }

  @override
  Widget build(BuildContext context) {
    Widget loadingWidget = widget.loadingWidget ??
        Container(
          color: Colors.white,
          height: double.infinity,
          width: double.infinity,
          child: const Align(
            alignment: Alignment.center,
            child: Text('loading camera'),
          ),
        );

    if (!controller.value.isInitialized) {
      return loadingWidget;
    }

    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        fit: StackFit.expand,
        children: [
          CameraPreview(controller),
          if (!widget.useFullScreen)
            OverlayShape(widget.cardOverlay, downloadObjectKey),
          if (widget.label.isNotEmpty || widget.info.isNotEmpty)
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                  margin: widget.infoMargin ??
                      const EdgeInsets.only(top: 100, left: 20, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.label.isNotEmpty)
                        Text(
                          widget.label,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700),
                        ),
                      if (widget.info.isNotEmpty)
                        Flexible(
                          child: Text(
                            widget.info,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                    ],
                  )),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: widget.controlOptionsBuilder != null
                ? widget.controlOptionsBuilder!(widget.cameras, controller)
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black12,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              enableFeedback: true,
                              color: Colors.white,
                              onPressed: () async {
                                await HapticFeedback.vibrate();
                                XFile file = await controller.takePicture();
                                if (widget.useFullScreen) {
                                  widget.onCapture(file);
                                } else {
                                  final screenSize =
                                      MediaQuery.of(context).size;
                                  setState(() {
                                    isProcessingImage = true;
                                  });
                                  final path = await cropImageAndSave(
                                      file.path, screenSize);
                                  widget.onCapture(XFile(path));
                                  if (mounted) {
                                    setState(() {
                                      isProcessingImage = false;
                                    });
                                  }
                                }
                              },
                              icon: isProcessingImage
                                  ? const SizedBox(
                                      height: 50,
                                      width: 50,
                                      child: CircularProgressIndicator(),
                                    )
                                  : widget.takePictureWidget ??
                                      const Icon(
                                        Icons.camera_alt_rounded,
                                      ),
                              iconSize: 50,
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black12,
                              shape: BoxShape.circle,
                            ),
                            margin: const EdgeInsets.all(10),
                            child: IconButton(
                              enableFeedback: true,
                              color: Colors.white,
                              onPressed: () async {
                                for (int i = 10; i > 0; i--) {
                                  await HapticFeedback.vibrate();
                                }
                                final flashMode = showFlash
                                    ? FlashMode.off
                                    : FlashMode.always;
                                await controller.setFlashMode(flashMode);
                                showFlash = !showFlash;
                                if (mounted) {
                                  setState(() {});
                                }
                              },
                              icon: const Icon(
                                Icons.flash_auto,
                              ),
                              iconSize: 50,
                            ),
                          ),
                        ),
                        if (widget.cameras.length > 1)
                          Material(
                            color: Colors.transparent,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black12,
                                shape: BoxShape.circle,
                              ),
                              margin: const EdgeInsets.all(10),
                              child: IconButton(
                                enableFeedback: true,
                                color: Colors.white,
                                onPressed: () async {
                                  final newCamera = widget.cameras.firstWhere(
                                      (camera) =>
                                          camera.lensDirection !=
                                          currentCamera.lensDirection);

                                  await onNewCameraSelected(newCamera);
                                },
                                icon: const Icon(
                                  Icons.cameraswitch_outlined,
                                  color: Colors.white,
                                ),
                                iconSize: 50,
                              ),
                            ),
                          ),
                        Material(
                          color: Colors.transparent,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black12,
                              shape: BoxShape.circle,
                            ),
                            margin: const EdgeInsets.all(10),
                            child: IconButton(
                              enableFeedback: true,
                              color: Colors.white,
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.red,
                              ),
                              iconSize: 50,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
