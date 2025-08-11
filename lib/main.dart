import 'package:flutter/material.dart';
import 'storage.dart';
import 'editnotes.dart';
import 'theme.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

extension StringCasingExtension on String {
  String capitalize() {
    if (isEmpty) {
      return this;
    }
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  prefs = await SharedPreferences.getInstance(); //assign only if null

  Timer.periodic(Duration(seconds: 10), (timer) {
    readCacheAndUpdateStorage();
  });

  runApp(NotesApp());
}

class NotesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NotesPage(),
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
    );
  }
}

class NotesPage extends StatefulWidget {
  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  bool isSelectModeOn = false;
  bool isSearchModeOn = false;
  bool hasSearchQueryChanged = false;

  Set<int> selectedNotes = {};
  String searchQuery = '';

  late FocusNode searchFocusNode;
  late TextEditingController searchEditingController;

  Future<List<Map<String, dynamic>>> notes = NotesDatabase.getAllNotes();

  Future<void> refreshPage() async {
    await readCacheAndUpdateStorage();

    setState(() {
      NotesDatabase.deleteEmpty().then((value) {
        if (value == 0) {
          return;
        }

        if (!context.mounted) {
          return;
        }

      });
      notes = NotesDatabase.getAllNotes(searchQuery: searchQuery);
    });
  }

  @override
  void dispose() {
    searchFocusNode.dispose();
    searchEditingController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    searchFocusNode = FocusNode();
    searchEditingController = TextEditingController(text: searchQuery);

    NotesDatabase.deleteEmpty();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (hasSearchQueryChanged) {
      notes = NotesDatabase.getAllNotes(searchQuery: searchQuery);
    }

    hasSearchQueryChanged = false;

    PreferredSizeWidget appBar;

    isSelectModeOn = selectedNotes.isNotEmpty;
    isSearchModeOn = searchQuery.isNotEmpty;

    if (isSelectModeOn) {
      appBar = AppBar(
        title: Text(
          "${selectedNotes.length.toString()} Note${selectedNotes.length == 1 ? "" : "s"} Selected",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            // fontFeatures: [FontFeature()]
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      'Are you sure?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                        // fontFeatures: [FontFeature()]
                      ),
                      textAlign: TextAlign.start,
                    ),
                    content: Text(
                      "${selectedNotes.length.toString()} Note${selectedNotes.length == 1 ? "" : "s"} will be deleted.",
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Cancel',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.start,
                          maxLines: 1,
                        ),
                      ),
                      TextButton(
                        onPressed: () async {

                          await NotesDatabase.deleteNotes(List.from(selectedNotes));
                          
                          if( context.mounted ) {
                            Navigator.of(context).pop();
                          }

                          selectedNotes.clear();
                          
                          refreshPage();

                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: Icon(Icons.delete, color: Theme.of(context).hintColor),
          ),
        ],
        scrolledUnderElevation: 0,
      );
    } else {
      List<Widget> actions = [];

      if (isSearchModeOn) {
        actions.add(
          IconButton(
            onPressed: () {
              searchFocusNode.unfocus();

              setState(() {
                searchQuery = '';
                searchEditingController.clear();
              });
            },
            icon: Icon(Icons.close, color: Theme.of(context).hintColor),
          ),
        );
      }

      appBar = AppBar(
        title: TextField(
          focusNode: searchFocusNode,
          decoration: InputDecoration(
            hintText: 'Search notes...',
            hintStyle: TextStyle(color: Theme.of(context).hintColor),
            prefixIcon: Icon(Icons.search, color: Theme.of(context).hintColor),
            border: InputBorder.none, // No inner borders for cleaner look
            contentPadding: EdgeInsets.symmetric(vertical: 10),
          ),
          onChanged: (value) {
            setState(() {
              hasSearchQueryChanged = true;
              searchQuery = value;
            });
          },
          controller: searchEditingController,
        ),
        actions: actions,
        scrolledUnderElevation: 0,
      );
    }

    List<Widget> noteCards = [];

    return PopScope(
      canPop: !isSelectModeOn, //allow going back only when nothing is selected
      onPopInvokedWithResult: (didPop, result) {
        setState(() {
          selectedNotes.clear();
        });
      },
      child: Scaffold(
        appBar: appBar,
        body: GestureDetector(
          behavior: HitTestBehavior
              .opaque, // Ensures taps on empty space are detected
          onTap: searchFocusNode.unfocus,
          child: RefreshIndicator(
            onRefresh: refreshPage,
            child: Padding(
              padding: EdgeInsets.all(8),
              child: FutureBuilder(
                future: notes,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // While the future is loading
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    // If the future completed with error
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    // If the future completed with no data
                    return Center(child: Text('No notes found.'));
                  } else {
                    final notes = snapshot.data!;
                    List<int> noteIds = [];

                    for (var currentNote in notes) {
                      noteIds.add(currentNote['id']);

                      ShapeBorder? shape;

                      if (selectedNotes.contains(currentNote['id'])) {
                        shape = RoundedRectangleBorder(
                          side: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        );
                      }

                      List<Widget> cardChildren = [];

                      if (currentNote['title'].trim().isNotEmpty) {
                        cardChildren.add(
                          Text(
                            StringCasingExtension(
                              currentNote['title'],
                            ).capitalize().replaceAll(RegExp(r'\s+'), ' '),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              // fontFeatures: [FontFeature()]
                            ),
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        );
                      }

                      cardChildren.add(
                        Text(
                          currentNote['body'].replaceAll(RegExp(r'\s+'), ' '),
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 5,
                        ),
                      );

                      noteCards.add(
                        Card(
                          color: Theme.of(context).cardTheme.color,
                          shape: shape,

                          child: GestureDetector(
                            onTap: () => {
                              if (isSelectModeOn)
                                {                                  
                                  setState(() {
                                    if (selectedNotes.contains(
                                      currentNote['id'],
                                    )) {
                                      selectedNotes.remove(currentNote['id']);
                                    } else {
                                      selectedNotes.add(currentNote['id']);
                                    }
                                  }),
                                }
                              else
                                {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return EditNotePage(
                                          noteId: currentNote['id'],
                                        );
                                      },
                                    ),
                                  ).then((_) {
                                    refreshPage();
                                  }),
                                },
                            },
                            onLongPress: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                selectedNotes.add(currentNote['id']);
                              });
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: cardChildren,
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    //to prevent elements that are filtered through search to be deleted when delete is pressed
                    for (var noteId in selectedNotes) {
                      if (!noteIds.contains(noteId)) {
                        selectedNotes.remove(noteId);
                      }
                    }

                    return ListView(
                      primary: true,
                      // crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: noteCards,
                    );
                  }
                },
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return EditNotePage();
                  // int noteId = notes.length;
                  // notes.add('');

                  // return EditNotePage(
                  //   note: '',
                  //   onChange: (newNote) {
                  //     _changeNote(noteId, newNote);
                  //   },
                  // );
                },
              ),
            ).then((_) {
              refreshPage();
            });
          },
          child: Icon(Icons.add),
          tooltip: 'Add Note',
        ),
      ),
    );
  }
}
