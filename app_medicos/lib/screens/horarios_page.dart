import 'package:app_medicos/components/add_horarios.dart';
import 'package:flutter/material.dart';
import 'package:app_medicos/services/api_service.dart';

class HorariosPage extends StatefulWidget {
  const HorariosPage({Key? key}) : super(key: key);

  @override
  _HorariosPageState createState() => _HorariosPageState();
}

class _HorariosPageState extends State<HorariosPage>
    with SingleTickerProviderStateMixin {
  Map<String, List<dynamic>> _horariosPorDia = {};
  bool _isLoading = true;
  final List<String> _diasSemana = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
    'Domingo',
  ];

  late TabController _tabController;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _carregarHorarios();
  }

  Future<void> _carregarHorarios() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final horarios = await _apiService.getHorariosDisponiveis();

      // Organizar os horários por dia da semana
      Map<String, List<dynamic>> horariosPorDia = {
        for (var dia in _diasSemana) dia: []
      };

      for (var horario in horarios) {
        String diaSemana = horario['diaSemana'];
        if (horariosPorDia.containsKey(diaSemana)) {
          horariosPorDia[diaSemana]!.add(horario);
        }
      }

      setState(() {
        _horariosPorDia = horariosPorDia;
      });
    } catch (e) {
      _mostrarMensagemErro('Erro ao carregar horários: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _mostrarMensagemErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _mostrarMensagemSucesso(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildHorariosPorDia() {
    return ListView.builder(
      itemCount: _diasSemana.length,
      itemBuilder: (context, index) {
        String diaSemana = _diasSemana[index];
        List<dynamic>? horarios = _horariosPorDia[diaSemana];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ExpansionTile(
            title: Text(
              diaSemana,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _adicionarHorario(diaSemana),
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar Horário'),
                ),
              ),
              if (horarios != null && horarios.isNotEmpty)
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: horarios.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final horario = horarios[index];
                    return _buildHorarioTile(horario);
                  },
                )
              else
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Nenhum horário disponível'),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHorarioTile(dynamic horario) {
    final startTimeIndex = horario['startTimeIndex'];
    final endTimeIndex = horario['endTimeIndex'];
    final horarioId = horario['_id'];

    // Conversão dos índices para o formato de horas
    final startHour = startTimeIndex ~/ 2;
    final startMinute = (startTimeIndex % 2) * 30;
    final endHour = endTimeIndex ~/ 2;
    final endMinute = (endTimeIndex % 2) * 30;

    final startTime =
        '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
    final endTime =
        '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';

    return ListTile(
      leading: const Icon(Icons.access_time),
      title: Text('$startTime - $endTime'),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () => _removerHorario(horarioId),
      ),
    );
  }

  Future<void> _adicionarHorario(String diaSemana) async {
    final result = await showDialog(
      context: context,
      builder: (context) => AdicionarHorarioDialog(diaSemana: diaSemana),
    );

    if (result != null) {
      final newStartIndex = result['startTimeIndex']!;
      final newEndIndex = result['endTimeIndex']!;

      // Verifica se o novo horário conflita com algum horário existente para o dia
      bool hasConflict = _horariosPorDia[diaSemana]!.any((horario) {
        final existingStartIndex = horario['startTimeIndex'];
        final existingEndIndex = horario['endTimeIndex'];

        // Checa se há interseção entre o novo horário e os horários existentes
        return (newStartIndex < existingEndIndex) &&
            (newEndIndex > existingStartIndex);
      });

      if (hasConflict) {
        _mostrarMensagemErro(
            'Horário conflituoso! Selecione um horário diferente.');
        return;
      }

      // Adiciona o horário caso não haja conflito
      try {
        await _apiService.adicionarHorarioDisponivel({
          'diaSemana': diaSemana,
          'startTimeIndex': newStartIndex,
          'endTimeIndex': newEndIndex,
        });
        _mostrarMensagemSucesso('Horário adicionado com sucesso!');
        _carregarHorarios();
      } catch (e) {
        _mostrarMensagemErro('Erro ao adicionar horário: $e');
      }
    }
  }

  Future<void> _removerHorario(String horarioId) async {
    try {
      await _apiService.removerHorarioDisponivel(horarioId);
      _mostrarMensagemSucesso('Horário removido com sucesso!');
      _carregarHorarios();
    } catch (e) {
      _mostrarMensagemErro('Erro ao remover horário: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciamento de Horários'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildHorariosPorDia(),
    );
  }
}
