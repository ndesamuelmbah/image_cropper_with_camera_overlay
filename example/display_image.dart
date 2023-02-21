import 'dart:io' show File;
import 'package:flutter/material.dart';

class DisplayImage extends StatefulWidget {
  final String imagePath;
  final double aspectRatio;

  const DisplayImage(
      {super.key, required this.imagePath, required this.aspectRatio});

  @override
  State<DisplayImage> createState() => _DisplayImageState();
}

class _DisplayImageState extends State<DisplayImage> {
  File? localFile;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
              ElevatedButton(
                onPressed: () async {
                  print(widget.imagePath);
                  print(await File(widget.imagePath).length());
                },
                child: const Text('Print Image Details'),
              ),
            ],
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Image.file(File(widget.imagePath), fit: BoxFit.contain)),
          const SizedBox(
            height: 100,
          )
        ],
      ),
    );
  }
}
