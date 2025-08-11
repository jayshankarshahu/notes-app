import 'package:sqflite/sqflite.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences prefs;

const cacheTypeTitle = 'title';
const cacheTypeBody = 'body';


//keeping things static so that the function can be used globally across the app
class NotesDatabase {
  static Database? _database;

  static Future<Database> get database async {
    return await _initDatabase();
  }

  static Future<Database> _initDatabase() async {
    if (_database != null) {
      return _database!;
    }

    // if( Platform.isWindows || Platform.isLinux || Platform.isMacOS ) {

    //   databaseFactory = databaseFactoryFfi;

    // }

    _database = await openDatabase(
      'notes.db',
      version: 1,
      onCreate: (db, version) {
        db.execute("""
            CREATE TABLE IF NOT EXISTS notes (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT,
              body TEXT,
              createdAt INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
              editedAt INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
            );
        """);
        db.execute("""
            PRAGMA recursive_triggers = OFF;

            CREATE TRIGGER update_editedAt
            AFTER UPDATE ON notes
            FOR EACH ROW
            BEGIN
                UPDATE notes
                SET editedAt = strftime('%s', 'now')
                WHERE id = OLD.id;
            END;

            """);
      },
    );

    return _database!;
  }

  static Future<List<Map<String, dynamic>>> getAllNotes( {String searchQuery = "" }) async {
    final db = await _initDatabase();

    searchQuery = searchQuery.trim();

    return await db.query(
      'notes',
      where: 'title like ? or body like ?',
      whereArgs: [ "%$searchQuery%" , "%$searchQuery%" ],
      orderBy: 'editedAt desc'
    );
  }

  static Future<int> InsertEmptyNoteAndGetId( ) async {
    final db = await _initDatabase();

    final queryResult = await db.insert(
      'notes',
      { 
        'title' : '',
        'body' : ''
      }
    );

    return queryResult;
  }

  static Future<int> deleteNotes( List<int> ids ) async {

    final db = await _initDatabase();

    if( ids.isEmpty ) {
      return 0;
    }

    return await db.delete('notes' , where: "id in (${ids.join(',')})");

  }

  static Future<int> deleteEmpty( ) async {

    final db = await _initDatabase();
    return await db.delete('notes' , where: 'title = "" and body = ""');

  }

  static Future<Map<String, dynamic>?> getOneNote( id ) async {
    final db = await _initDatabase();

    final queryResult = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    return queryResult.firstOrNull;
  }

  static updateNote(int noteId, String? newTitle, String? newBody) async {
    if (newTitle == null && newBody == null) {
      return false;
    }

    final db = await _initDatabase();
    Map<String, String> updateValues = Map();

    if (newTitle != null) {
      updateValues['title'] = newTitle;
    }

    if (newBody != null) {
      updateValues['body'] = newBody;
    }

    final updatedValue = await db.update(
      'notes',
      updateValues,
      where: 'id = ?',
      whereArgs: [noteId],
    );

    return updatedValue == 1;
  }
}


void saveNoteInCache( int id , String type , String value ) async {

  final key = "draft-${id.toString()}-$type";

  prefs.setString(key, value);

}

Future<void> readCacheAndUpdateStorage() async {

  for (String key in prefs.getKeys()) {

    if (key.startsWith('draft-')) {
      
      final keyElements = key.split('-');

      if( keyElements.length != 3 ) {
        continue;
      }

      final id = int.tryParse(keyElements[1]);

      if( id == null ) {
        continue;
      }

      final type = keyElements[2];

      final value = prefs.getString(key);

      if( type == cacheTypeTitle ) {

        await NotesDatabase.updateNote(id, value , null);
        await prefs.remove(key);

      } else if ( type == cacheTypeBody ) {

        await NotesDatabase.updateNote(id, null , value);
        await prefs.remove(key);
        
      }

    }

  }

}