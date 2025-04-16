import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SalesDatabase {
  static const NAMEDB = 'sales';
  static const VERSIONDB = 1;

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database!;
    return _database = await initDatabase();
  }

  Future<Database?> initDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, NAMEDB);

    return openDatabase(
      path,
      version: VERSIONDB,
      onCreate: (db, version) async {
        await db.execute('PRAGMA foreign_keys = ON;');

        String query = '''
        
create table category(
    category_id integer primary key,
    category varchar(50),
    image blob
);

create table state(
    state_id integer primary key,
    state varchar(20)
);

create table product(
    product_id integer primary key,
    product varchar(50),
    description varchar(250),
    price real,
    image blob,
    category_id integer,
    foreign key (category_id) references category(category_id) on delete set null
);

create table 'order'(
    order_id integer primary key,
    date varchar(10),
    due_date varchar(10),
    state_id integer,
    foreign key (state_id) references state(state_id) on delete restrict
);

create table order_detail(
    order_detail_id integer primary key,
    order_id integer not null,
    product_id integer not null,
    quantity integer,
    foreign key (order_id) references 'order'(order_id) on delete cascade,
    foreign key (product_id) references product(product_id) on delete restrict
);

        ''';
        db.execute(query);
      },
      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON;');
      },
    );
  }

  Future<int> insert(String table, Map<String, dynamic> map) async {
    final con = await database;
    return con!.insert(table, map);
  }

  Future<int> update(String table, Map<String, dynamic> map, String key) async {
    final con = await database;
    return con!.update(table, map, where: '$key = ?', whereArgs: [map[key]]);
  }

  /*
  Future<int> update(String table, Map<String, dynamic> data, String key,
      dynamic value) async {
    final db = await database;
    return await db!.update(table, data, where: '$key = ?', whereArgs: [value]);
  }
  */

  Future<int> delete(String table, String key, int id) async {
    final con = await database;
    return con!.delete(table, where: '$key = ?', whereArgs: [id]);
  }

  /*
  Future<int> delete(String table, String key, dynamic value) async {
    final db = await database;
    return await db!.delete(table, where: '$key = ?', whereArgs: [value]);
  }
  */

  Future<List<T>> select<T>(
    String table,
    T Function(Map<String, dynamic>) fromMap,
  ) async {
    final con = await database;
    final result = await con!.query(table);
    return result.map((item) => fromMap(item)).toList();
  }

  /*
  Future<List<TodoModel>> SELECT() async {
    final con = await database;
    var result = await con!.query('todo');
    return result.map((task) => TodoModel.fromMap(task)).toList(); 
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await database;
    return await db!.query(table);
  }
  */
}
