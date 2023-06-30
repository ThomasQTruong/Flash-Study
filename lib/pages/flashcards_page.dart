import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flash_study/pages/settings_page.dart';
import 'package:flash_study/objects/flashcard_set.dart';
import 'package:flash_study/data/user_data.dart';
import 'package:flash_study/utils/useful_widgets.dart';
import 'package:flash_study/utils/simple_sqflite.dart';


double _flashcardWidth = 450;
double _flashcardHeight = 258.0;


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
            SizedBox(
              width: _flashcardWidth,
              child: Row(
                children: [
                  InkWell(
                    onTap: editButton,
                    customBorder: const CircleBorder(),
                    child: const Icon(Icons.arrow_back, size: 20.0),
                  ),
                  InkWell(
                    onTap: () {
                    },
                    customBorder: const CircleBorder(),
                    child: const Icon(Icons.arrow_forward, size: 20.0),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: editButton,
                    customBorder: const CircleBorder(),
                    child: const Icon(Icons.edit, size: 20.0),
                  ),
                  InkWell(
                    onTap: () {},
                    customBorder: const CircleBorder(),
                    child: const Icon(Icons.delete, size: 20.0),
                  ),
                ],
              ),
            ),
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
          // InkWell(
          //   onTap: editButton,
          //   customBorder: const CircleBorder(),
          //   child: const Icon(Icons.edit),
          // ),
          InkWell(
            onTap: () async {
              // Create card and add to SQLite database.
              await SimpleSqflite.addFlashcard(_setLinked.create());
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
          _currentFaceFront = true;
          _currentIndex = (_currentIndex + 1) % _setLinked.flashcards.length;
          setState(() {});
        }

        // Swiping in right direction: previous.
        if (details.primaryVelocity! > 0.0) {
          Feedback.forTap(context);
          _currentFaceFront = true;
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
          width: _flashcardWidth,
          height: _flashcardHeight,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                left: 8.0,
                right: 2.0,
                top: _enabledEditing ? 0.0 : 3.0,
              ),
              child: _enabledEditing ? TextField(
                autofocus: true,
                controller: _cardController,
                keyboardType: TextInputType.multiline,
                maxLines: 10,
                style: const TextStyle(
                  fontSize: 20.5,
                  height: 1.5,
                  letterSpacing: 0.0,
                  fontFeatures: [
                    FontFeature.tabularFigures(),
                  ],
                ),
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

  void editButton() {
    _enabledEditing = !_enabledEditing;
    if (!_enabledEditing) {
      // Not editing anymore, save user input.
      _currentFaceFront ? _setLinked.flashcards[_currentIndex].front = _cardController!.text :
      _setLinked.flashcards[_currentIndex].back = _cardController!.text;

      // Save to databases too.
      SimpleSqflite.updateFlashcard(_setLinked.flashcards[_currentIndex]);
    } else {
      // If user is editing, set the current onscreen text into controller.
      _cardController?.text = _currentFaceFront ? _setLinked.flashcards[_currentIndex].front :
      _setLinked.flashcards[_currentIndex].back;
    }
    setState(() {});
  }
}