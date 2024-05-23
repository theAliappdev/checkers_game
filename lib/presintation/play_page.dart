import 'package:checkers_game/logic/game_table.dart';
import 'package:checkers_game/model/block_table.dart';
import 'package:checkers_game/model/coordinate.dart';
import 'package:checkers_game/model/men.dart';
import 'package:flutter/material.dart';

class PlayPage extends StatefulWidget {
  final Color colorBackgroundF = const Color(0xffeec295);
  final Color colorBackgroundT = const Color(0xff9a6851);
  final Color colorBorderTable = const Color(0xff6d3935);
  final Color colorAppBar = const Color(0xff6d3935);
  final Color colorBackgroundGame = const Color(0xffc16c34);
  final Color? colorBackgroundHighlight = Colors.blue[500];
  final Color? colorBackgroundHighlightAfterKilling = Colors.purple[500];

  PlayPage({super.key, required this.title});

  final String title;

  @override
  _PlayPageState createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  late GameTable gameTable;
  late int modeWalking;

  double blockSize = 1;

  @override
  void initState() {
    initGame();
    super.initState();
  }

  void initGame() {
    modeWalking = GameTable.MODE_WALK_NORMAL;
    //log('modwalking -> $modeWalking');

    gameTable = GameTable(countRow: 8, countCol: 8);
    gameTable.initMenOnTable();
  }

  @override
  Widget build(BuildContext context) {
    initScreenSize(context);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: widget.colorAppBar,
          centerTitle: true,
          title: Text(widget.title.toUpperCase()),
          elevation: 0,
          actions: <Widget>[
            IconButton(
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.amber,
                ),
                onPressed: () {
                  setState(() {
                    initGame();
                  });
                })
          ],
        ),
        body: Container(
            color: widget.colorBackgroundGame,
            child: Column(children: <Widget>[
              Expanded(
                  child: Center(
                child: buildGameTable(),
              )),
              Container(
                decoration: BoxDecoration(
                    color: widget.colorAppBar,
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.red,
                          offset: Offset(0, 3),
                          blurRadius: 12)
                    ]),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[buildCurrentPlayerTurn()],
                ),
              ),
            ])));
  }
  // end of drwaing

  //! start of UI functions
  void initScreenSize(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double shortestSide = MediaQuery.of(context).size.shortestSide;

    if (width < height) {
      blockSize = (shortestSide / 8) - (shortestSide * 0.03);
    } else {
      blockSize = (shortestSide / 8) - (shortestSide * 0.05);
    }
  }

  buildGameTable() {
    List<Widget> listCol = [];
    for (int row = 0; row < gameTable.countRow; row++) {
      List<Widget> listRow = [];
      for (int col = 0; col < gameTable.countCol; col++) {
        listRow.add(buildBlockContainer(Coordinate(row: row, col: col)));
      }

      listCol.add(Row(mainAxisSize: MainAxisSize.min, children: listRow));
    }

    return Container(
        padding: const EdgeInsets.all(8),
        color: widget.colorBorderTable,
        child: Column(mainAxisSize: MainAxisSize.min, children: listCol));
  }

  //todo this is a function I have to work on  moving men
  Widget buildBlockContainer(Coordinate coor) {
    BlockTable block = gameTable.getBlockTable(coor);

    Color? colorBackground;
    if (block.isHighlight) {
      colorBackground = widget.colorBackgroundHighlight;
    } else if (block.isHighlightAfterKilling) {
      colorBackground = widget.colorBackgroundHighlightAfterKilling;
    } else {
      if (gameTable.isBlockTypeF(coor)) {
        colorBackground = widget.colorBackgroundF;
      } else {
        colorBackground = widget.colorBackgroundT;
      }
    }

    Widget menWidget;
    if (block.men != null) {
      Men? men = gameTable.getBlockTable(coor).men;

      menWidget = InkWell(
        onTap: () {
          setState(() {
            gameTable.movingMan = men;
            gameTable.clearHighlightWalkable();
            print("walking mode = $modeWalking");
            if (men.player == gameTable.currentPlayerTurn) {
              gameTable.highlightWalkable(men, mode: modeWalking);
            }
          });
        },
        child: Center(
            child: buildMenWidget(
                player: men!.player, isKing: men.isKing!, size: blockSize)),
      );
    } else {
      menWidget = Container();
    }

    return buildBlockTableContainer(coor, block, colorBackground!, menWidget);
  }

  //todo -----------
  Widget buildBlockTableContainer(Coordinate coor, BlockTable block,
      Color colorBackground, Widget menWidget) {
    Widget containerBackground = InkWell(
      onTap: () {
        if (block.isHighlight || block.isHighlightAfterKilling) {
          setState(() {
            gameTable.moveMen(gameTable.movingMan, Coordinate.of(coor));
            gameTable.checkKilled(coor);

            if (gameTable.checkKillableMore(gameTable.movingMan, coor) &&
                gameTable.getBlockTable(coor).killableMore) {
              modeWalking = GameTable.MODE_WALK_AFTER_KILLING;
            } else {
              if (gameTable.isKingArea(
                  player: gameTable.currentPlayerTurn, coor: coor)) {
                gameTable.movingMan.upgradeToKing();
              }
              modeWalking = GameTable.MODE_WALK_NORMAL;
              gameTable.clearHighlightWalkable();
              gameTable.togglePlayerTurn();
            }
          });
        }
      },
      child: Container(
          width: blockSize + (blockSize * 0.1),
          height: blockSize + (blockSize * 0.1),
          color: colorBackground,
          margin: const EdgeInsets.all(2),
          child: menWidget),
    );
    return containerBackground;
  }

  // -------------------------
  Widget buildCurrentPlayerTurn() {
    return Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Current turn".toUpperCase(),
                  style: const TextStyle(fontSize: 16, color: Colors.white)),
              Padding(
                  padding: const EdgeInsets.all(6),
                  child: buildMenWidget(
                      player: gameTable.currentPlayerTurn, size: blockSize))
            ]));
  }

  buildMenWidget({int player = 1, bool isKing = false, double size = 32}) {
    if (isKing) {
      return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                    color: Colors.black45, offset: Offset(0, 4), blurRadius: 4)
              ],
              color: player == 1 ? Colors.black54 : Colors.grey[100]),
          child: Icon(Icons.star,
              color: player == 1
                  ? Colors.grey[100]!.withOpacity(0.5)
                  : Colors.black54.withOpacity(0.5),
              size: size - (size * 0.1)));
    }

    return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                  color: Colors.black45, offset: Offset(0, 4), blurRadius: 4)
            ],
            color: player == 1 ? Colors.black54 : Colors.grey[100]));
  }
}
