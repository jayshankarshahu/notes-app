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
  late final TextEditingController _bodyController;
  late final TextEditingController _titleController;
  late Map<String, dynamic> _currentNote;

  @override
  void dispose() {
    // Dispose the controller when the widget is removed
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> _InitCurrentNote() async {
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
    _bodyController = TextEditingController(text: _currentNote['body']);
    _titleController = TextEditingController(text: _currentNote['title']);

    return note;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Note")),
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
                    controller: _titleController,
                    maxLines: 1,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "What is it about?",
                      hintStyle: TextStyle(color: Theme.of(context).hintColor),
                      fillColor: Theme.of(context).colorScheme.surface
                    ),                    
                    onChanged: (value) {

                      saveNoteInCache(_currentNote['id'], cacheTypeTitle, value);

                    },
                  ),

                  Expanded(
                    child: TextField(
                      minLines: null,
                      textAlignVertical: TextAlignVertical(y: -1),
                      maxLines: null,
                      autofocus: true,
                      expands: true,
                      controller: _bodyController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "What's on your mind?",
                        hintStyle: TextStyle(color: Theme.of(context).hintColor),
                        alignLabelWithHint: true,
                        fillColor: Theme.of(context).colorScheme.surface
                      ),
                      onChanged: (value) {

                        saveNoteInCache(_currentNote['id'], cacheTypeBody, value);
                        
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
