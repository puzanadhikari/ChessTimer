import 'dart:async';
import 'dart:developer';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _whiteTimeController = TextEditingController();
  TextEditingController _blackTimeController = TextEditingController();
  TimeOfDay? _selectedWhiteTime;
  TimeOfDay? _selectedBlackTime;
  int _whiteSeconds = 0;
  int _additionalTime = 0;

  int _blackSeconds = 0;

  bool _isStarted = true;
  bool _isWhiteTurn = false;
  bool _isBlackTurn = false;
  Timer? _timer;
  String selectedValue = 'Default';
  int _whiteCount = 0;
  int _blackCount = 0;

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_isWhiteTurn && _whiteSeconds > 0) {
          _whiteSeconds--;
        } else if (_whiteSeconds == 0 || _blackSeconds == 0) {
          stop();
          _timer!.cancel();
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
      _whiteSeconds = _parseTime(_whiteTimeController.text);
      _blackSeconds = _parseTime(_blackTimeController.text);
      _isWhiteTurn = false;
      _isBlackTurn = false;
      _isStarted = true;
      _blackCount = 0;
      _whiteCount = 0;
      _timer?.cancel();
    });
  }

  Future<void> _selectWhiteTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedWhiteTime ?? TimeOfDay.now(),
      useRootNavigator: false, // Add this line
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,

        );
      },
    );

    if (picked != null && picked != _selectedWhiteTime) {
      setState(() {
        _selectedWhiteTime = picked;
        _whiteTimeController.text = _selectedWhiteTime!.format(context);
        // You can use _selectedTime to perform further actions with the chosen time
      });
    }
  }

  Future<void> _selectBlackTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedBlackTime ?? TimeOfDay.now(),
      useRootNavigator: false, // Add this line
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedBlackTime) {
      setState(() {
        _selectedBlackTime = picked;
        _blackTimeController.text = _selectedBlackTime!.format(context);
        // You can use _selectedTime to perform further actions with the chosen time
      });
    }
  }

  Future<void> _showDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder(
            future: Future.delayed(Duration.zero),
            builder: (context, snapshot) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                title: Text('Set Timer'),
                content: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:  BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.3),
                    child: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: TextField(
                                    controller: _whiteTimeController,
                                    keyboardType: TextInputType.datetime,
                                    inputFormatters: [
                                      _TimeInputFormatter(),
                                    ],
                                    decoration: InputDecoration(
                                      labelText: "White",
                                      hintText: "mm:ss",
                                      border: OutlineInputBorder(),
                                      suffixIcon: GestureDetector(
                                        onTap: () {
                                          _selectWhiteTime(context);
                                        },
                                        child: Icon(Icons.timer),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  flex: 1,
                                  child: TextField(
                                    controller: _blackTimeController,
                                    keyboardType: TextInputType.datetime,
                                    inputFormatters: [
                                      _TimeInputFormatter(),
                                    ],
                                    decoration: InputDecoration(
                                      labelText: "Black",
                                      hintText: "mm:ss",
                                      border: OutlineInputBorder(),
                                      suffixIcon: GestureDetector(
                                        onTap: () {
                                          _selectBlackTime(context);
                                        },
                                        child: Icon(Icons.timer),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            _DialogContents(
                              key: UniqueKey(),
                              selectedValue: selectedValue,
                              onChanged: (String newValue) {
                                setState(() {
                                  selectedValue = newValue;
                                });
                              },
                            ),
                            SizedBox(height: 10),
                            if (selectedValue == 'Increment' ||
                                selectedValue == 'Decrement')
                              Expanded(
                                flex: 1,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setState(() {
                                      _additionalTime = int.tryParse(value) ?? 0;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText: "Time",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
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
                      setState(() {
                        _whiteSeconds = _parseTime(_whiteTimeController.text);
                        _blackSeconds = _parseTime(_blackTimeController.text);
                        // Use _parseTime for the additional time field if needed
                        if (_whiteSeconds == 0 || _blackSeconds == 0) {
                          // Show toast message
                          Fluttertoast.showToast(
                            msg: "Time should not be zero",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.TOP_RIGHT,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        } else {
                          Navigator.pop(context);
                        }
                      });
                    },
                    child: Text('Set'),
                  ),
                ],
              );
            });
      },
    );
  }

  int _parseTime(String timeString) {
    List<String> parts = timeString.split(':');
    if (parts.length != 2) {
      // Invalid format, return 0 or handle it accordingly
      return 0;
    }
    try {
      int minutes = int.parse(parts[0]);
      int seconds = int.parse(parts[1]);

      // Check if the values are within a valid range
      if (minutes < 0 || seconds < 0 || seconds >= 60) {
        return 0; // Invalid values, return 0 or handle it accordingly
      }

      return minutes * 60 + seconds;
    } catch (e) {
      return 0; // Parsing error, return 0 or handle it accordingly
    }
  }

  Future<void> play() async {
    log("im here");
    await AssetsAudioPlayer.newPlayer().open(
      Audio('assets/sound/gun.mp3'),
    );
  }

  Future<void> reload() async {
    await AssetsAudioPlayer.newPlayer().open(
      Audio('assets/sound/reload.mp3'),
    );
  }

  Future<void> stop() async {
    await AssetsAudioPlayer.newPlayer().open(
      Audio('assets/sound/beep.mp3'),
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
                  _isWhiteTurn == true && _whiteSeconds != 0
                      ? setState(() {
                        selectedValue == "Increment" ? _whiteSeconds += _additionalTime : " ";
                        selectedValue == "Decrement" ? _whiteSeconds -= _additionalTime : " ";
                          play();
                          _isWhiteTurn = false;
                          _isBlackTurn = true;
                          _startTimer();
                          _whiteCount++;
                        })
                      : '';
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.39,
                  color: _isWhiteTurn == true
                      ? _whiteSeconds < 10
                          ? Colors.red
                          : Color(0xFF00CC00)
                      : Colors.white,
                  child: Center(
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationZ(3.14159),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${(_whiteSeconds ~/ 60).toString().padLeft(2, '0')}:${(_whiteSeconds % 60).toString().padLeft(2, '0')}",
                            style: TextStyle(
                                fontSize: 50, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Moves: " "${_whiteCount}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      _isStarted == true
                          ? ElevatedButton(
                              onPressed: () {
                                _whiteSeconds == 00 || _blackSeconds == 00
                                    ? Fluttertoast.showToast(
                                        msg: "Time Should not be 0.",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.TOP_RIGHT,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 16.0)
                                    : setState(() {
                                        _isStarted = false;
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
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.green),
                            )
                          : ElevatedButton(
                              onPressed: () {},
                              child: Text(
                                "Start",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.grey),
                            ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
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
                  _isStarted == true
                      ? ElevatedButton(
                          onPressed: () {
                            _showDialog();
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
                      : ElevatedButton(
                          onPressed: () {},
                          child: Text(
                            "Time",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                          style: ElevatedButton.styleFrom(primary: Colors.grey),
                        )
                ],
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  _isBlackTurn == true && _blackSeconds != 0
                      ? setState(() {
                    selectedValue == "Increment" ? _blackSeconds += _additionalTime : " ";
                    selectedValue == "Decrement" ? _blackSeconds -= _additionalTime : " ";
                          play();
                          _isBlackTurn = false;
                          _isWhiteTurn = true;
                          _startTimer();
                          _blackCount++;
                        })
                      : '';
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.39,
                  color: _isBlackTurn == true
                      ? _blackSeconds < 10
                          ? Colors.red
                          : Color(0xFF00CC00)
                      : Colors.black,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${(_blackSeconds ~/ 60).toString().padLeft(2, '0')}:${(_blackSeconds % 60).toString().padLeft(2, '0')}",
                          style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Text(
                          "Moves: " + "${_blackCount}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.white),
                        ),
                      ],
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

class _DialogContents extends StatefulWidget {
  final String selectedValue;
  final Function(String) onChanged;

  _DialogContents({
    Key? key,
    required this.selectedValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  __DialogContentsState createState() => __DialogContentsState();
}

class __DialogContentsState extends State<_DialogContents> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButton<String>(
          isExpanded: true,
          underline: Container(),
          value: widget.selectedValue,
          onChanged: (String? newValue) {
            widget.onChanged(newValue!);
          },
          items: <String>['Default', 'Increment', 'Decrement']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _TimeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text;

    if (text.length == 3 && !text.contains(':')) {
      // Insert ':' after the first two characters
      final updatedText = text.substring(0, 2) + ':' + text.substring(2);

      return TextEditingValue(
        text: updatedText,
        selection: TextSelection.collapsed(offset: updatedText.length),
      );
    } else if (text.length > 5) {
      // Limit the length to 5 characters (mm:ss)
      return TextEditingValue(
        text: text.substring(0, 5),
        selection: TextSelection.collapsed(offset: 5),
      );
    } else {
      return newValue;
    }
  }
}

