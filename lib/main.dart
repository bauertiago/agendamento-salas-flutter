import 'package:agendamento_salas/screens/room_screen.dart';
import 'package:agendamento_salas/screens/scheduling_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agendamento',
      home: const MyHomePage(title: 'Agendamento de Salas'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final dynamic title;

  const MyHomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cadastro e Agendamento de Salas',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade100,
        toolbarHeight: 80,
        centerTitle: true,
        elevation: 4,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RoomScreen()),
                  );
                },
                child: Text("Cadastro de Salas"),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SchedulingScreen()),
                  );
                },
                child: Text("Agendamentos"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
