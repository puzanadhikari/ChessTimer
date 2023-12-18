import 'dart:async';
import 'dart:developer';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _whiteSeconds = 20;
  int _blackSeconds = 20;
  bool _isStarted = false;
  bool _isWhiteTurn = false;
  bool _isBlackTurn = false;
  Timer? _timer;

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_isWhiteTurn && _whiteSeconds > 0) {
          _whiteSeconds--;
        } else if (_isBlackTurn && _blackSeconds > 0) {
          _blackSeconds--;
        } else {
          // Timer expired, switch turns
          _timer?.cancel();
          _switchTurns();
        }
      });
    });
  }

  void _switchTurns() {
    log("Switch Turn");
    setState(() {
      _isWhiteTurn = !_isWhiteTurn;
      _isBlackTurn = !_isBlackTurn;
      _startTimer();
    });
  }

  void _resetTimer() {
    setState(() {
      _whiteSeconds = 20;
      _blackSeconds = 20;
      _isWhiteTurn=false;
      _isBlackTurn = false;
      _timer?.cancel();
    });
  }

  void _showTimeInputDialog(BuildContext context, bool isWhite) {
    TextEditingController _controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Set Timer",
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                int timeInSeconds = int.tryParse(_controller.text) ?? 0;
                setState(() {
                  if (isWhite) {
                    _whiteSeconds = timeInSeconds;
                  } else {
                    _blackSeconds = timeInSeconds;
                  }
                });
                Navigator.of(context).pop();
              },
              child: Text('Set'),
            ),
          ],
        );
      },
    );
  }

  Future<void> play() async {
    log("im here");
    await AssetsAudioPlayer.newPlayer().open(
      Audio('assets/sound/gun.mp3'),
    );
  }
  Future<void> reload() async {
    log("im here");
    await AssetsAudioPlayer.newPlayer().open(
      Audio('assets/sound/reload.mp3'),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chess Timer"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Card(
          margin: EdgeInsets.all(10.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  _isWhiteTurn== true ?
                  setState(() {
                    play();
                    _isWhiteTurn = false;
                    _isBlackTurn = true;
                    _startTimer();
                  }) : '';
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.39,
                  color: _isWhiteTurn==true ? _whiteSeconds<10?Colors.red:Colors.green : Colors.white,
                  child: Center(
                    child: Text(
                      "${_whiteSeconds}",
                      style:
                      TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isStarted = true;
                        _isWhiteTurn = true;
                        _isBlackTurn = false;
                        _startTimer();
                      });
                    },
                    child: Text(
                      "Start",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                    style: ElevatedButton.styleFrom(primary: Colors.green),
                  ),
                  ElevatedButton(
                    onPressed:(){
                      setState(() {
                        reload();
                        _resetTimer();
                      });
                    },
                    child: Text(
                      "Reset",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                    style: ElevatedButton.styleFrom(primary: Colors.red),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _showTimeInputDialog(context, true);
                    },
                    child: Text(
                      "Time",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                    style: ElevatedButton.styleFrom(primary: Colors.blue),
                  )
                ],
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () { _isBlackTurn==true ?
                  setState(() {
                    play();
                    _isBlackTurn = false;
                    _isWhiteTurn = true;
                    _startTimer();
                  }) : '';
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.39,
                  color: _isBlackTurn==true ? _blackSeconds<10?Colors.red:Colors.green :Colors.black38,
                  child: Center(
                    child: Text(
                      "${_blackSeconds}",
                      style:
                      TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
