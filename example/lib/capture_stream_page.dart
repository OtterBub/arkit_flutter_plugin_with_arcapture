import 'dart:developer';

import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:arkit_plugin_example/util/ar_helper.dart';
import 'package:flutter/material.dart';

class CaptureStreamPage extends StatefulWidget {
  @override
  _CaptureStreamPageState createState() => _CaptureStreamPageState();
}

class _CaptureStreamPageState extends State<CaptureStreamPage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('CaptureStream'),
      ),
      body: Container(child: testViewer()));
}

class testViewer extends StatefulWidget {
  const testViewer({Key? key}) : super(key: key);

  @override
  State<testViewer> createState() => _testViewerState();
}

class _testViewerState extends State<testViewer> {
  ARKitController? arkitController;
  List<ImageProvider> imageList = [];
  bool isStartReady = true;
  bool isDispose = false;

  @override
  void initState() {
    Future.doWhile(updateFrame);
    super.initState();
  }

  int indexCount = 0;
  Future<bool> updateFrame() async {
    await Future.delayed(Duration(milliseconds: 3));
    if (isDispose) return false;
    if (arkitController != null) {
      try {
        var image = (await arkitController!.snapshot(compressionQuality: 0.5)) as MemoryImage;
        if (imageList.length < 6) {
          imageList.add(image);
        } else {
          imageList[indexCount] = image;
          indexCount = (indexCount + 1) % 6;
        }
      } catch (e) {
        log("snapshot error: $e");
        await Future.delayed(Duration(milliseconds: 500));
      }
      if (!mounted) return false;
      log("capture");
      setState(() {});
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      ARKitSceneView(onARKitViewCreated: onARKitViewCreated),
      SizedBox.fromSize(
          size: Size(1000, 1000),
          child: imageList.length < 6
              ? ColoredBox(color: Colors.black)
              : IndexedStack(
                  index: indexCount,
                  children: [
                    Image(image: imageList[0]),
                    Image(image: imageList[1]),
                    Image(image: imageList[2]),
                    Image(image: imageList[3]),
                    Image(image: imageList[4]),
                    Image(image: imageList[5]),
                  ],
                )),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FloatingActionButton.large(
            onPressed: () {
              isStartReady ? arkitController?.captureStart() : arkitController?.captureStop();
              setState(() {
                isStartReady = !isStartReady;
              });
            },
            child: Text(isStartReady ? "Start" : "Stop"),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: Column(
                children: [
                  LinearProgressIndicator(),
                  RefreshProgressIndicator(),
                  CircularProgressIndicator.adaptive(),
                  CircularProgressIndicator()
                ],
              ),
            ),
          )
        ],
      ),
    ]);
  }

  void onARKitViewCreated(ARKitController arkitController) {
    this.arkitController = arkitController;
    this.arkitController?.add(createSphere());
  }

  @override
  void dispose() {
    isDispose = true;
    arkitController?.dispose();
    arkitController = null;
    super.dispose();
  }
}
