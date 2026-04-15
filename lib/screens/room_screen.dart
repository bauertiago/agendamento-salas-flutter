import 'package:agendamento_salas/database/db_helper.dart';
import 'package:flutter/material.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> room = [];

  @override
  void initState() {
    super.initState();
    loadRoom();
  }

  Future<void> loadRoom() async {
    final db = await DBHelper.instance.database;
    final result = await db.query('sala');

    setState(() {
      room = result;
    });
  }

  Future<void> addRoom() async {
    final nome = _controller.text.trim();
    if (nome.isEmpty) {
      showErro("O nome da sala não pode ser vazio.");
      return;
    }

    final db = await DBHelper.instance.database;

    try {
      await db.insert('sala', {'nome': nome});
      _controller.clear();
      loadRoom();
      showSuccess("Sala adicionada com sucesso!");
    } catch (e) {
      showErro(e.toString());
    }
  }

  Future<void> editRoom(Map<String, dynamic> room) async {
    _controller.text = room['nome'];

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("Editar Sala"),
          content: TextField(controller: _controller),
          actions: [
            TextButton(
              child: Text("Cancelar"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("Salvar"),
              onPressed: () async {
                await updateRoom(room['id']);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> updateRoom(int id) async {
    final nome = _controller.text.trim();
    final db = await DBHelper.instance.database;

    try {
      await db.update('sala', {'nome': nome}, where: 'id = ?', whereArgs: [id]);
      _controller.clear();
      loadRoom();
      showSuccess("Sala atualizada com sucesso!");
    } catch (e) {
      showErro(e.toString());
    }
  }

  Future<void> deleteRoom(int id) async {
    final db = await DBHelper.instance.database;

    try {
      await db.delete('sala', where: 'id = ?', whereArgs: [id]);
      loadRoom();
      showSuccess("Sala excluída com sucesso!");
    } catch (e) {
      showErro(e.toString());
    }
  }

  void showSuccess(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }

  void showErro(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cadastro de  Salas',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade100,
        toolbarHeight: 80,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Nome da Sala'),
            ),

            SizedBox(height: 10),

            ElevatedButton(onPressed: addRoom, child: Text('Adicionar Sala')),

            SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Salas Cadastradas:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            Divider(),

            Expanded(
              child: ListView.builder(
                itemCount: room.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(room[index]['nome']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => editRoom(room[index]),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            final id = room[index]['id'];
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text("Confirmar Exclusão"),
                                content: Text(
                                  "Tem certeza que deseja excluir esta sala?",
                                ),
                                actions: [
                                  TextButton(
                                    child: Text("Cancelar"),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  TextButton(
                                    child: Text("Excluir"),
                                    onPressed: () {
                                      deleteRoom(id);
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
