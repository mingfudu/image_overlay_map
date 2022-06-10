import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_overlay_map/image_overlay_map.dart';
import 'bubble_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'image overlay map Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'map like leaflet image overlay'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;
  final List<Facility> _facilityList = [
    Facility(1, "facility1", 0, 0), // center
    Facility(2, "facility2", -100, 0),
    Facility(3, "facility3", 100, 0),
    Facility(4, "facility4", 0, -100),
    Facility(5, "facility5", 0, 100),
  ];

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Stack(
          children: <Widget>[
            _getWebMap(
                "https://user-images.githubusercontent.com/11880676/117417895-c6f5a380-af55-11eb-8fe4-5db2f40ca82a.png"),
          ],
        ));
  }

  Widget _getWebMap(String url) {
    return FutureBuilder(
        future: _calculateImageDimension(url),
        builder: (BuildContext context, AsyncSnapshot snapShot) {
          if (snapShot.connectionState == ConnectionState.done) {
            if (snapShot.hasError) {
              return Center(
                child: Text("error happened when download image"),
              );
            }
            return Center(
              child: MapContainer(
                  new Image(image: CachedNetworkImageProvider(url)),
                  snapShot.data,
                  markers: _getMarker(widget._facilityList, snapShot.data),
                  markerWidgetBuilder: _getMarkerWidget,
                  onTab: _onTab,
                  onMarkerClicked: _onMarkerClicked),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  Future<Size> _calculateImageDimension(String imageUrl) {
    Completer<Size> completer = Completer();
    Image image = new Image(image: CachedNetworkImageProvider(imageUrl));
    image.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo image, bool synchronousCall) {
          var myImage = image.image;
          Size size = Size(myImage.width.toDouble(), myImage.height.toDouble());
          completer.complete(size);
        },
      ),
    );
    return completer.future;
  }

  List<MarkerModel> _getMarker(List<Facility> facilities, Size size) {
    List<MarkerModel> result = [];
    facilities.forEach((element) {
      // Leaflet CRS.Simple, bounds = [[-height / 2, -width / 2], [height / 2, width / 2]]
      double dx = size.width / 2 + element.lng;
      double dy = size.height / 2 - element.lat;
      // offset from left top
      result.add(MarkerModel(element, Offset(dx, dy)));
    });
    return result;
  }

  Widget _getMarkerWidget(double scale, MarkerModel data) {
    Facility facility = data.data;
    if (facility.facilityId == 1) {
      return Icon(Icons.location_on, color: Colors.blue);
    }

    if (scale > 3) {
      return BubbleWidget(
          direction: ArrowDirection.bottom,
          color: Colors.orange,
          strokeColor: Colors.white,
          strokeWidth: 1.0,
          borderRadius: 3.0,
          style: BubbleStyle.stroke,
          padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
          child: Text(facility.name,
              maxLines: 1,
              textAlign: TextAlign.left,
              style: TextStyle(color: Colors.white, fontSize: 10.0)));
    }

    return Icon(Icons.location_on, color: Colors.redAccent);
  }

  _onMarkerClicked(MarkerModel markerModel) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: Text((markerModel.data as Facility).name),
          );
        },
        routeSettings: RouteSettings(name: "/facilityDetail"));
  }

  _onTab() {
    print("onTab");
  }
}

class Facility {
  int facilityId;
  String name;

  // Leaflet CRS.Simple, bounds = [[-height / 2, -width / 2], [height / 2, width / 2]]
  double lng;
  double lat;

  Facility(this.facilityId, this.name, this.lng, this.lat);
}
