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
         ('Ropa', NULL),
         ('Hogar', NULL),
         ('Juguetes', NULL),
         ('Libros', NULL),
         ('Deportes', NULL),
         ('Alimentos', NULL);
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
    ('Jeans', 'Jeans azules clásicos, talla 32', 49.99, NULL, 2),
    ('Lámpara LED', 'Lámpara con luz regulable', 24.99, NULL, 3),
    ('Silla ergonómica', 'Silla de oficina con soporte lumbar', 129.99, NULL, 3),
    ('Mesa de café', 'Mesa de centro de madera', 89.99, NULL, 3),
    ('Cortina', 'Cortina opaca para habitación', 34.99, NULL, 3),
    ('Rompecabezas', 'Puzzle de 1000 piezas', 15.99, NULL, 4),
    ('Muñeco de acción', 'Figura articulada de superhéroe', 22.49, NULL, 4),
    ('Juego de mesa', 'Juego de mesa familiar', 39.99, NULL, 4),
    ('Pelota saltarina', 'Pelota para niños', 9.99, NULL, 4),
    ('Novela', 'Novela de misterio bestseller', 14.99, NULL, 5),
    ('Cómic', 'Cómic de superhéroes', 6.99, NULL, 5),
    ('Libro técnico', 'Libro sobre estructuras de datos', 49.99, NULL, 5),
    ('Enciclopedia', 'Enciclopedia de ciencia para niños', 29.99, NULL, 5),
    ('Balón de fútbol', 'Balón oficial tamaño 5', 25.0, NULL, 6),
    ('Raqueta de tenis', 'Raqueta profesional', 89.0, NULL, 6),
    ('Pesas', 'Set de pesas ajustables', 59.0, NULL, 6),
    ('Bicicleta', 'Bicicleta de montaña', 199.0, NULL, 6),
    ('Cereal', 'Cereal integral con frutas', 4.99, NULL, 7),
    ('Galletas', 'Galletas de avena', 2.99, NULL, 7),
    ('Jugo natural', 'Jugo de naranja sin azúcar', 3.49, NULL, 7),
    ('Arroz', 'Arroz integral 1kg', 1.89, NULL, 7);
""");

        await db.execute("""
  INSERT INTO "order" (date, due_date, state_id)
  VALUES
    ('2025-04-17', '2025-04-20', 1),
    ('2025-04-15', '2025-04-16', 1),
    ('2025-04-27', '2025-05-02', 2),
    ('2025-04-06', '2025-04-08', 3),
    ('2025-04-11', '2025-04-14', 1),
    ('2025-04-26', '2025-04-30', 3),
    ('2025-04-20', '2025-04-24', 1),
    ('2025-04-08', '2025-04-11', 2),
    ('2025-04-27', '2025-05-01', 2),
    ('2025-04-05', '2025-04-08', 1),
    ('2025-04-20', '2025-04-25', 3),
    ('2025-04-17', '2025-04-18', 2),
    ('2025-04-07', '2025-04-08', 3),
    ('2025-04-08', '2025-04-09', 1),
    ('2025-04-03', '2025-04-08', 2),
    ('2025-04-19', '2025-04-24', 1),
    ('2025-04-14', '2025-04-15', 2);
""");

        await db.execute("""
  INSERT INTO order_detail (order_id, product_id, quantity)
  VALUES
    (1, 1, 2),
    (1, 3, 1),
    (2, 2, 1),
    (2, 4, 2),
    (3, 14, 2), (3, 10, 2), (3, 20, 1), (3, 9, 3),
    (4, 19, 3), (4, 14, 3), (4, 22, 3), (4, 11, 2),
    (5, 21, 3), (5, 2, 3),
    (6, 7, 3), (6, 3, 2), (6, 15, 3),
    (7, 23, 2), (7, 3, 3), (7, 13, 1), (7, 20, 3),
    (8, 8, 1), (8, 9, 3), (8, 12, 1), (8, 10, 1),
    (9, 11, 1), (9, 3, 2), (9, 5, 3),
    (10, 22, 3), (10, 21, 2),
    (11, 15, 2), (11, 11, 1),
    (12, 4, 1), (12, 19, 2),
    (13, 17, 3), (13, 4, 3), (13, 3, 1), (13, 22, 1),
    (14, 7, 2), (14, 21, 3), (14, 22, 2), (14, 19, 3),
    (15, 4, 2), (15, 16, 2),
    (16, 15, 3), (16, 17, 1),
    (17, 20, 2), (17, 23, 3);
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
    // DOCUMENTAR PARA LA PROXIMA VEZ
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
