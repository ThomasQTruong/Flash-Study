import 'package:flash_study/flashcard_set.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';

void main() {
  runApp(const MyApp());
}

enum MenuItem {
  item1,
  item2,
  item3,
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flash Study',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.

        // Light mode color scheme.
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 133, 218, 255)),

        // Dark mode color scheme.
        // colorScheme: const ColorScheme.dark(primary: Colors.white),

        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Sets'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<FlashcardSet> listOfSets = List.empty(growable: true);
  int _counter = 0;

  void _incrementCounter() {
    listOfSets.add(FlashcardSet(name: _counter.toString()));
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 26,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          // Settings button.
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            listOfSets.isEmpty ? const Text("Empty") :
                Expanded(
                  child: ListView.builder(
                    itemCount: listOfSets.length,
                    itemBuilder: (context, index) => getRow(index),
                  ),
                ),
            Container(
              margin: const EdgeInsets.only(bottom: 15),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(100)),
                color: Colors.lightGreen,
              ),
              padding: EdgeInsets.zero,
              child: PopupMenuButton<MenuItem>(
                onSelected: (value) async {
                  if (value == MenuItem.item1) {
                    _incrementCounter();
                  } else if (value == MenuItem.item2) {
                    final result = await FilePicker.platform.pickFiles();
                    if (result == null) {
                      displayMessage("Import cancelled.");
                      return;
                    }

                    final file = result.files.first;
                    if (file.extension != "json") {
                      displayMessage("Imported file is invalid.");
                      return;
                    }
                    openFile(file);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: MenuItem.item1,
                    child: Text(
                        "Create"
                    ),
                  ),
                  const PopupMenuItem(
                    value: MenuItem.item2,
                    child: Text(
                        "Import"
                    ),
                  ),
                ],
                tooltip: 'Add Set',
                child: const Icon(
                  Icons.add,
                  size: 50,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getRow(int index) {
    return Card(
      child: ListTile(
        title: Column(
          children: [
            Text(
              listOfSets[index].name,
              style: const TextStyle(
                fontSize: 22,
              )
            ),
          ],
        ),
      ),
    );
  }

  void openFile(PlatformFile file) {
    OpenFile.open(file.path);
  }

  void displayMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          height: 50,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Center(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          ),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),
    );
  }
}
