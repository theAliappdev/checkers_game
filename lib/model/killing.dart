
import 'package:checkers_game/model/men.dart';

/// in  this repo  we get men and seee if it is killed
class Killed {
  late bool isKilled;
  Men? men;

  /// cant understand why we need man coz we not usig it
  Killed({this.isKilled = false, this.men});

  Killed.none() {
    isKilled = false;
  }
}
