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
        title: const Text('Snapshot'),
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
  bool isStart = false;
  bool isDispose = false;

  @override
  void initState() {
    Future.doWhile(updateFrame);
    super.initState();
  }

  int indexCount = 0;
  Future<bool> updateFrame() async {
    await Future.delayed(Duration(milliseconds: 9));
    if (isDispose) return false;
    if (arkitController != null) {
      try {
        var image = (await arkitController!.snapshot()) as MemoryImage;
        if (imageList.length < 3) {
          imageList.add(image);
        } else {
          imageList[indexCount] = image;
          indexCount = (indexCount + 1) % 3;
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
          size: Size(500, 500),
          child: imageList.length < 3
              ? ColoredBox(color: Colors.black)
              : IndexedStack(
                  index: indexCount,
                  children: [
                    Image(image: imageList[0]),
                    Image(image: imageList[1]),
                    Image(image: imageList[2]),
                  ],
                )),
      FloatingActionButton.small(
        onPressed: () {
          setState(() {
            isStart = !isStart;
          });
        },
        child: Text(isStart ? "Stop" : "Start"),
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

class SnapshotPreview extends StatefulWidget {
  const SnapshotPreview({
    Key? key,
    required this.imageProvider,
    required this.arKitController,
  }) : super(key: key);

  final ImageProvider imageProvider;
  final ARKitController arKitController;

  @override
  State<SnapshotPreview> createState() => _SnapshotPreviewState();
}

class _SnapshotPreviewState extends State<SnapshotPreview> {
  ARKitController get controller => widget.arKitController;
  late ImageProvider image;

  int count = 0;

  @override
  void initState() {
    image = widget.imageProvider;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // WidgetsBinding.instance.addPostFrameCallback(updateframe);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Preview'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image(image: image),
        ],
      ),
    );
  }
}
