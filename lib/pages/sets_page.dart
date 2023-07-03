import 'package:flash_study/objects/flashcard_set.dart';
import 'package:flash_study/data/user_data.dart';
import 'package:flash_study/pages/flashcards_page.dart';
import 'package:flash_study/utils/palette.dart';
import 'package:flash_study/utils/useful_widgets.dart';
import 'package:flash_study/utils/simple_sqflite.dart';
import 'package:flash_study/utils/simple_firebase.dart';
import 'package:flash_study/pages/settings_page.dart';
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
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();

    controller = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Logged in, load from Firestore.
      if (SimpleFirebase.isLoggedIn()) {
        await SimpleFirebase.loadSets();

        // Sync loaded data with SQLite.
        await SimpleSqflite.clearDatabase();
        await SimpleSqflite.addAll();
      } else {
        // Not logged in, load from SQLite.
        await SimpleSqflite.loadSets();
      }

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
      appBar: AppBar(
        elevation: 2.0,
        shadowColor: Theme.of(context).colorScheme.inversePrimary,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
            Expanded(
              child: UserData.listOfSets.isEmpty() ? const Center(
                child: Text(
                  "Empty",
                  style: TextStyle(
                    fontSize: 45.0,
                  ),
                ),
              ) : Scrollbar(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80.0),
                  itemCount: UserData.listOfSets.length(),
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
          // Get name from user.
          final setName = await getSetName("Create");
          if (setName == null) {
            return;
          }
          // Set names are supposed to be unique.
          if (UserData.listOfSets.hasSetNamed(setName)) {
            displayMessage("Set name already exists!");
            return;
          }
          if (setName == "") {
            displayMessage("Set name cannot be blank!");
            return;
          }

          FlashcardSet setToAdd = FlashcardSet(name: setName,
                index: UserData.getNumberOfSets());

          await UserData.listOfSets.add(setToAdd);
          setState(() {});

          // Save data.
          await SimpleFirebase.saveSets();
          await SimpleSqflite.addSet(UserData.listOfSets.getLast());
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

          // TODO: import set.
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
      child: UsefulWidgets.addButtonDesign(),
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
          if (UserData.listOfSets.hasSetNamed(setName)) {
            controller.clear();
            displayMessage("Set name already exists!");
            return;
          }
          if (setName == "") {
            controller.clear();
            displayMessage("Set name cannot be blank!");
            return;
          }

          String oldName = UserData.listOfSets.getNameAt(index);
          setState(() => UserData.listOfSets.setNameAt(index, setName));

          // Update in databases.
          await SimpleFirebase.saveSets();
          await SimpleSqflite.updateSetName(oldName,
                                      UserData.listOfSets.getAt(index));
        } else if (value == MoreActionsMenuItems.export) {
          // TODO: export set.
        }
        else if (value == MoreActionsMenuItems.delete) {
          final deleteConfirmed = await getDeleteConfirmation(index);
          if (deleteConfirmed == true) {
            FlashcardSet removed = await UserData.listOfSets.removeAt(index);
            await UserData.listOfSets.updateIndexes(index);
            setState(() {});

            // Update in databases.
            await SimpleFirebase.saveSets();
            await SimpleSqflite.deleteSet(removed);
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
      elevation: 5.0,
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FlashcardsPage(
                title: UserData.listOfSets.getNameAt(index),
              ),
            ),
          ).then((_) {
            setState(() {});
          });
        },
        // Set name.
        title: Text(
          UserData.listOfSets.getNameAt(index),
          style: const TextStyle(
            fontSize: 22.0,
          ),
        ),
        // Number of cards in set.
        subtitle: Text(
          "${UserData.listOfSets.getNumberOfCardsAt(index)} Cards",
          style: TextStyle(
            color: Theme.of(context).textTheme.displaySmall
                                    ?.color?.withOpacity(0.6),
          ),
        ),
        // Action buttons.
        trailing: FittedBox(
          child: Row(
            children: [
              // Not first item, add up arrow.
              index > 0 ? InkWell(
                onTap: () async {
                  await UserData.listOfSets.moveSetUpAt(index);
                  // Update databases when moving up.
                  await SimpleFirebase.saveSets();
                  await SimpleSqflite.swapSets(index - 1, index);
                  setState(() {});
                },
                child: const Icon(Icons.arrow_upward),
              ) : const Opacity(
                opacity: 0.0,
                child: Icon(Icons.arrow_upward),
              ),

              // Not last item, add down arrow.
              index < UserData.listOfSets.length() - 1 ? InkWell(
                onTap: () async {
                  await UserData.listOfSets.moveSetDownAt(index);
                  // Update databases when moving down.
                  await SimpleFirebase.saveSets();
                  await SimpleSqflite.swapSets(index, index + 1);

                  setState(() {});
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
          height: 50.0,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          child: Center(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 20.0,
              ),
            ),
          ),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0.0,
      ),
    );
  }


  Future<String?> getSetName(String action) => showDialog<String>(
    context: context,
    builder: (context) => Center(
      child: SingleChildScrollView(
        // physics: const NeverScrollableScrollPhysics(),
        child: AlertDialog(
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
      ),
    ),
  );


  Future<bool?> getDeleteConfirmation(index) => showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
        title: Text(
          "Are you sure you want to delete: ${UserData.listOfSets.getNameAt(index)}?",
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
                color: Palette.deleteColor,
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
