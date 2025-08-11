import 'package:flutter/material.dart';
import 'storage.dart';
import 'editnotes.dart';
import 'theme.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

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

  Set<int> selectedNotes = {};
  String searchQuery = '';

  late FocusNode searchFocusNode;
  late TextEditingController searchEditingController;

  Future<List<Map<String, dynamic>>> notes = NotesDatabase.getAllNotes();

  Future<void> refreshPage() async {
    await readCacheAndUpdateStorage();

    setState(() {
      NotesDatabase.deleteEmpty();
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

    notes = NotesDatabase.getAllNotes(searchQuery: searchQuery);

    PreferredSizeWidget appBar;

    isSelectModeOn = selectedNotes.isNotEmpty;
    isSearchModeOn = searchQuery.isNotEmpty;

    if (isSelectModeOn) {
      appBar = AppBar(
        title: Text("${selectedNotes.length.toString()} Notes Selected"),
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
        title: Container(
          child: TextField(
            focusNode: searchFocusNode,
            decoration: InputDecoration(
              hintText: 'Search notes...',
              hintStyle: TextStyle(color: Theme.of(context).hintColor),
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context).hintColor,
              ),
              border: InputBorder.none, // No inner borders for cleaner look
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            controller: searchEditingController,
          ),
        ),
        actions: actions,
      );
    }

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

                  return RefreshIndicator(
                    onRefresh: refreshPage,
                    child: GridView.builder(
                      itemCount: notes.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Two columns
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1.1,
                      ),
                      itemBuilder: (context, index) {
                        final currentNote = notes[index];

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

                        return Card(
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
                            onLongPress: () => {
                              setState(() {
                                selectedNotes.add(currentNote['id']);
                              }),
                            },
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                currentNote['body'],
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
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
