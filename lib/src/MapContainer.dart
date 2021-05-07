import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'markerModel.dart';
import 'measuredSize.dart';

class MapContainer extends StatefulWidget {
  final Image child;
  final Size size;
  final List<MarkerModel> markers;
  final ValueChanged<MarkerModel> onMarkerClicked;
  final void Function() onTab;
  final Widget Function(double scale, MarkerModel data) markerWidgetBuilder;

  MapContainer(this.child, this.size,
      {this.markers,
      this.onMarkerClicked,
      this.onTab,
      this.markerWidgetBuilder,
      Key key})
      : super(key: key);

  _MapContainerState createState() => _MapContainerState();
}

class _MapContainerState extends State<MapContainer> {
  Offset _offset = Offset.zero;
  double _scale = 1.0;
  Offset _normalizedOffset;
  double _previousScale;
  bool _needSetDefaultScaleAndOffset = true;
  double _defaultScale = 1.0;
  double _defaultScaleX = 1.0;
  double _defaultScaleY = 1.0;

  List<MarkerModel> _markers = [];

  @override
  void initState() {
    super.initState();
  }

  double _clampScale(double scale) {
    return scale.clamp(_defaultScale, 10).toDouble();
  }

  Offset _clampOffset(Offset offset) {
    final Size size = context.size;
    // expand image to fit full screen if need
    if (_defaultScaleX > _defaultScaleY) {
      double per = _defaultScaleY / _defaultScaleX;
      double xSize = size.width * _scale;
      double xOffsetMax = xSize * (per - 1) / 2 + 0.01;
      double xOffsetMin = -(xSize - xSize * (1 - per) / 2 - size.width);
      return new Offset(offset.dx.clamp(xOffsetMin, xOffsetMax),
          offset.dy.clamp(size.height * (1 - _scale), 0.0));
    } else {
      double per = _defaultScaleX / _defaultScaleY;
      double ySize = size.height * _scale;
      double yOffsetMax = ySize * (per - 1) / 2 + 0.01;
      double yOffsetMin = -(ySize - ySize * (1 - per) / 2 - size.height);
      return new Offset(offset.dx.clamp(size.width * (1 - _scale), 0.0),
          offset.dy.clamp(yOffsetMin, yOffsetMax));
    }
  }

  void _handleOnScaleStart(ScaleStartDetails details) {
    widget.onTab();
    setState(() {
      _previousScale = _scale;
      _normalizedOffset = (details.localFocalPoint - _offset) / _scale;
    });
  }

  void _handleOnScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _scale = _clampScale(_previousScale * details.scale);
      _offset =
          _clampOffset(details.localFocalPoint - _normalizedOffset * _scale);
    });
  }

  Future<void> _handleOnPressMarker(
      BuildContext context, MarkerModel markerModel) async {
    if (widget.onMarkerClicked != null) widget.onMarkerClicked(markerModel);
  }

  List<Widget> _getMapWidgetWithMarker(
      double scale, List<MarkerModel> markers) {
    var result = <Widget>[];
    result.add(Container(
        margin: EdgeInsets.all(0),
        constraints: const BoxConstraints(
          minWidth: double.maxFinite,
          minHeight: double.infinity,
        ),
        transform: new Matrix4.identity()
          ..translate(_offset.dx, _offset.dy)
          ..scale(_scale, _scale),
        child: widget.child));
    result.addAll(_getMarkerWidgetList(scale, markers));
    return result;
  }

  List<Widget> _getMarkerWidgetList(double scale, List<MarkerModel> markers) {
    var result = <Widget>[];
    _markers.forEach((element) {
      Widget childWidget = Wrap(
        children: [
          InkWell(
              onTap: () {
                _handleOnPressMarker(context, element);
              },
              child: _getMarkerWidget(scale, element))
        ],
      );

      result.add(Container(
          child: MeasuredSize(
              onChange: (Size size) {
                setState(() {
                  element.size = size;
                });
              },
              child: childWidget),
          transform: new Matrix4.identity()
            ..translate(
                _offset.dx +
                    element.offset.dx * scale -
                    0.5 * element.size.width,
                _offset.dy +
                    element.offset.dy * scale -
                    1 * element.size.height)));
    });
    return result;
  }

  Widget _getMarkerWidget(double scale, MarkerModel data) {
    if (widget.markerWidgetBuilder != null) {
      return widget.markerWidgetBuilder(scale, data);
    }
    return Icon(Icons.location_on, color: Colors.redAccent);
  }

  void calculateMarkerPosition() {
    if (_markers.isNotEmpty || widget.markers.isEmpty) return;
    final Size size = context.size;
    var markerCalculated = <MarkerModel>[];
    var scaleX = size.width / widget.size.width;
    var scaleY = size.height / widget.size.height;
    double scale = math.min(scaleX, scaleY);
    widget.markers.forEach((element) {
      var dx = (size.width - widget.size.width * scale) / 2 +
          scale * element.offset.dx;
      var dy = (size.height - widget.size.height * scale) / 2 +
          scale * element.offset.dy;
      element.offset = Offset(dx, dy);
      markerCalculated.add(element);
    });
    setState(() {
      _markers = markerCalculated;
    });
  }

  void calculateDefaultScaleAndOffset() {
    if (!_needSetDefaultScaleAndOffset) return;
    final Size size = context.size;
    _defaultScaleX = size.width / widget.size.width;
    _defaultScaleY = size.height / widget.size.height;
    double scaleMax = math.max(_defaultScaleX, _defaultScaleY);
    double scaleMin = math.min(_defaultScaleX, _defaultScaleY);
    setState(() {
      _defaultScale = scaleMax / scaleMin;
      _scale = _defaultScale;
      _offset = Offset(
          (size.width * (1 - _scale)) / 2, size.height * (1 - _scale) / 2);
      _needSetDefaultScaleAndOffset = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      calculateDefaultScaleAndOffset();
      calculateMarkerPosition();
    });
    return new GestureDetector(
        onTap: widget.onTab,
        onScaleStart: _handleOnScaleStart,
        onScaleUpdate: _handleOnScaleUpdate,
        behavior: HitTestBehavior.translucent,
        child: Stack(children: _getMapWidgetWithMarker(_scale, _markers)));
  }
}
