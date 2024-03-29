import 'dart:convert';
import 'dart:io';
import 'package:flash_study/objects/flashcard_set.dart';
import 'package:flash_study/data/user_data.dart';
import 'package:flash_study/pages/flashcards_page.dart';
import 'package:flash_study/utils/palette.dart';
import 'package:flash_study/utils/useful_widgets.dart';
import 'package:flash_study/utils/simple_sqflite.dart';
import 'package:flash_study/utils/simple_firebase.dart';
import 'package:flash_study/objects/flashcard.dart';
import 'package:flash_study/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';


/// App/data still loading?
bool _loading = true;


/// Types of buttons for the Add Set menu.
enum AddSetMenuItems {
  create,
  import,
}


/// Types of buttons for the More Actions menu.
enum MoreActionsMenuItems {
  edit,
  export,
  delete,
}


/// The page with all of the sets.
class SetsPage extends StatefulWidget {
  const SetsPage({super.key, required this.title});

  // Fields in a Widget subclass are always marked "final".
  final String title;

  @override
  State<SetsPage> createState() => _SetsPageState();
}


class _SetsPageState extends State<SetsPage> {
  // Used to get user's input for set names.
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();

    controller = TextEditingController();

    // What to do after the page loads.
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

      // Not loading anymore.
      _loading = false;

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
    return Stack(
      children: [
        // Sets page.
        Scaffold(
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
                  ).then((_) {
                    setState(() {});
                  });
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
        ),
        // Loading screen.
        Visibility(
          visible: _loading,
          child: Container(
            alignment: Alignment.center,
            color: Colors.white70,
            child: const CircularProgressIndicator(),
          ),
        ),
      ],
    );
  }


  /// Add Set Button widget with a popup menu.
  PopupMenuButton<AddSetMenuItems> addSetButtonAndMenu() {
    return PopupMenuButton<AddSetMenuItems>(
      // Actions when an item is selected.
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
          FlashcardSet? importedSet = await importPressed();
          if (importedSet == null) {
            return;
          }

          // Save to databases.
          await SimpleFirebase.saveSets();
          await SimpleSqflite.addSet(importedSet);
          for (Flashcard card in importedSet.flashcards) {
            await SimpleSqflite.addFlashcard(card);
          }
        }
      },
      // Creates the menu.
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


  /// More Actions Button widget with popup menu.
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
          // Set name already exists.
          if (UserData.listOfSets.hasSetNamed(setName)) {
            controller.clear();
            displayMessage("Set name already exists!");
            return;
          }
          // Blank set name.
          if (setName == "") {
            controller.clear();
            displayMessage("Set name cannot be blank!");
            return;
          }

          // Proper set name, update.
          String oldName = UserData.listOfSets.getNameAt(index);
          setState(() => UserData.listOfSets.setNameAt(index, setName));

          // Update in databases.
          await SimpleFirebase.saveSets();
          await SimpleSqflite.updateSetName(oldName,
                                      UserData.listOfSets.getAt(index));
        } else if (value == MoreActionsMenuItems.export) {
          exportPressed(UserData.listOfSets.getAt(index));
        }
        else if (value == MoreActionsMenuItems.delete) {
          final deleteConfirmed = await getDeleteConfirmation(index);

          // User confirmed to delete.
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


  /// Turns a set into a card.
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
                  await SimpleSqflite.updateSwappedSets(index - 1, index);
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
                  await SimpleSqflite.updateSwappedSets(index, index + 1);

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


  /// Displays a messgae to the screen.
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


  /// Asks the user to input the name for a set.
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


  /// Gets user's confirmation on deleting a set.
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


  /// When the create set button is pressed.
  void createSetButton() {
    Navigator.of(context).pop(controller.text);

    controller.clear();
  }


  /// When the export button is pressed.
  Future<void> exportPressed(FlashcardSet set) async {
    final box = context.findRenderObject() as RenderBox?;
    final temp = await getTemporaryDirectory();
    final path = "${temp.path}/${set.name}.json";
    var jsonEncoder = JsonEncoder.withIndent(" " * 4);
    await File(path).writeAsString(jsonEncoder.convert(set.exportToJson())
                                                          .toString());

    await Share.shareXFiles(
      [XFile(path)],
      subject: "${set.name}.json",
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }


  /// When the import button is pressed.
  Future<FlashcardSet?> importPressed() async {
    // Let user choose file.
    final result = await FilePicker.platform.pickFiles();
    if (result == null) {
      displayMessage("Import cancelled.");
      return null;
    }

    // Invalid file type.
    final file = result.files.first;
    if (file.extension != "json") {
      displayMessage("Imported file is invalid.");
      return null;
    }

    // Map json file.
    final fileConverted = File(file.path.toString());
    String jsonString = await fileConverted.readAsString();
    Map<String, dynamic> json = await jsonDecode(jsonString);

    // Set already exists.
    if (UserData.listOfSets.hasSetNamed(json["name"])) {
      displayMessage("${json["name"]} already exists.");
      return null;
    }

    // Load and save set.
    FlashcardSet set = FlashcardSet.importFromJson(json);
    await UserData.listOfSets.add(set);

    // Load flashcards.
    for (var cardJson in List.of(json["flashcards"])) {
      set.add(Flashcard.importFromJson(cardJson));
    }

    setState(() {});

    return set;
  }
}
