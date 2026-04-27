import 'package:flutter/material.dart';
import '../models/lembrete_agua_model.dart';

class CadastroLembreteScreen extends StatefulWidget {
  const CadastroLembreteScreen({super.key});

  @override
  State<CadastroLembreteScreen> createState() =>
      _CadastroLembreteScreenState();
}

class _CadastroLembreteScreenState extends State<CadastroLembreteScreen> {
  int horaInicio = 8;
  int minutoInicio = 0;

  int horaFim = 22;
  int minutoFim = 0;

  int horasFreq = 1;
  int minutosFreq = 0;

  String? erroFrequencia;

  final TextEditingController horasController =
      TextEditingController(text: '1');
  final TextEditingController minutosController =
      TextEditingController(text: '0');

  Future<void> _selecionarHoraInicio() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: horaInicio, minute: minutoInicio), // Usa minuto atual
    );

    if (picked != null) {
      setState(() {
        horaInicio = picked.hour;
        minutoInicio = picked.minute; // Captura o minuto selecionado
      });
    }
  }

  Future<void> _selecionarHoraFim() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: horaFim, minute: minutoFim), // Usa minuto atual
    );

    if (picked != null) {
      setState(() {
        horaFim = picked.hour;
        minutoFim = picked.minute; // Captura o minuto selecionado
      });
    }
  }

  void _validarFrequencia() {
    setState(() {
      // 1. Converter inputs de frequência para minutos totais
      horasFreq = int.tryParse(horasController.text) ?? 0;
      minutosFreq = int.tryParse(minutosController.text) ?? 0;
      int frequenciaTotal = (horasFreq * 60) + minutosFreq;

      // 2. Calcular o intervalo disponível em minutos
      int inicioEmMinutos = (horaInicio * 60) + minutoInicio;
      int fimEmMinutos = (horaFim * 60) + minutoFim;
      int intervaloDisponivel = fimEmMinutos - inicioEmMinutos;

      // 3. Validação
      if (frequenciaTotal <= 0) {
        erroFrequencia = 'A frequência deve ser maior que zero';
      } else if (frequenciaTotal > intervaloDisponivel) {
        erroFrequencia = 'A frequência não pode ser maior que o intervalo definido';
      } else {
        erroFrequencia = null; // Tudo certo!
      }
    });
  }

  void _salvar() {
    _validarFrequencia();

    if (erroFrequencia == null) {
      int frequenciaTotal = (horasFreq * 60) + minutosFreq;

      // Criamos o modelo incluindo os novos campos de minutos
      final lembrete = LembreteAguaModel(
        id: DateTime.now().millisecondsSinceEpoch,
        frequenciaEmMinutos: frequenciaTotal,
        horaInicio: horaInicio,
        minutoInicio: minutoInicio, // Agora o dado real é enviado
        horaFim: horaFim,
        minutoFim: minutoFim,    // Agora o dado real é enviado
      );

      Navigator.pop(context, lembrete);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Lembrete')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 221, 221, 221),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // INÍCIO
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Início dos lembretes'),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selecionarHoraInicio,
                    child: Text('${horaInicio.toString().padLeft(2, '0')}:${minutoInicio.toString().padLeft(2, '0')}'),
                  ),
                ),

                const SizedBox(height: 15),

                // FIM
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Fim dos lembretes'),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selecionarHoraFim,
                    child: Text('${horaFim.toString().padLeft(2, '0')}:${minutoFim.toString().padLeft(2, '0')}'),
                  ),
                ),

                const SizedBox(height: 15),

                // FREQUÊNCIA
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Frequência dos lembretes'),
                ),
                const SizedBox(height: 5),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: horasController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Horas',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => _validarFrequencia(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: minutosController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Minutos',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => _validarFrequencia(),
                      ),
                    ),
                  ],
                ),

                if (erroFrequencia != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    erroFrequencia!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _salvar,
                    child: const Text('Salvar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}