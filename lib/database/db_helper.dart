import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('agendamento.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sala (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL UNIQUE,
        CHECK (TRIM(nome) <> '')
      );
    ''');

    await db.execute('''
      CREATE TABLE agendamento (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sala_id INTEGER NOT NULL,
        data_inicio TEXT NOT NULL,
        data_fim TEXT NOT NULL,
        FOREIGN KEY (sala_id) REFERENCES sala (id),
        CHECK (data_fim > data_inicio)
      );
    ''');

    await db.execute('''
      CREATE TABLE log_operacao (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome_tabela TEXT NOT NULL,
        operacao TEXT NOT NULL,
        data_hora TEXT DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    await db.execute('''
      CREATE TRIGGER log_sala_insert
      AFTER INSERT ON sala
      BEGIN
        INSERT INTO log_operacao (nome_tabela, operacao) 
        VALUES ('sala', 'INSERT');
      END;
      ''');

    await db.execute('''
      CREATE TRIGGER log_sala_update
      AFTER UPDATE ON sala
      BEGIN
        INSERT INTO log_operacao (nome_tabela, operacao) 
        VALUES ('sala', 'UPDATE');
      END;
      ''');

    await db.execute('''
      CREATE TRIGGER log_sala_delete
      AFTER DELETE ON sala
      BEGIN
        INSERT INTO log_operacao (nome_tabela, operacao)
        VALUES ('sala', 'DELETE');
      END;
    ''');

    await db.execute('''
      CREATE TRIGGER log_agendamento_insert
      AFTER INSERT ON agendamento
      BEGIN
        INSERT INTO log_operacao (nome_tabela, operacao) 
        VALUES ('agendamento', 'INSERT');
      END;
      ''');

    await db.execute('''
      CREATE TRIGGER log_agendamento_update
      AFTER UPDATE ON agendamento
      BEGIN
        INSERT INTO log_operacao (nome_tabela, operacao)
        VALUES ('agendamento', 'UPDATE');
      END;
      ''');

    await db.execute('''
      CREATE TRIGGER log_agendamento_delete
      AFTER DELETE ON agendamento
      BEGIN
        INSERT INTO log_operacao (nome_tabela, operacao)
        VALUES ('agendamento', 'DELETE');
      END;
    ''');

    await db.execute('''
      CREATE TRIGGER trg_conflito_insert
      BEFORE INSERT ON agendamento
      BEGIN
        SELECT CASE
          WHEN EXISTS (
            SELECT 1 FROM agendamento
            WHERE sala_id = NEW.sala_id
              AND (
                NEW.data_inicio < data_fim AND
                NEW.data_fim > data_inicio
              )
            ) THEN RAISE(ABORT, 'Conflito de agendamento: a sala já está reservada nesse horário.')
        END;
      END;
    ''');

    await db.execute('''
      CREATE TRIGGER trg_conflito_update
      BEFORE UPDATE ON agendamento
      BEGIN
        SELECT CASE
          WHEN EXISTS (
            SELECT 1 FROM agendamento
            WHERE sala_id = NEW.sala_id
              AND id != OLD.id
              AND (
                NEW.data_inicio < data_fim AND
                NEW.data_fim > data_inicio
              )
            ) THEN RAISE(ABORT, 'Conflito de agendamento: a sala já está reservada nesse horário.')
        END;
      END;
    ''');

    await db.execute('''
      CREATE TRIGGER trg_delete_sala
      BEFORE DELETE ON sala
      BEGIN
        SELECT CASE
          WHEN EXISTS (
            SELECT 1 FROM agendamento
            WHERE sala_id = OLD.id
            AND data_inicio > datetime('now')
          ) THEN RAISE(ABORT, 'Não é possível excluir a sala: existem agendamentos futuros para esta sala.')
        END;
      END;
    ''');
  }
}
