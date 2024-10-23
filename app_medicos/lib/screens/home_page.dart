// lib/screens/home_page.dart

import 'package:flutter/material.dart';
import 'package:app_medicos/screens/horarios_page.dart';
import 'package:app_medicos/screens/consultas_page.dart';
import 'package:google_fonts/google_fonts.dart'; // Importação do pacote google_fonts

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    ConsultasPage(),
    HorariosPage(),
    // Você pode adicionar mais telas aqui
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'App',
          style: GoogleFonts.montserrat(
            textStyle: const TextStyle(
              color: Color.fromARGB(255, 0, 0, 0),
              fontSize: 30,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0, // Remove a sombra para um design mais limpo
        iconTheme:
            const IconThemeData(color: Colors.black), // Ícones na cor preta
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.event_note),
            label: 'Consultas',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.schedule),
            label: 'Horários',
          ),
          // Adicione mais itens se necessário
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        selectedLabelStyle:
            GoogleFonts.lato(), // Fonte para o label selecionado
        unselectedLabelStyle:
            GoogleFonts.lato(), // Fonte para labels não selecionados
      ),
    );
  }
}
