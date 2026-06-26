import 'package:cinco_tigres_felizes/features/vaccines/domain/entities/vaccination_schedule.dart';
import 'package:cinco_tigres_felizes/features/vaccines/domain/repositories/i_vaccines_repository.dart';

/// Implementação falsa de [IVacinasRepository] para uso exclusivo em testes.
///
/// Não depende de assets, SharedPreferences ou qualquer infraestrutura real.
/// Permite controlar exatamente o que o serviço recebe em cada cenário de teste.
class FakeVacinasRepository implements IVacinasRepository {
  final CalendarioVacinas _calendario;
  Map<String, List<bool>> _doses;

  FakeVacinasRepository({
    CalendarioVacinas? calendario,
    Map<String, List<bool>>? doses,
  })  : _calendario = calendario ?? _calendarioVazio(),
        _doses = doses ?? {};

  @override
  Future<CalendarioVacinas> carregarCalendario() async => _calendario;

  @override
  Future<Map<String, List<bool>>> carregarDoses() async => Map.from(_doses);

  @override
  Future<void> salvarDoses(Map<String, List<bool>> doses) async {
    _doses = Map.from(doses);
  }

  static CalendarioVacinas _calendarioVazio() => CalendarioVacinas(
        criancas: [],
        adolescentes: [],
        adultos: [],
        gestantes: [],
        idosos: [],
      );

  /// Helpers para montar vacinas e calendários de teste de forma concisa.
  static Vacina vacina(String nome, {int doses = 1}) => Vacina(
        nome: nome,
        descricao: 'Descrição de $nome',
        doseTexto: '$doses dose(s)',
        quantidadeDeDoses: doses,
      );

  static CalendarioVacinas calendario({
    List<Vacina> criancas = const [],
    List<Vacina> adolescentes = const [],
    List<Vacina> adultos = const [],
    List<Vacina> gestantes = const [],
    List<Vacina> idosos = const [],
  }) =>
      CalendarioVacinas(
        criancas: criancas,
        adolescentes: adolescentes,
        adultos: adultos,
        gestantes: gestantes,
        idosos: idosos,
      );
}
