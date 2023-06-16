import 'package:flash_study/objects/flashcard_set.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';

enum AddSetMenuItems {
  create,
  import,
}


enum MoreActionsMenuItems {
  edit,
  export,
  delete,
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
              ) : Scrollbar(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: listOfSets.length,
                  itemBuilder: (context, index) => getSetAsCard(index),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: addSetButtonAndMenu(),
    );
  }


  PopupMenuButton<AddSetMenuItems> addSetButtonAndMenu() {
    return PopupMenuButton<AddSetMenuItems>(
      onSelected: (value) async {
        if (value == AddSetMenuItems.create) {
          final setName = await getSetName("Create");
          if (setName == null) {
            return;
          }

          setState(() => listOfSets.add(FlashcardSet(name: setName)));
        } else if (value == AddSetMenuItems.import) {
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
          value: AddSetMenuItems.create,
          child: Row(
            children: [
              Icon(Icons.add),
              Text("  "),
              Text(
                "Create",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuItem(
          value: AddSetMenuItems.import,
          child: Row(
            children: [
              Icon(Icons.upload),
              Text("  "),
              Text(
                "Import",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
      tooltip: "Add Set",
      child: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          color: Colors.lightGreen,
          borderRadius: BorderRadius.all(Radius.circular(100)),
        ),
        child: Icon(
          Icons.add,
          color: Theme.of(context).canvasColor,
          size: 50,
        ),
      ),
    );
  }


  PopupMenuButton<MoreActionsMenuItems> moreActionsButtonAndMenu(index) {
    return PopupMenuButton<MoreActionsMenuItems>(
      // When action is selected.
      onSelected: (value) async {
        if (value == MoreActionsMenuItems.edit) {
          final setName = await getSetName("Edit");
          // Cancelled action.
          if (setName == null) {
            controller.clear();
            return;
          }

          setState(() => listOfSets[index].name = setName);
        } else if (value == MoreActionsMenuItems.export) {
          // TODO: code export.
        }
        else if (value == MoreActionsMenuItems.delete) {
          final deleteConfirmed = await getDeleteConfirmation(index);
          if (deleteConfirmed == true) {
            setState(() => listOfSets.removeAt(index));
          }
        }
      },
      // Create menu.
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: MoreActionsMenuItems.edit,
          child: Row(
            children: [
              Icon(Icons.edit),
              Text("  "),  // Spacing in-between.
              Text(
                "Edit",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuItem(
          value: MoreActionsMenuItems.export,
          child: Row(
            children: [
              Icon(Icons.download),
              Text("  "),  // Spacing in-between.
              Text(
                "Export",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuItem(
          value: MoreActionsMenuItems.delete,
          child: Row(
            children: [
              Icon(Icons.delete),
              Text("  "),  // Spacing in-between.
              Text(
                "Delete",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
      tooltip: "More Actions",
      child: const Icon(Icons.more_vert),
    );
  }


  Widget getSetAsCard(int index) {
    return Card(
      child: ListTile(
        // Set name.
        title: Text(
          listOfSets[index].name,
          style: const TextStyle(
            fontSize: 22,
          ),
        ),
        // Number of cards in set.
        subtitle: Text(
          "${listOfSets[index].numberOfCards} Cards",
          style: TextStyle(
            color: Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.6),
          ),
        ),
        // Action buttons.
        trailing: FittedBox(
          child: Row(
            children: [
              // Not first item, add up arrow.
              index > 0 ? InkWell(
                onTap: () {
                  setState(() => moveSetUp(index));
                },
                child: const Icon(Icons.arrow_upward),
              ) : const Opacity(
                opacity: 0.0,
                child: Icon(Icons.arrow_upward),
              ),

              // Not last item, add down arrow.
              index < listOfSets.length - 1 ? InkWell(
                onTap: () async {
                  setState(() => moveSetDown(index));
                },
                child: const Icon(Icons.arrow_downward),
              ) : const Opacity(
                opacity: 0.0,
                child: Icon(Icons.arrow_downward),
              ),

              // More button and menu.
              moreActionsButtonAndMenu(index),
            ],
          ),
        ),
      ),
    );
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
          "Are you sure you want to delete: ${listOfSets[index].name}?",
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


  bool moveSetUp(index) {
    // First set, cannot move any higher.
    if (index <= 0) {
      return false;
    }

    // Switch sets.
    FlashcardSet previousSet = listOfSets[index - 1];
    listOfSets[index - 1] = listOfSets[index];
    listOfSets[index] = previousSet;

    return true;
  }


  bool moveSetDown(index) {
    // Last set, cannot move any lower.
    if (index >= listOfSets.length - 1) {
      return false;
    }

    // Switch sets.
    FlashcardSet nextSet = listOfSets[index + 1];
    listOfSets[index + 1] = listOfSets[index];
    listOfSets[index] = nextSet;

    return true;
  }
}
