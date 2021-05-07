import 'dart:ui';

class MarkerModel {
  static const defaultSize = Size(18, 25);
  dynamic data;
  Offset offset;
  Size size;

  MarkerModel(this.data, this.offset, {this.size = defaultSize});
}
