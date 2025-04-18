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

        db.execute('''
create table category(
    category_id integer primary key,
    category varchar(50),
    image text
);
''');
        db.execute('''
create table state(
    state_id integer primary key,
    state varchar(20)
);
''');
        db.execute('''
create table product(
    product_id integer primary key,
    product varchar(50),
    description varchar(250),
    price real,
    image text,
    category_id integer,
    foreign key (category_id) references category(category_id) on delete set null
);
''');
        db.execute('''
create table 'order'(
    order_id integer primary key,
    date varchar(10),
    due_date varchar(10),
    state_id integer,
    foreign key (state_id) references state(state_id) on delete restrict
);
''');
        db.execute('''
create table order_detail(
    order_detail_id integer primary key,
    order_id integer not null,
    product_id integer not null,
    quantity integer,
    foreign key (order_id) references 'order'(order_id) on delete cascade,
    foreign key (product_id) references product(product_id) on delete restrict
);
''');
        await db.execute("""
  INSERT INTO category (category, image)
  VALUES ('Electrónica', NULL),
         ('Ropa', NULL);
""");

        await db.execute("""
  INSERT INTO state (state)
  VALUES ('Por cumplir'),
         ('Cancelado'),
         ('Completado');
""");

        await db.execute("""
  INSERT INTO product (product, description, price, image, category_id)
  VALUES
    ('Smartphone', 'Teléfono inteligente con pantalla AMOLED', 699.99, NULL, 1),
    ('Laptop', 'Laptop con procesador Intel i7 y 16GB RAM', 999.99, NULL, 1),
    ('Camiseta', 'Camiseta de algodón talla M', 19.99, NULL, 2),
    ('Jeans', 'Jeans azules clásicos, talla 32', 49.99, NULL, 2);
""");

        await db.execute("""
  INSERT INTO "order" (date, due_date, state_id)
  VALUES
    ('2025-04-17', '2025-04-20', 1),
    ('2025-04-15', '2025-04-16', 1);
""");

        await db.execute("""
  INSERT INTO order_detail (order_id, product_id, quantity)
  VALUES
    (1, 1, 2),
    (1, 3, 1),
    (2, 2, 1),
    (2, 4, 2);
""");
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

  Future<int> delete(String table, String key, int id) async {
    final con = await database;
    return con!.delete(table, where: '$key = ?', whereArgs: [id]);
  }

  Future<List<T>> select<T>(
    String table,
    T Function(Map<String, dynamic>) fromMap,
  ) async {
    final con = await database;
    final result = await con!.query(table);
    return result.map((item) => fromMap(item)).toList();
  }

  Future<List<T>> selectByColumn<T>(
    String table,
    String column,
    dynamic value,
    T Function(Map<String, dynamic>) fromMap,
  ) async {
    final con = await database;
    final result = await con!.query(
      table,
      where: '$column = ?',
      whereArgs: [value],
    );
    return result.map((item) => fromMap(item)).toList();
  }
}
