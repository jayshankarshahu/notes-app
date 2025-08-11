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
      debugShowCheckedModeBanner: false
    );
  }
}

class NotesPage extends StatefulWidget {
  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  Future<List<Map<String, dynamic>>> notes = NotesDatabase.getAllNotes();

  Future<void> refreshPage() async {
    
    await readCacheAndUpdateStorage();
    
    setState(() {
      NotesDatabase.deleteEmpty();
      notes = NotesDatabase.getAllNotes();
    });

  }

  @override
  void initState() {
    NotesDatabase.deleteEmpty();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('All Notes')),
      body: Padding(
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

                    return Card(
                      color: Colors.amber[100],
                      child: GestureDetector(
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return EditNotePage(noteId: currentNote['id']);
                              },
                            ),
                          ).then((_) {
                            refreshPage();
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
    );
  }
}
