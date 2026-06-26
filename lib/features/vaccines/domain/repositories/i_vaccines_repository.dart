import 'package:cinco_tigres_felizes/features/vaccines/domain/entities/vaccination_schedule.dart';

abstract class IVacinasRepository {
  Future<CalendarioVacinas> carregarCalendario();
  Future<Map<String, List<bool>>> carregarDoses();
  Future<void> salvarDoses(Map<String, List<bool>> doses);
}
