import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class CalendarioPage extends StatefulWidget {
  const CalendarioPage({super.key});

  @override
  State<CalendarioPage> createState() => _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage> {
  String _cultivoSel = 'Papa';

  static const _cultivos = [
    ('🥔', 'Papa'), ('☕', 'Café'), ('🫐', 'Mora'), ('🥬', 'Hortalizas'),
  ];
  static const _meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];

  static const _calData = {
    'Papa': {
      'desc': 'La papa se siembra principalmenten en feb–mar y jul–ago, aprovechando el inicio de las lluvias. La cosecha ocurre 90–120 días después. Altitud ideal: 2.200–3.400 m.',
      'siembra': [1, 2, 6, 7],
      'cosecha': [4, 5, 10, 11],
      'fumigacion': [1, 2, 6, 7, 8],
    },
    'Café': {
      'desc': 'El café de Nariño tiene cosecha principal entre octubre y enero. La siembra (trasplante) se hace en noviembre–diciembre en época seca. Altitud ideal: 1.400–2.000 m.',
      'siembra': [10, 11, 0],
      'cosecha': [9, 10, 11, 0, 1],
      'fumigacion': [5, 6, 7],
    },
    'Mora': {
      'desc': 'La mora produce prácticamente todo el año. La mejor calidad se da entre junio–agosto. Fumigación preventiva al inicio de lluvias. Altitud ideal: 1.800–2.800 m.',
      'siembra': [2, 3, 8, 9],
      'cosecha': [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
      'fumigacion': [3, 4, 8, 9],
    },
    'Hortalizas': {
      'desc': 'Brócoli, lechuga, zanahoria tienen ciclos cortos de 30–90 días. Se siembran varias veces al año con riego. Altitud ideal: 2.000–3.000 m.',
      'siembra': [1, 2, 3, 7, 8, 9],
      'cosecha': [3, 4, 5, 6, 10, 11],
      'fumigacion': [1, 2, 3, 7, 8, 9],
    },
  };

  @override
  Widget build(BuildContext context) {
    final mesActual = DateTime.now().month - 1; // 0-indexed
    final data = _calData[_cultivoSel]!;
    final siembra = List<int>.from(data['siembra'] as List);
    final cosecha = List<int>.from(data['cosecha'] as List);
    final fumig = List<int>.from(data['fumigacion'] as List);

    // Actividades del mes actual
    final acts = <(String, String)>[];
    if (siembra.contains(mesActual)) acts.add(('🌱', 'Buen mes para sembrar — aprovecha el inicio de lluvias'));
    if (cosecha.contains(mesActual)) acts.add(('🌾', 'Temporada de cosecha — revisa madurez cada 3 días'));
    if (fumig.contains(mesActual)) acts.add(('💊', 'Mes de fumigación preventiva — aplica en días secos y sin viento'));
    if (acts.isEmpty) acts.add(('⏳', 'Mes de mantenimiento — riega y abona según necesidad'));

    return Scaffold(
      backgroundColor: AppColors.crema,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: AppColors.blanco,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(children: [
                Text('📅 Calendario Agrícola',
                    style: GoogleFonts.fraunces(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.verdeOscuro)),
                const Spacer(),
                Text('Ventanas óptimas por cultivo',
                    style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.gris)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selector cultivoo
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.blanco, borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.niebla),
                      boxShadow: const [BoxShadow(color: Color(0x0C1A3D2B), blurRadius: 16, offset: Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Selecciona cultivo para ver el calendario',
                            style: GoogleFonts.fraunces(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.verdeOscuro)),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8, runSpacing: 8,
                          children: _cultivos.map((c) {
                            final nombre = c.$2;
                            final sel = nombre == _cultivoSel;
                            return GestureDetector(
                              onTap: () => setState(() => _cultivoSel = nombre),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: sel ? AppColors.verde : AppColors.blanco,
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(color: sel ? AppColors.verde : AppColors.niebla, width: 2),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(c.$1, style: const TextStyle(fontSize: 15)),
                                    const SizedBox(width: 6),
                                    Text(nombre, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500,
                                        color: sel ? Colors.white : AppColors.verdeOscuro)),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Descripción del cultivo
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.niebla, borderRadius: BorderRadius.circular(10),
                      border: Border(left: BorderSide(color: AppColors.verde, width: 4)),
                    ),
                    child: Text(data['desc'] as String,
                        style: GoogleFonts.dmSans(fontSize: 14, height: 1.6, color: AppColors.verdeOscuro)),
                  ),
                  const SizedBox(height: 16),

                  // Tabla calendario
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.blanco, borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.niebla),
                      boxShadow: const [BoxShadow(color: Color(0x0C1A3D2B), blurRadius: 16, offset: Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                          child: Text('Calendario anual — $_cultivoSel',
                              style: GoogleFonts.fraunces(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.verdeOscuro)),
                        ),
                        const Divider(height: 1, color: AppColors.niebla),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                // Header meses
                                Row(
                                  children: [
                                    const SizedBox(width: 100),
                                    ..._meses.asMap().entries.map((e) => _MesHeader(
                                      mes: e.value, isActual: e.key == mesActual)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                _CalRow(label: '🌱 Siembra', meses: siembra, color: AppColors.riskLow, bg: AppColors.niebla, mesActual: mesActual),
                                _CalRow(label: '🌾 Cosecha', meses: cosecha, color: const Color(0xFF92400E), bg: const Color(0xFFFEF3C7), mesActual: mesActual),
                                _CalRow(label: '💊 Fumigar', meses: fumig, color: AppColors.azul, bg: const Color(0xFFDBEAFE), mesActual: mesActual),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: AppColors.niebla),
                        // Mes actual
                        Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: GoogleFonts.fraunces(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.verdeOscuro),
                                  children: [
                                    const TextSpan(text: '📅 Este mes — '),
                                    TextSpan(text: _meses[mesActual],
                                        style: const TextStyle(color: AppColors.verde)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...acts.map((a) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.niebla,
                                  border: const Border(left: BorderSide(color: AppColors.verdeClaro, width: 4)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Text(a.$1, style: const TextStyle(fontSize: 18)),
                                    const SizedBox(width: 10),
                                    Expanded(child: Text(a.$2,
                                        style: GoogleFonts.dmSans(fontSize: 13, height: 1.5))),
                                  ],
                                ),
                              )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MesHeader extends StatelessWidget {
  final String mes;
  final bool isActual;
  const _MesHeader({required this.mes, required this.isActual});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: isActual ? AppColors.verde : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(mes,
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
              fontSize: 10, fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              color: isActual ? Colors.white : AppColors.gris)),
    );
  }
}

class _CalRow extends StatelessWidget {
  final String label;
  final List<int> meses;
  final Color color, bg;
  final int mesActual;
  const _CalRow({required this.label, required this.meses, required this.color, required this.bg, required this.mesActual});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.verdeOscuro))),
          ...List.generate(12, (i) {
            final active = meses.contains(i);
            return Container(
              width: 36, height: 36, margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: active ? bg : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: i == mesActual ? AppColors.verde : Colors.transparent, width: 2),
              ),
              child: Center(
                child: Text(active ? '●' : '·',
                    style: TextStyle(fontSize: active ? 14 : 12,
                        color: active ? color : const Color(0xFFCCCCCC))),
              ),
            );
          }),
        ],
      ),
    );
  }
}
