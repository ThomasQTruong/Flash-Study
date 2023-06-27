import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flash_study/pages/settings_page.dart';
import 'package:flash_study/objects/flashcard_set.dart';
import 'package:flash_study/data/user_data.dart';
import 'package:flash_study/utils/useful_widgets.dart';
import 'package:flash_study/utils/simple_sqflite.dart';
import 'package:flash_study/utils/max_lines_formatter.dart';
import 'package:flash_study/utils/max_length_per_line_formatter.dart';


late FlashcardSet _setLinked;
int _currentIndex = 0;
bool _currentFaceFront = true;
bool _enabledEditing = false;
TextEditingController? _cardController;


class FlashcardsPage extends StatefulWidget {
  FlashcardsPage({super.key, required this.title}) {
    _setLinked = UserData.listOfSets.getByName(title)!;
    _currentIndex = 0;
    _currentFaceFront = true;
    _cardController = TextEditingController(
      text: _setLinked.flashcards.isEmpty ? ""
          : _setLinked.flashcards[_currentIndex].front
    );
  }

  // Fields in a Widget subclass are always marked "final".
  final String title;

  @override
  State<FlashcardsPage> createState() => _FlashcardsPageState();
}


class _FlashcardsPageState extends State<FlashcardsPage> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();

    controller = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Load settings from Firebase if any.
      setState(() {});
    });
  }


  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 2.0,
        shadowColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 26.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          // Settings button.
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SettingsPage(title: "Settings")
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _setLinked.flashcards.isNotEmpty ? currentFlashcard()
                : const Text("Empty", style: TextStyle(fontSize: 45.0)),
            Visibility(
              visible: _setLinked.flashcards.isNotEmpty,
              child: Text("${_currentIndex + 1}/${_setLinked.numberOfCards}"),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InkWell(
            onTap: () {
              _enabledEditing = !_enabledEditing;
              if (!_enabledEditing) {
              _currentFaceFront ? _setLinked.flashcards[_currentIndex].front = _cardController!.text :
              _setLinked.flashcards[_currentIndex].back = _cardController!.text;
              }
              setState(() {});
            },
            customBorder: const CircleBorder(),
            child: Text("Edit"),
          ),
          InkWell(
            onTap: () {
              // Create card and add to SQLite database.
              SimpleSqflite.addFlashcard(_setLinked.create());
              setState(() {});
            },
            customBorder: const CircleBorder(),
            child: UsefulWidgets.addButtonDesign(),
          ),
        ],
      ),
    );
  }


  Widget currentFlashcard() {
    return GestureDetector(
      onTap: () {
        if (_enabledEditing) {
          return;
        }

        Feedback.forTap(context);
        _currentFaceFront = !_currentFaceFront;
        setState(() {});
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (_enabledEditing) {
          return;
        }

        // Swiping in left direction: next.
        if (details.primaryVelocity! < 0.0) {
          Feedback.forTap(context);
          _currentIndex = (_currentIndex + 1) % _setLinked.flashcards.length;
          setState(() {});
        }

        // Swiping in right direction: previous.
        if (details.primaryVelocity! > 0.0) {
          Feedback.forTap(context);
          _currentIndex = _currentIndex - 1;
          if (_currentIndex < 0) {
            _currentIndex = _setLinked.flashcards.length - 1;
          }
          setState(() {});
        }
      },
      child: Card(
        elevation: 5.0,
        child: SizedBox(
          width: 450.0,
          height: 258.0,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.only(
                left: 8.0, top: _enabledEditing ? 0.0 : 3.0,
              ),
              child: _enabledEditing ? TextField(
                controller: _cardController,
                keyboardType: TextInputType.multiline,
                maxLines: 8,
                style: const TextStyle(
                  fontSize: 20.5,
                  height: 1.5,
                  letterSpacing: 0.0,
                  fontFeatures: [
                    FontFeature.tabularFigures(),
                  ],
                ),
                inputFormatters: [
                  MaxLinesTextInputFormatter(8, () {}),
                  MaxLengthPerLineFormatter(36, () {}),
                ],
                decoration: const InputDecoration.collapsed(hintText: ""),
              ) : Text(
                  _currentFaceFront ? _setLinked.flashcards[_currentIndex].front
                      : _setLinked.flashcards[_currentIndex].back,
                  style: const TextStyle(
                    fontSize: 20.5,
                    height: 1.5,
                    letterSpacing: 0.0,
                    fontFeatures: [
                      FontFeature.tabularFigures(),
                    ],
                  ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}