import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_cropper_with_camera_overlay/flutter_camera_overlay.dart';
import 'package:image_cropper_with_camera_overlay/card_overlay.dart';

import 'display_image.dart';

class ExampleCameraOverlay extends StatefulWidget {
  final CardOverlay overlayModel;
  final bool useFullScreen;
  const ExampleCameraOverlay(
      {Key? key, required this.overlayModel, this.useFullScreen = false})
      : super(key: key);

  @override
  _ExampleCameraOverlayState createState() => _ExampleCameraOverlayState();
}

class _ExampleCameraOverlayState extends State<ExampleCameraOverlay> {
  late CardOverlay cardOverlay;
  int tab = 0;

  @override
  void initState() {
    cardOverlay = widget.overlayModel;
    WidgetsFlutterBinding.ensureInitialized();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<CameraDescription>?>(
        future: availableCameras(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == null) {
              return const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'No camera found',
                    style: TextStyle(color: Colors.black),
                  ));
            }
            return CameraOverlay(
              widget.overlayModel,
              ResolutionPreset.high,
              useFullScreen: widget.useFullScreen,
              (XFile takenPicture) async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DisplayImage(
                          imagePath: takenPicture.path,
                          aspectRatio: widget.overlayModel.ratio)),
                );
              },
              cameras: snapshot.data!,
              info: 'Additional Information Goes Here',
              label: 'Lable goes here',
              applicationDocumentsDirectoryPath:
                  '/data/user/0/com.company_name.app_name/cache', //  = await getApplicationDocumentsDirectory();
            );
          } else {
            return const Align(
                alignment: Alignment.center,
                child: Text(
                  'Fetching cameras',
                  style: TextStyle(color: Colors.black),
                ));
          }
        },
      ),
    );
  }
}
