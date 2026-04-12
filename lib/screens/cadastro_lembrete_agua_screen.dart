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
  int horaFim = 22;

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
      initialTime: TimeOfDay(hour: horaInicio, minute: 0),
    );

    if (picked != null) {
      setState(() {
        horaInicio = picked.hour;
      });
    }
  }

  Future<void> _selecionarHoraFim() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: horaFim, minute: 0),
    );

    if (picked != null) {
      setState(() {
        horaFim = picked.hour;
      });
    }
  }

  void _validarFrequencia() {
    final h = int.tryParse(horasController.text) ?? -1;
    final m = int.tryParse(minutosController.text) ?? -1;

    if (h < 0 || m < 0 || (h == 0 && m == 0)) {
      setState(() {
        erroFrequencia = 'Frequência inválida';
      });
      return;
    }

    final totalMin = h * 60 + m;

    final intervaloTotal = (horaFim - horaInicio) * 60;

    if (totalMin > intervaloTotal) {
      setState(() {
        erroFrequencia =
            'Frequência maior que o intervalo (${intervaloTotal} min)';
      });
      return;
    }

    setState(() {
      erroFrequencia = null;
      horasFreq = h;
      minutosFreq = m;
    });
  }

  void _salvar() {
    if (horaFim <= horaInicio) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Intervalo inválido')),
      );
      return;
    }

    _validarFrequencia();

    if (erroFrequencia != null) return;

    final frequenciaTotal = horasFreq * 60 + minutosFreq;

    final lembrete = LembreteAguaModel(
      id: DateTime.now().millisecondsSinceEpoch,
      frequenciaEmMinutos: frequenciaTotal,
      horaInicio: horaInicio,
      horaFim: horaFim,
    );

    debugPrint('Lembrete criado: $lembrete');

    Navigator.pop(context, lembrete);
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
                    child: Text('${horaInicio.toString().padLeft(2, '0')}:00'),
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
                    child: Text('${horaFim.toString().padLeft(2, '0')}:00'),
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