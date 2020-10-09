import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Open the database and store the reference.
  final Future<Database> database = openDatabase(
    join(await getDatabasesPath(), 'doggie_database.db'),
    onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, age INTEGER)",
      );
    },
    version: 1,
  );

  Future<void> insertDog(Dog dog) async {
    final Database db = await database;

    await db.insert(
      'dogs',
      dog.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Dog>> dogs() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('dogs');

    return List.generate(maps.length, (i) {
      return Dog(
        id: maps[i]['id'],
        name: maps[i]['name'],
        age: maps[i]['age'],
      );
    });
  }

  Future<void> updateDog(Dog dog) async {
    final db = await database;

    await db.update(
      'dogs',
      dog.toMap(),
      where: "id = ?",
      whereArgs: [dog.id],
    );
  }

  Future<void> deleteDog(int id) async {
    final db = await database;

    await db.delete(
      'dogs',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<Dog> findDogById(int id) async {
    final db = await database;
    List<Map> results = await db.query("dogs",
        columns: ["id", "name", "age"], where: 'id = ?', whereArgs: [id]);

    if (results.length > 0) {
      return new Dog.fromMap(results.first);
    }

    return null;
  }

  Future<Dog> findDogByName(String name) async {
    final db = await database;
    List<Map> results = await db.query("dogs",
        columns: ["id", "name", "age"], where: 'name = ?', whereArgs: [name]);

    if (results.length > 0) {
      return new Dog.fromMap(results.first);
    }

    return null;
  }

  var fido = Dog(
    id: 0,
    name: 'Fido',
    age: 35,
  );
  await insertDog(fido);
  print(await dogs());

  var puppy = Dog(
    id: 1,
    name: 'Puppy',
    age: 2,
  );
  await insertDog(puppy);
  print(await dogs());

  //findDog with ID
  var results = await findDogById(1);
  print('finding ${1} here $results');

  //findDog with name
  var dogName = await findDogByName('Fido');
  print('finding Fido here $dogName');

  fido = Dog(
    id: fido.id,
    name: fido.name,
    age: fido.age + 7,
  );
  await updateDog(fido);
  print(await dogs());

  await deleteDog(fido.id);
  print(await dogs());
}

class Dog {
  final int id;
  final String name;
  final int age;

  Dog({this.id, this.name, this.age});

  factory Dog.fromMap(Map<String, dynamic> data) => new Dog(
        id: data["id"],
        name: data["name"],
        age: data["age"],
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
    };
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'Dog{id: $id, name: $name, age: $age}';
  }
}
