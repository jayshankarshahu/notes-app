import 'package:flutter/material.dart';
import 'storage.dart';

class EditNotePage extends StatefulWidget {
  final int? noteId;

  const EditNotePage({Key? key, this.noteId}) : super(key: key);

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  // Create a controller with some initial text
  Map<String, dynamic>? _currentNote;
  late UndoHistoryController bodyUndoHistoryController;

  late TextEditingController titleController;
  late TextEditingController bodyController;

  bool canUndo = false;
  bool canRedo = false;

  late bool isNewNote;

  @override
  void dispose() {
    bodyUndoHistoryController.dispose();
    titleController.dispose();
    bodyController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    isNewNote = widget.noteId == null;
    super.initState();
  }

  Future<Map<String, dynamic>?> _InitCurrentNote() async {
    if (_currentNote != null) {
      return _currentNote;
    }

    int noteId;

    if (widget.noteId == null) {
      noteId = await NotesDatabase.InsertEmptyNoteAndGetId();
    } else {
      noteId = widget.noteId!;
    }

    final note = await NotesDatabase.getOneNote(noteId);

    if (note == null) {
      //Do Something;
      return null;
    }

    _currentNote = Map.from(note);

    bodyUndoHistoryController = UndoHistoryController();
    titleController = TextEditingController(text: _currentNote!['title']);
    bodyController = TextEditingController(text: _currentNote!['body']);

    return note;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isNewNote ? "Create Note" : "Edit Note",
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.start,
        ),
        actions: [
          IconButton(
            onPressed: () {
              bodyUndoHistoryController.undo();
            },
            icon: Icon(
              Icons.undo,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
          ),
          IconButton(
            onPressed: () {
              bodyUndoHistoryController.redo();
            },
            icon: Icon(
              Icons.redo,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: FutureBuilder(
          future: _InitCurrentNote(),
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
              return Column(
                children: [
                  TextField(
                    minLines: null,
                    autocorrect: false,
                    controller: titleController,
                    maxLines: 1,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "What is it about?",
                      hintStyle: TextStyle(color: Theme.of(context).hintColor),
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                    onChanged: (value) {

                      // setState(() {
                      //   canUndo = bodyUndoHistoryController.value.canUndo;
                      //   canRedo = bodyUndoHistoryController.value.canRedo;
                      // });

                      saveNoteInCache(
                        _currentNote!['id'],
                        cacheTypeTitle,
                        value,
                      );
                    },
                  ),

                  Expanded(
                    child: TextField(
                      minLines: null,
                      textAlignVertical: TextAlignVertical(y: -1),
                      maxLines: null,
                      autofocus: true,
                      expands: true,
                      controller: bodyController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "What's on your mind?",
                        hintStyle: TextStyle(
                          color: Theme.of(context).hintColor,
                        ),
                        alignLabelWithHint: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                      ),
                      onChanged: (value) {
                        saveNoteInCache(
                          _currentNote!['id'],
                          cacheTypeBody,
                          value,
                        );
                      },
                      undoController: bodyUndoHistoryController,
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Icon(Icons.check),
      ),
    );
  }
}
android {
    // ...other config...
    ndkVersion = "27.0.12077973"
    // ...other config...
}
