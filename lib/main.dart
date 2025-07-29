import 'package:flutter/material.dart';
import 'editnotes.dart';

void main() => runApp(NotesApp());

class NotesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: NotesPage(), debugShowCheckedModeBanner: false);
  }
}

class NotesPage extends StatefulWidget {
  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  // Some sample notes to display
  List<String> notes = [
    "Buy groceries again",
    "Read Flutter docs",
    "Finish project",
    "Write test cases",
    "Call Alice",
    "Water plants",
  ];

  void _addNote(String newNote) {
    setState(() {
      notes.add(newNote);
    });
  }

  void _changeNote(int index, String updatedNote) {
    setState(() {
      notes[index] = updatedNote;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('All Notes')),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: GridView.builder(
          itemCount: notes.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two columns
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.1,
          ),
          itemBuilder: (context, index) {
            return Card(
              color: Colors.amber[100],
              child: GestureDetector(
                onTap: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditNotePage(
                        note: notes[index],
                        onChange: (updatedNote) {
                          _changeNote(index, updatedNote);
                        },
                      ),
                    ),
                  ),
                },
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(notes[index], style: TextStyle(fontSize: 18)),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                int noteId = notes.length;
                notes.add('');

                return EditNotePage(
                  note: '',
                  onChange: (newNote) {
                    _changeNote(noteId, newNote);
                  },
                );
              },
            ),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Add Note',
      ),
    );
  }
}
