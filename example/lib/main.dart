import 'package:arkit_plugin_example/body_tracking_page.dart';
import 'package:arkit_plugin_example/camera_position_scene.dart';
import 'package:arkit_plugin_example/capture_stream_page.dart';
import 'package:arkit_plugin_example/check_support_page.dart';
import 'package:arkit_plugin_example/custom_animation_page.dart';
import 'package:arkit_plugin_example/custom_object_page.dart';
import 'package:arkit_plugin_example/distance_tracking_page.dart';
import 'package:arkit_plugin_example/custom_light_page.dart';
import 'package:arkit_plugin_example/earth_page.dart';
import 'package:arkit_plugin_example/free_draw_line_page.dart';
import 'package:arkit_plugin_example/hello_world.dart';
import 'package:arkit_plugin_example/image_detection_page.dart';
import 'package:arkit_plugin_example/light_estimate_page.dart';
import 'package:arkit_plugin_example/load_external_model.dart';
import 'package:arkit_plugin_example/manipulation_page.dart';
import 'package:arkit_plugin_example/measure_page.dart';
import 'package:arkit_plugin_example/midas_page.dart';
import 'package:arkit_plugin_example/network_image_detection.dart';
import 'package:arkit_plugin_example/occlusion_page.dart';
import 'package:arkit_plugin_example/physics_page.dart';
import 'package:arkit_plugin_example/plane_detection_page.dart';
import 'package:arkit_plugin_example/snapshot_scene.dart';
import 'package:arkit_plugin_example/tap_page.dart';
import 'package:arkit_plugin_example/face_detection_page.dart';
import 'package:arkit_plugin_example/panorama_page.dart';
import 'package:arkit_plugin_example/video_page.dart';
import 'package:arkit_plugin_example/widget_projection.dart';
import 'package:arkit_plugin_example/real_time_updates.dart';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final samples = [
      Sample(
        'Hello World',
        'The simplest scene with all geometries.',
        Icons.home,
        () => Navigator.of(context).push<void>(MaterialPageRoute(builder: (c) => HelloWorldPage())),
      ),
      Sample(
        'Load External Model',
        'Load External Model .obj etx...',
        Icons.home,
        () => Navigator.of(context).push<void>(MaterialPageRoute(builder: (c) => LoadExternal3DModel())),
      ),
      Sample(
        'Check configuration',
        'Shows which kinds of AR configuration are supported on the device',
        Icons.settings,
        () => Navigator.of(context).push<void>(MaterialPageRoute(builder: (c) => CheckSupportPage())),
      ),
      Sample(
        'Earth',
        'Sphere with an image texture and rotation animation.',
        Icons.language,
        () => Navigator.of(context).push<void>(MaterialPageRoute(builder: (c) => EarthPage())),
      ),
      Sample(
        'Tap',
        'Sphere which handles tap event.',
        Icons.touch_app,
        () => Navigator.of(context).push<void>(MaterialPageRoute(builder: (c) => TapPage())),
      ),
      Sample(
        'Midas',
        'Turns walls, floor, and Earth itself into gold by tap.',
        Icons.touch_app,
        () => Navigator.of(context).push<void>(MaterialPageRoute(builder: (c) => MidasPage())),
      ),
      Sample(
        'Plane Detection',
        'Detects horizontal plane.',
        Icons.blur_on,
        () => Navigator.of(context).push<void>(MaterialPageRoute(builder: (c) => PlaneDetectionPage())),
      ),
      Sample(
        'Distance tracking',
        'Detects horizontal plane and track distance on it.',
        Icons.blur_on,
        () => Navigator.of(context).push<void>(MaterialPageRoute(builder: (c) => DistanceTrackingPage())),
      ),
      Sample(
        'Free Draw Line',
        'Free Draw LIne.',
        Icons.blur_on,
        () => Navigator.of(context).push<void>(MaterialPageRoute(builder: (c) => FreeDrawLinePage())),
      ),
      Sample(
        'Measure',
        'Measures distances',
        Icons.linear_scale,
        () => Navigator.of(context).push<void>(MaterialPageRoute(builder: (c) => MeasurePage())),
      ),
      Sample(
        'Physics',
        'A sphere and a plane with dynamic and static physics',
        Icons.file_download,
        () => Navigator.of(context).push<void>(MaterialPageRoute(builder: (c) => PhysicsPage())),
      ),
      Sample(
        'Image Detection',
        'Detects Earth photo and puts a 3D object near it.',
        Icons.collections,
        () => Navigator.of(context).push<void>(MaterialPageRoute(builder: (c) => ImageDetectionPage())),
      ),
      Sample(
        'Network Image Detection',
        'Detects Mars photo and puts a 3D object near it.',
        Icons.collections,
        () => Navigator.of(context).push<void>(MaterialPageRoute(builder: (c) => NetworkImageDetectionPage())),
      ),
      Sample(
        'Custom Light',
        'Hello World scene with a custom light spot.',
        Icons.lightbulb_outline,
        () => Navigator.of(context).push<void>(MaterialPageRoute(builder: (c) => CustomLightPage())),
      ),
      Sample(
        'Light Estimation',
        'Estimates and applies the light around you.',
        Icons.brightness_6,
        () => Navigator.of(context).push<void>(MaterialPageRoute(builder: (c) => LightEstimatePage())),
      ),
      Sample(
        'Custom Object',
        'Place custom object on plane with coaching overlay.',
        Icons.nature,
        () => Navigator.of(context).push<void>(MaterialPageRoute(builder: (c) => CustomObjectPage())),
      ),
      Sample(
        'Occlusion',
        'Spheres which are not visible after horizontal and vertical planes.',
        Icons.blur_circular,
        () => Navigator.of(context).push<void>(MaterialPageRoute(builder: (c) => OcclusionPage())),
      ),
      Sample(
        'Manipulation',
        'Custom objects with pinch and rotation events.',
        Icons.threed_rotation,
        () => Navigator.of(context).push<void>(MaterialPageRoute(builder: (c) => ManipulationPage())),
      ),
      Sample(
        'Face Tracking',
        'Face mask sample.',
        Icons.face,
        () => Navigator.of(context).push<void>(MaterialPageRoute(builder: (c) => FaceDetectionPage())),
      ),
      Sample(
        'Body Tracking',
        'Dash that follows your hand.',
        Icons.person,
        () => Navigator.of(context).push<void>(MaterialPageRoute(builder: (c) => BodyTrackingPage())),
      ),
      Sample(
        'Panorama',
        '360 photo sample.',
        Icons.panorama,
        () => Navigator.of(context).push<void>(MaterialPageRoute(builder: (c) => PanoramaPage())),
      ),
      Sample(
        'Video',
        '360 video sample.',
        Icons.videocam,
        () => Navigator.of(context).push<void>(MaterialPageRoute(builder: (c) => VideoPage())),
      ),
      Sample(
        'Custom Animation',
        'Custom object animation. Port of https://github.com/eh3rrera/ARKitAnimation',
        Icons.accessibility_new,
        () => Navigator.of(context).push<void>(MaterialPageRoute(builder: (c) => CustomAnimationPage())),
      ),
      Sample(
        'Widget Projection',
        'Flutter widgets in AR',
        Icons.widgets,
        () => Navigator.of(context).push<void>(MaterialPageRoute(builder: (c) => WidgetProjectionPage())),
      ),
      Sample(
        'Real Time Updates',
        'Calls a function once per frame',
        Icons.timer,
        () => Navigator.of(context).push<void>(MaterialPageRoute(builder: (c) => RealTimeUpdatesPage())),
      ),
      Sample(
        'Snapshot',
        'Make a photo of AR content',
        Icons.camera,
        () => Navigator.of(context).push<void>(MaterialPageRoute(builder: (c) => SnapshotScenePage())),
      ),
      Sample(
        'Capture Stream',
        'New Snapshot Capture Stream Page',
        Icons.camera_roll,
        () => Navigator.of(context).push<void>(MaterialPageRoute(builder: (c) => CaptureStreamPage())),
      ),
      Sample(
        'Camera position',
        'Get position of the camera in AR scene',
        Icons.location_on,
        () => Navigator.of(context).push<void>(MaterialPageRoute(builder: (c) => CameraPositionScenePage())),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('ARKit Demo'),
      ),
      body: ListView(children: samples.map((s) => SampleItem(item: s)).toList()),
    );
  }
}

class SampleItem extends StatelessWidget {
  const SampleItem({
    required this.item,
    Key? key,
  }) : super(key: key);
  final Sample item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => item.onTap(),
        child: ListTile(
          leading: Icon(item.icon),
          title: Text(
            item.title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Text(
            item.description,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
      ),
    );
  }
}

class Sample {
  const Sample(this.title, this.description, this.icon, this.onTap);
  final String title;
  final String description;
  final IconData icon;
  final Function onTap;
}
