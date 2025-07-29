import 'package:flutter/material.dart';

class EditNotePage extends StatefulWidget {
  final String note;
  final Function onChange;

  const EditNotePage({Key? key, required this.note, required this.onChange}) : super(key: key);

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  // Create a controller with some initial text
  late final TextEditingController _controller;

  @override
  void dispose() {
    // Dispose the controller when the widget is removed
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _controller = TextEditingController(text: widget.note);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Note")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: TextField(
          minLines: null,
          textAlignVertical: TextAlignVertical(y: -1),
          maxLines: null,
          autofocus: true,
          expands: true,
          controller: _controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: "What's on your mind?",
          ),
          // Optional: Listen to changes if you want
          onChanged: (value) {
            widget.onChange(value);
          },
        ),
      ),
    );
  }
}