import 'package:flash_study/objects/flashcard_set.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';

enum AddSetMenu {
  create,
  import,
}


class SetsPage extends StatefulWidget {
  const SetsPage({super.key, required this.title});

  // Fields in a Widget subclass are always marked "final".
  final String title;

  @override
  State<SetsPage> createState() => _SetsPageState();
}


class _SetsPageState extends State<SetsPage> {
  List<FlashcardSet> listOfSets = List.empty(growable: true);
  late TextEditingController controller;


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
    // This method is rerun every time setState is called.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
        child: Column(
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

                    setState(() => listOfSets.add(FlashcardSet(name: setName)));
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
                    OpenFile.open(file.path);
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
                  size: 45,
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
                    setState(() => listOfSets.removeAt(index));
                  }
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
}
