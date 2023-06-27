import 'package:flutter/material.dart';
import 'package:flash_study/pages/settings_page.dart';
import 'package:flash_study/objects/flashcard_set.dart';
import 'package:flash_study/data/user_data.dart';
import 'package:flash_study/utils/useful_widgets.dart';


late FlashcardSet _setLinked;
int _currentIndex = 0;
bool _currentFaceFront = true;


class FlashcardsPage extends StatefulWidget {
  FlashcardsPage({super.key, required this.title}) {
    _setLinked = UserData.listOfSets.getByName(title)!;
    _currentIndex = 0;
    _currentFaceFront = true;
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
      floatingActionButton: InkWell(
        onTap: () {
          _setLinked.create();
          setState(() {});
        },
        customBorder: const CircleBorder(),
        child: UsefulWidgets.addButtonDesign(),
      ),
    );
  }


  Widget currentFlashcard() {
    return GestureDetector(
      onTap: () {
        Feedback.forTap(context);
        _currentFaceFront = !_currentFaceFront;
        setState(() {});
      },
      onHorizontalDragEnd: (DragEndDetails details) {
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
      child: SizedBox(
        width: 450.0,
        height: 250.0,
        child: Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ListTile(
                title: Text(
                  _currentFaceFront ? _setLinked.flashcards[_currentIndex].front
                      : _setLinked.flashcards[_currentIndex].back,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22.0,
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