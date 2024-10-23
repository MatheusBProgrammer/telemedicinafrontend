import 'package:flutter/material.dart';

class AdicionarHorarioDialog extends StatefulWidget {
  final String diaSemana;

  const AdicionarHorarioDialog({required this.diaSemana, Key? key})
      : super(key: key);

  @override
  _AdicionarHorarioDialogState createState() => _AdicionarHorarioDialogState();
}

class _AdicionarHorarioDialogState extends State<AdicionarHorarioDialog> {
  int? _startTimeIndex;
  int? _endTimeIndex;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Adicionar Horário - ${widget.diaSemana}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Campo de seleção de horário de início
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Horário de Início',
                border: OutlineInputBorder(),
              ),
              value: _startTimeIndex,
              items: _buildTimeDropdownItems(),
              onChanged: (value) {
                setState(() {
                  _startTimeIndex = value;
                  // Ajusta o horário de fim se necessário
                  if (_endTimeIndex != null &&
                      _startTimeIndex! >= _endTimeIndex!) {
                    _endTimeIndex = _startTimeIndex! + 1;
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            // Campo de seleção de horário de fim
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Horário de Fim',
                border: OutlineInputBorder(),
              ),
              value: _endTimeIndex,
              items: _buildTimeDropdownItems(),
              onChanged: (value) {
                setState(() {
                  _endTimeIndex = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (_startTimeIndex != null &&
                _endTimeIndex != null &&
                _startTimeIndex! < _endTimeIndex!) {
              Navigator.of(context).pop({
                'startTimeIndex': _startTimeIndex,
                'endTimeIndex': _endTimeIndex,
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Por favor, selecione horários válidos.')),
              );
            }
          },
          child: const Text('Adicionar'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
      ],
    );
  }

  // Método para gerar os itens do Dropdown de horários
  List<DropdownMenuItem<int>> _buildTimeDropdownItems() {
    return List.generate(48, (index) {
      final hour = index ~/ 2;
      final minute = (index % 2) * 30;
      final timeLabel =
          '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      return DropdownMenuItem<int>(
        value: index,
        child: Text(timeLabel),
      );
    });
  }
}
