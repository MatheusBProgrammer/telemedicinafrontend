import 'package:flutter/material.dart';
import 'package:app_medicos/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:jitsi_meet/jitsi_meet.dart';

class DetalhesConsultaPage extends StatefulWidget {
  final String consultaId;
  final Function onConsultaDeleted;

  const DetalhesConsultaPage(
      {Key? key, required this.consultaId, required this.onConsultaDeleted})
      : super(key: key);

  @override
  _DetalhesConsultaPageState createState() => _DetalhesConsultaPageState();
}

class _DetalhesConsultaPageState extends State<DetalhesConsultaPage> {
  Map<String, dynamic>? _consulta;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarDetalhesConsulta();
  }

  Future<void> _carregarDetalhesConsulta() async {
    final apiService = ApiService();
    try {
      final consulta = await apiService.getConsultaById(widget.consultaId);
      setState(() {
        _consulta = consulta;
      });
    } catch (e) {
      print('Erro ao carregar detalhes da consulta: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _entrarSalaConsulta() async {
    if (_consulta == null) return;

    String salaId = _consulta!['_id'];
    String nomeUsuario = _consulta!['paciente']?['nome'] ?? 'Paciente';

    Map<FeatureFlagEnum, bool> featureFlags = {
      FeatureFlagEnum.WELCOME_PAGE_ENABLED: false,
    };

    var options = JitsiMeetingOptions(room: salaId)
      ..serverURL = null // Use o servidor padrão ou especifique o seu
      ..userDisplayName = nomeUsuario
      ..audioMuted = false
      ..videoMuted = false
      ..featureFlags.addAll(featureFlags);

    debugPrint("JitsiMeetingOptions: $options");

    await JitsiMeet.joinMeeting(
      options,
      listener: JitsiMeetingListener(
        onConferenceWillJoin: (message) {
          debugPrint("${options.room} vai entrar na conferência: $message");
        },
        onConferenceJoined: (message) {
          debugPrint("${options.room} entrou na conferência: $message");
        },
        onConferenceTerminated: (message) {
          debugPrint("${options.room} conferência terminada: $message");
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Consulta'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _consulta == null
              ? const Center(child: Text('Consulta não encontrada'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Consulta ID: ${_consulta!['_id']}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                          'Data: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(_consulta!['data']))}'),
                      const SizedBox(height: 8),
                      Text(
                          'Paciente: ${_consulta!['paciente']?['nome'] ?? 'Paciente não informado'}'),
                      const SizedBox(height: 8),
                      Text('Notas: ${_consulta!['notas'] ?? 'Nenhuma nota'}'),
                      Spacer(),
                      ElevatedButton(
                        onPressed: _entrarSalaConsulta,
                        child: const Text('Ir para a Sala de Consulta'),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Deletar Consulta'),
                                  content: const Text(
                                      'Tem certeza que deseja deletar esta consulta?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        final apiService = ApiService();
                                        try {
                                          await apiService.deleteConsulta(
                                              _consulta!['_id']);
                                          widget
                                              .onConsultaDeleted(); // Atualiza o grid ao retornar
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        } catch (e) {
                                          print('Erro ao deletar consulta: $e');
                                        }
                                      },
                                      child: const Text('Deletar'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Text('Deletar Consulta'),
                        ),
                      )
                    ],
                  ),
                ),
    );
  }
}
