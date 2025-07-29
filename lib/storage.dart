import 'package:sqflite/sqflite.dart';


//keeping things static so that the function can be used globally across the app
class NotesDatabase {

  static Database? _database;

  static Future<Database> get database async {
    
    if( _database != null ) {
      return _database!;
    }

    _database = await openDatabase('notes.db' , 
    onCreate: ( db , version ) {
      db.execute("""
          CREATE TABLE IF NOT EXISTS notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            body TEXT,
            createdAt INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
            modifiedAt INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
          );
      """);
      db.execute("""
          PRAGMA recursive_triggers = OFF;

          CREATE TRIGGER update_modifiedAt
          AFTER UPDATE ON notes
          FOR EACH ROW
          BEGIN
              UPDATE notes
              SET modifiedAt = strftime('%s', 'now')
              WHERE id = OLD.id;
          END;

          """);
    });

    return _database!;

  }


}

// var db = await openDatabase('notes.db' , {
//   onCreate: () {

//   }
// });
