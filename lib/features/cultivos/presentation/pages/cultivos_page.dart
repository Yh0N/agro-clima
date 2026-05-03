import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class CultivosPage extends StatefulWidget {
  const CultivosPage({super.key});

  @override
  State<CultivosPage> createState() => _CultivosPageState();
}

class _CultivosPageState extends State<CultivosPage> {
  final Set<String> _seleccionados = {'Papa', 'Mora'};

  static const _cultivos = [
    ('🥔', 'Papa'), ('☕', 'Café'), ('🫐', 'Mora'), ('🥬', 'Hortalizas'),
    ('🌽', 'Maíz'), ('🍅', 'Tomate de árbol'), ('🫘', 'Fríjol'),
    ('🟠', 'Lulo'), ('🍓', 'Fresa'), ('💚', 'Arveja'),
    ('🥕', 'Zanahoria'), ('🧅', 'Cebolla'),
  ];

  static const _info = {
    'Papa': ('2.200–3.400 m', '4–14°C', '600–1mm/año', '90–120 días', [
      'Muy sensible a heladas. Protege cuando temp < 3°C.',
      'Fumigación preventiva contra lancha: cada 8-15 días en época húmeda.',
      'Gusano blanco: usa trampas con feromona.',
      'Evita riego por aspersión en noches frías.',
    ]),
    'Café': ('1.400–2.000 m', '18–24°C', '1.800–2.500mm/año', '7–9 meses', [
      'No tolera heladas. Altitud recomendada en Nariño: <2.000m.',
      'Floración en meses secos. Cosecha principal: nov–ene.',
      'El "café de Nariño" a 1.800m es reconocido internacionalmente.',
      'Poda en enero–febrero para mantener productividad.',
    ]),
    'Mora': ('1.800–2.800 m', '12–18°C', '1.200–2.000mm/año', 'Continua', [
      'Produce todo el año si hay buen manejo.',
      'Sensible a exceso de lluvia (Botrytis).',
      'Cosecha cada 8–12 días en verano, 12–16 días en invierno.',
      'Poda de renovación cada 2 años.',
    ]),
    'Hortalizas': ('2.000–3.000 m', '8–18°C', '600–1.200mm/año', '30–90 días', [
      'Brócoli, coliflor, lechuga, espinaca se adaptan bien.',
      'Ciclos cortos: ideal para rotar con papa.',
      'Sensibles a heladas. Usa invernadero artesanal en zonas altas.',
      'Mercado local en Pasto: demanda constante.',
    ]),
  };

  Map<String, dynamic> _getInfo(String cultivo) {
    final i = _info[cultivo];
    if (i == null) return {
      'altitud': 'Variable', 'temp': 'Variable', 'lluvia': 'Variable', 'ciclo': 'Variable',
      'tips': ['Consulta con el SENA o tu agrónomo local.', 'Usa semilla certificada.', 'Lleva registro de cosechas.']
    };
    return {'altitud': i.$1, 'temp': i.$2, 'lluvia': i.$3, 'ciclo': i.$4, 'tips': i.$5};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.crema,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: AppColors.blanco,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(children: [
                Text('🌱 Mis Cultivos',
                    style: GoogleFonts.fraunces(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.verdeOscuro)),
                const Spacer(),
                Text('Consejos específicos por especie',
                    style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.gris)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selector chips
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.blanco,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.niebla),
                      boxShadow: const [BoxShadow(color: Color(0x0C1A3D2B), blurRadius: 16, offset: Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('¿Qué cultivas actualmente?',
                            style: GoogleFonts.fraunces(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.verdeOscuro)),
                        const SizedBox(height: 4),
                        Text('Puedes seleccionar varios',
                            style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.gris)),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _cultivos.map((c) {
                            final nombre = c.$2;
                            final sel = _seleccionados.contains(nombre);
                            return GestureDetector(
                              onTap: () => setState(() {
                                if (sel) _seleccionados.remove(nombre);
                                else _seleccionados.add(nombre);
                              }),
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
                                    Text(nombre,
                                        style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500,
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
                  const SizedBox(height: 20),
                  if (_seleccionados.isNotEmpty) ...[
                    Text('Información de tus cultivos',
                        style: GoogleFonts.fraunces(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.verdeOscuro)),
                    const SizedBox(height: 12),
                    ..._seleccionados.map((nombre) {
                      final info = _getInfo(nombre);
                      final emoji = _cultivos.firstWhere((c) => c.$2 == nombre, orElse: () => ('🌿', nombre)).$1;
                      final tips = info['tips'] as List;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.blanco,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.niebla),
                          boxShadow: const [BoxShadow(color: Color(0x0C1A3D2B), blurRadius: 16, offset: Offset(0, 4))],
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
                              child: Row(
                                children: [
                                  Text(emoji, style: const TextStyle(fontSize: 26)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(nombre,
                                        style: GoogleFonts.fraunces(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.verdeOscuro)),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(color: AppColors.niebla, borderRadius: BorderRadius.circular(20)),
                                    child: Text('Activo',
                                        style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.verdeMedio)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 22),
                              child: GridView.count(
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                childAspectRatio: 3.5,
                                children: [
                                  _InfoItem('⛰️ Altitud', info['altitud'] as String),
                                  _InfoItem('🌡️ Temperatura', info['temp'] as String),
                                  _InfoItem('🌧️ Lluvia', info['lluvia'] as String),
                                  _InfoItem('📅 Ciclo', info['ciclo'] as String),
                                ],
                              ),
                            ),
                            const Divider(height: 20, color: AppColors.niebla),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('💡 Consejos clave para Nariño:',
                                      style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.verde)),
                                  const SizedBox(height: 8),
                                  ...tips.map((t) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 3),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('• ', style: TextStyle(color: AppColors.verde, fontWeight: FontWeight.bold)),
                                        Expanded(child: Text(t.toString(),
                                            style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.verdeOscuro, height: 1.5))),
                                      ],
                                    ),
                                  )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ] else
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            const Text('🌾', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 12),
                            Text('Selecciona tus cultivos arriba para ver información y consejos específicos.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.gris, height: 1.6)),
                          ],
                        ),
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

class _InfoItem extends StatelessWidget {
  final String label, value;
  const _InfoItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.gris, letterSpacing: 0.3)),
            Text(value, style: GoogleFonts.fraunces(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.verdeOscuro)),
          ],
        ),
      ],
    );
  }
}
