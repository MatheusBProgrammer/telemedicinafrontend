import 'package:flutter/material.dart';
import 'package:app_medicos/services/api_service.dart';
import 'package:intl/intl.dart';
import 'detalhes_consulta_page.dart';

class ConsultasPage extends StatefulWidget {
  const ConsultasPage({Key? key}) : super(key: key);

  @override
  _ConsultasPageState createState() => _ConsultasPageState();
}

class _ConsultasPageState extends State<ConsultasPage> {
  List<dynamic> _consultas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarConsultas();
  }

  Future<void> _carregarConsultas() async {
    setState(() {
      _isLoading = true;
    });

    final apiService = ApiService();
    try {
      final consultas = await apiService.getConsultas();

      // Ordena todas as consultas em ordem crescente de data
      consultas.sort((a, b) {
        DateTime dataA = DateTime.parse(a['data']);
        DateTime dataB = DateTime.parse(b['data']);
        return dataA.compareTo(dataB);
      });

      setState(() {
        _consultas = consultas;
      });
    } catch (e) {
      print('Erro ao carregar consultas: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _atualizarConsultas() async {
    await _carregarConsultas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultas Agendadas'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _consultas.length,
                itemBuilder: (context, index) {
                  final consulta = _consultas[index];
                  DateTime dataConsulta = DateTime.parse(consulta['data']);
                  String formattedDate =
                      DateFormat('dd/MM/yyyy HH:mm').format(dataConsulta);

                  String pacienteNome = consulta['paciente'] != null
                      ? consulta['paciente']['nome']
                      : 'Paciente não informado';

                  // Definir gradiente para o card
                  Gradient cardGradient;
                  if (index == 0) {
                    // Gradiente verde
                    cardGradient = LinearGradient(
                      colors: [
                        const Color.fromARGB(255, 165, 240, 167),
                        const Color.fromARGB(255, 100, 200, 110),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    );
                  } else {
                    // Gradiente azul
                    cardGradient = LinearGradient(
                      colors: [
                        Colors.blue.shade700,
                        Colors.blue.shade400,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    );
                  }

                  return GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetalhesConsultaPage(
                            consultaId: consulta['_id'],
                            onConsultaDeleted: _atualizarConsultas,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: cardGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          // Centraliza o conteúdo verticalmente
                          crossAxisAlignment: CrossAxisAlignment.center,
                          // Centraliza o conteúdo horizontalmente
                          children: [
                            Icon(
                              Icons.event_available,
                              color: Colors.white,
                              size: 36,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              formattedDate,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              pacienteNome,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
