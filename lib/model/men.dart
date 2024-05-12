import 'coordinate.dart';

class Men {
  late int player;
  bool? isKing;
  Coordinate? coordinate;

  Men({this.player = 1, this.isKing = false, this.coordinate});

  /// this constructor for existing Men to  init new coor
  Men.of(Men men, {Coordinate? newCoor}) {
    player = men.player;
    isKing = men.isKing;
    coordinate = newCoor ?? men.coordinate;

    // if (newCoor != null) {
    //   coordinate = newCoor;
    // }
  }

  upgradeToKing() {
    isKing = true;
  }
}
