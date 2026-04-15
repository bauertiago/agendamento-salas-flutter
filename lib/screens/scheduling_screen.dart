import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class SchedulingScreen extends StatefulWidget {
  const SchedulingScreen({super.key});

  @override
  State<SchedulingScreen> createState() => _SchedulingScreenState();
}

class _SchedulingScreenState extends State<SchedulingScreen> {
  List<Map<String, dynamic>> rooms = [];
  int? selectedRoom;

  List<Map<String, dynamic>> schedulings = [];

  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    loadRoom();
    loadSchedulings();
  }

  Future<void> loadRoom() async {
    final db = await DBHelper.instance.database;
    final result = await db.query('sala');

    setState(() {
      rooms = result;
    });
  }

  Future<void> loadSchedulings() async {
    final db = await DBHelper.instance.database;
    final result = await db.rawQuery('''
      SELECT a.*, s.nome
      FROM agendamento a
      JOIN sala s ON s.id = a.sala_id
    ''');
    setState(() {
      schedulings = result;
    });
  }

  Future<void> addScheduling() async {
    if (selectedRoom == null || startDate == null || endDate == null) {
      showErro("Todos os campos devem ser preenchidos.");
      return;
    }
    final db = await DBHelper.instance.database;

    try {
      DateTime start = DateTime(
        startDate!.year,
        startDate!.month,
        startDate!.day,
        startDate!.hour,
        startDate!.minute,
        0,
      );
      DateTime end = DateTime(
        endDate!.year,
        endDate!.month,
        endDate!.day,
        endDate!.hour,
        endDate!.minute,
        0,
      );

      await db.insert('agendamento', {
        'sala_id': selectedRoom,
        'data_inicio': start.toIso8601String(),
        'data_fim': end.toIso8601String(),
      });
      showSuccess("Agendamento realizado com sucesso.");
      setState(() {
        selectedRoom = null;
        startDate = null;
        endDate = null;
      });
      loadSchedulings();
    } catch (e) {
      showErro(e.toString());
    }
  }

  Future<void> selectDateTime(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    final endDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isStart) {
        startDate = endDateTime;
      } else {
        endDate = endDateTime;
      }
    });
  }

  Future<void> editScheduling(Map<String, dynamic> scheduling) async {
    setState(() {
      selectedRoom = scheduling['sala_id'];
      startDate = DateTime.parse(scheduling['data_inicio']);
      endDate = DateTime.parse(scheduling['data_fim']);
    });

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("Editar Agendamento"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<int>(
                hint: Text("Selecione a sala"),
                value: selectedRoom,
                isExpanded: true,
                items: rooms.map((room) {
                  return DropdownMenuItem<int>(
                    value: room['id'],
                    child: Text(room['nome']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRoom = value;
                  });
                },
              ),
              ElevatedButton(
                onPressed: () => selectDateTime(true),
                child: Text(
                  startDate == null
                      ? "Selecionar Data e Hora de Início"
                      : formatDateTime(startDate!),
                ),
              ),
              ElevatedButton(
                onPressed: () => selectDateTime(false),
                child: Text(
                  endDate == null
                      ? "Selecionar Data e Hora de Fim"
                      : formatDateTime(endDate!),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Cancelar"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("Salvar"),
              onPressed: () async {
                await updateScheduling(scheduling['id']);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> updateScheduling(int id) async {
    final db = await DBHelper.instance.database;

    try {
      DateTime start = DateTime(
        startDate!.year,
        startDate!.month,
        startDate!.day,
        startDate!.hour,
        startDate!.minute,
        0,
      );
      DateTime end = DateTime(
        endDate!.year,
        endDate!.month,
        endDate!.day,
        endDate!.hour,
        endDate!.minute,
        0,
      );

      await db.update(
        'agendamento',
        {
          'sala_id': selectedRoom,
          'data_inicio': start.toIso8601String(),
          'data_fim': end.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      loadSchedulings();
      showSuccess("Agendamento atualizado com sucesso.");
    } catch (e) {
      showErro(e.toString());
    }
  }

  Future<void> deleteScheduling(int id) async {
    final db = await DBHelper.instance.database;

    try {
      await db.delete('agendamento', where: 'id = ?', whereArgs: [id]);
      loadSchedulings();
      showSuccess("Agendamento deletado com sucesso.");
    } catch (e) {
      showErro(e.toString());
    }
  }

  String formatDateTime(DateTime dt) {
    return "${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
  }

  void showErro(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void showSuccess(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Agendamento de Salas',
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
            DropdownButton<int>(
              hint: Text("Selecione a sala"),
              value: selectedRoom,
              isExpanded: true,
              items: rooms.map((room) {
                return DropdownMenuItem<int>(
                  value: room['id'],
                  child: Text(room['nome']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedRoom = value;
                });
              },
            ),

            SizedBox(height: 10),

            SizedBox(
              height: 50,
              width: 280,
              child: ElevatedButton(
                onPressed: () => selectDateTime(true),
                child: Text(
                  startDate == null
                      ? "Selecionar Data e Hora de Início"
                      : formatDateTime(startDate!),
                ),
              ),
            ),

            SizedBox(height: 10),

            SizedBox(
              height: 50,
              width: 280,
              child: ElevatedButton(
                onPressed: () => selectDateTime(false),
                child: Text(
                  endDate == null
                      ? "Selecionar Data e Hora de Fim"
                      : formatDateTime(endDate!),
                ),
              ),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: addScheduling,
              child: Text('Salvar Agendamento'),
            ),

            SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Agendamentos:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            Divider(),

            Expanded(
              child: ListView.builder(
                itemCount: schedulings.length,
                itemBuilder: (context, index) {
                  final item = schedulings[index];
                  final inicio = DateTime.parse(item['data_inicio']);
                  final fim = DateTime.parse(item['data_fim']);

                  return ListTile(
                    title: Text(item['nome']),
                    subtitle: Text(
                      "Início: ${formatDateTime(inicio)}\nFim: ${formatDateTime(fim)}",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => editScheduling(item),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            final id = item['id'];
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text("Confirmar Exclusão"),
                                content: Text(
                                  "Tem certeza que deseja excluir este agendamento?",
                                ),
                                actions: [
                                  TextButton(
                                    child: Text("Cancelar"),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  TextButton(
                                    child: Text("Excluir"),
                                    onPressed: () {
                                      deleteScheduling(id);
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
