import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final String baseUrl =
      'http://localhost:5555/api'; // Atualize para o URL correto
  final storage = const FlutterSecureStorage();

  // Método para fazer login do profissional
  Future<bool> loginProfissional(String email, String senha) async {
    final url = Uri.parse('$baseUrl/profissional/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'senha': senha}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Supondo que o backend retorne um token e o ID do profissional
      String token =
          data['token']; // Ajuste conforme a resposta real do backend
      String profissionalId = data['profissional']['_id'];

      // Armazenar o token e o ID do profissional de forma segura
      await storage.write(key: 'token', value: token);
      await storage.write(key: 'profissionalId', value: profissionalId);

      return true;
    } else {
      return false;
    }
  }

  // Método para registrar um novo profissional (se necessário)
  Future<bool> registerProfissional(
      Map<String, dynamic> profissionalData) async {
    final url = Uri.parse('$baseUrl/profissional/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(profissionalData),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  // Obter o ID do profissional logado
  Future<String?> getProfissionalId() async {
    return await storage.read(key: 'profissionalId');
  }

  // Obter o token de autenticação armazenado
  Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  // Obter horários disponíveis
  Future<List<dynamic>> getHorariosDisponiveis() async {
    final profissionalId = await getProfissionalId();
    if (profissionalId == null) {
      throw Exception('Profissional não autenticado');
    }

    final url = Uri.parse('$baseUrl/profissional/$profissionalId/horarios');
    final token = await getToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['horariosDisponiveis'];
    } else {
      throw Exception('Erro ao carregar horários');
    }
  }

  // Método para adicionar horário disponível
  Future<void> adicionarHorarioDisponivel(
      Map<String, dynamic> novoHorario) async {
    final profissionalId = await getProfissionalId();
    if (profissionalId == null) {
      throw Exception('Profissional não autenticado');
    }

    final url = Uri.parse('$baseUrl/profissional/$profissionalId/horarios');
    final token = await getToken();

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'horarios': [novoHorario]
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao adicionar horário');
    }
  }

  // Remover horário disponível
  Future<void> removerHorarioDisponivel(String horarioId) async {
    final profissionalId = await getProfissionalId();
    if (profissionalId == null) {
      throw Exception('Profissional não autenticado');
    }

    final url =
        Uri.parse('$baseUrl/profissional/$profissionalId/horarios/$horarioId');
    final token = await getToken();

    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception(response.statusCode);
    }
  }

  Future<List<dynamic>> getConsultas() async {
    final profissionalId = await getProfissionalId();
    if (profissionalId == null) {
      throw Exception('Profissional não autenticado');
    }

    final url = Uri.parse('$baseUrl/consulta/profissional/$profissionalId');
    final token = await getToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data; // Verifica se é uma lista de consultas
      } else if (data['consultas'] != null) {
        return data[
            'consultas']; // Caso o backend retorne consultas dentro de outro objeto
      } else {
        throw Exception('Formato inesperado da resposta do servidor');
      }
    } else {
      throw Exception('Erro ao carregar consultas');
    }
  }

// Método para buscar paciente por ID
  Future<Map<String, dynamic>> getPacienteById(String pacienteId) async {
    final url = Uri.parse('$baseUrl/paciente/$pacienteId');
    final token = await getToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Erro ao carregar dados do paciente');
    }
  }

  //Deletar consulta
  Future<void> deleteConsulta(String consultaId) async {
    final response = await http.delete(
        Uri.parse(
          '$baseUrl/consulta/$consultaId',
        ),
        headers: {
          'Content-Type': 'application/json',
        });

    if (response.statusCode != 200) {
      throw Exception('Erro ao deletar consulta');
    }
  }

  Future<Map<String, dynamic>> getConsultaById(String consultaId) async {
    final url = Uri.parse('$baseUrl/consulta/$consultaId');
    final token = await getToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Erro ao carregar detalhes da consulta');
    }
  }
}
