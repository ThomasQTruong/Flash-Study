import 'package:flash_study/flashcard_set.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

enum AddSetMenu {
  create,
  import,
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flash Study",
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

        fontFamily: GoogleFonts.arvo().fontFamily,

        // Light mode color scheme.
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 133, 218, 255)),

        // Dark mode color scheme.
        // colorScheme: const ColorScheme.dark(primary: Colors.white),

        useMaterial3: true,
      ),
      home: const MyHomePage(title: "Sets"),
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
  late TextEditingController controller;
  String setName = "";
  bool deleteConfirmed = false;

  @override
  void initState() {
    super.initState();

    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
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
            Expanded(
              child: listOfSets.isEmpty ? const Center(
                child: Text(
                  "Empty",
                  style: TextStyle(
                    fontSize: 26,
                  ),
                ),
              ) : ListView.builder(
                itemCount: listOfSets.length,
                itemBuilder: (context, index) => getSetAsCard(index),
              ),
            ),

            /*
            listOfSets.isEmpty ? const Text(
                "Empty",
                style: TextStyle(
                  fontSize: 26,
                ),
              ) :
                Expanded(
                  child: ListView.builder(
                    itemCount: listOfSets.length,
                    itemBuilder: (context, index) => getSets(index),
                  ),
                ),*/
            Container(
              margin: const EdgeInsets.only(
                bottom: 15,
                top: 15,
              ),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(100)),
                color: Theme.of(context).canvasColor,
                border: Border.all(
                  color: Colors.lightGreen,
                  width: 5,
                ),
                /*
                boxShadow: [
                  BoxShadow(
                    color: Colors.lightGreen.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
                */
              ),
              padding: EdgeInsets.zero,
              child: PopupMenuButton<AddSetMenu>(
                onSelected: (value) async {
                  if (value == AddSetMenu.create) {
                    final setName = await getSetName("Create");
                    if (setName == null) {
                      return;
                    }

                    setState(() => this.setName = setName);
                    createSetByName(setName);
                  } else if (value == AddSetMenu.import) {
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
                    value: AddSetMenu.create,
                    child: Text(
                        "Create"
                    ),
                  ),
                  const PopupMenuItem(
                    value: AddSetMenu.import,
                    child: Text(
                        "Import"
                    ),
                  ),
                ],
                tooltip: 'Add Set',
                child: const Icon(
                  Icons.add,
                  color: Colors.lightGreen,
                  size: 50,
                  /*
                  shadows: <Shadow>[
                    Shadow(
                      color: Colors.lightGreen.withOpacity(0.5),
                      blurRadius: 7.0,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  */
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getSetAsCard(int index) {
    return Card(
      child: ListTile(
        title: Text(
          listOfSets[index].name,
          style: const TextStyle(
            fontSize: 22,
          ),
        ),
        subtitle: Text(
          "${listOfSets[index].numberOfCards} Cards",
          style: TextStyle(
            color: Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.6),
          ),
        ),
        trailing: SizedBox(
          width: 75,
          child: Row(
            children: [
              InkWell(
                  onTap: () async {
                    final setName = await getSetName("Edit");
                    // Cancelled action.
                    if (setName == null) {
                      controller.clear();
                      return;
                    }

                    setState(() => listOfSets[index].name = setName);
                  },
                  child: const Icon(Icons.edit),
              ),
              InkWell(
                onTap: () {

                },
                child: const Icon(Icons.download),
              ),
              InkWell(
                onTap: () async {
                  final deleteConfirmed = await getDeleteConfirmation(index);
                  if (deleteConfirmed == true) {
                    listOfSets.removeAt(index);
                  }

                  setState(() {
                  });
                },
                child: const Icon(Icons.delete),
              ),
            ],
          ),
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

  Future<String?> getSetName(String action) => showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Set Name"),
      surfaceTintColor: Theme.of(context).canvasColor,
      content: TextField(
        autofocus: true,
        decoration: const InputDecoration(hintText: "Enter set name."),
        controller: controller,
        onSubmitted: (_) => createSetButton(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            "Cancel",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextButton(
          onPressed: createSetButton,
          child: Text(
            action,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );

  Future<bool?> getDeleteConfirmation(index) => showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        "Are you sure you want to delete ${listOfSets[index].name}?",
        style: const TextStyle(
          // fontWeight: FontWeight.bold,
        ),
      ),
      surfaceTintColor: Theme.of(context).canvasColor,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(
            "Cancel",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text(
            "Delete",
            style: TextStyle(
              color: Color.fromARGB(255, 190, 0, 0),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ]
    ),
  );

  void createSetButton() {
    Navigator.of(context).pop(controller.text);

    controller.clear();
  }

  void createSetByName(String setName) {
    setState(() => listOfSets.add(FlashcardSet(name: setName)));
  }
}
