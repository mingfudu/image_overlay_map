# example

This is a Flutter demo project using image_overlay_map to build a map with markers.
It's able to customize markers use markerWidgetBuilder.
Markers will be rebuild when scale on screen;

https://user-images.githubusercontent.com/11880676/117442463-c1a65200-af71-11eb-940e-4cc60b31d2a0.mp4

## Getting Started

### add dependencies
dependencies:
  image_overlay_map: ^0.0.1
  
### import
import 'package:image_overlay_map/image_overlay_map.dart';
  

## Guidance

### this.child,
An image widget as map. It will be scaled to the right size to make sure fit full screen on different devices.
The image use local assets or web url is both supported.Sample demo shows howto use web images;

### this.size,
Size of image in pixels.Sample demo use Leaflet CRS.Simple, bounds = [[-height / 2, -width / 2], [height / 2, width / 2]].
[0,0] is center of image. You can build a different one when build MarkerModel from your marker data;

### this.markers,
MarkerModel data build from your marker data.
          
### this.onMarkerClicked,
Called when marker widget is clicked.

### this.markerWidgetBuilder,
Build a widget from MarkerModel. You can build different widget for different scale value.

### this.onTab,
Called when map background image is tabbed.
