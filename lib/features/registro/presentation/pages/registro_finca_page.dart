import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../features/pronostico/domain/entities/weather_forecast.dart';
import '../../../finca/presentation/bloc/finca_bloc.dart';
import '../../../finca/presentation/bloc/finca_event_state.dart';
import '../../../finca/domain/entities/finca.dart';

/// RegistroFincaPage — pantalla de primer uso.
///
/// Diseño optimizado para agricultores mayores de 45 años:
///   - Texto grande (mínimo 15px)
///   - Botones amplios (padding vertical ≥ 16)
///   - Una sola columna
///   - Sin tecnicismos
class RegistroFincaPage extends StatefulWidget {
  const RegistroFincaPage({super.key});

  @override
  State<RegistroFincaPage> createState() => _RegistroFincaPageState();
}

class _RegistroFincaPageState extends State<RegistroFincaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _fincaCtrl = TextEditingController();
  final _veredaCtrl = TextEditingController();

  String _municipio = 'Pasto';
  double _altitud = 2527;
  double _hectareas = 2.0;
  String _riego = 'Lluvia';
  int _step = 0;

  final _municipios = municipiosNarino.keys.toList();
  final _riegos = ['Lluvia', 'Aspersión', 'Goteo', 'Canal / acequia'];

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _fincaCtrl.dispose();
    _veredaCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      context.read<FincaBloc>().add(SaveFincaEvent(Finca(
            nombreAgricultero: _nombreCtrl.text.trim(),
            nombreFinca: _fincaCtrl.text.trim(),
            vereda: _veredaCtrl.text.trim(),
            municipio: _municipio,
            altitud: _altitud.round(),
            hectareas: _hectareas,
            tipoRiego: _riego,
          )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FincaBloc, FincaState>(
      listener: (context, state) {
        if (state is FincaSaved) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
        if (state is FincaError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ ${state.message}')),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.crema,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ────────────────────────────────────────────────
                  _Header(step: _step),
                  const SizedBox(height: 28),

                  // ── Paso 0: Datos personales ──────────────────────────────
                  if (_step == 0) ...[
                    _SectionTitle('¿Cómo se llama usted?'),
                    const SizedBox(height: 12),
                    _BigField(
                      controller: _nombreCtrl,
                      hint: 'Ej: Don Carlos Erazo',
                      icon: Icons.person_rounded,
                      validator: (v) =>
                          v == null || v.trim().isEmpty
                              ? 'Por favor escriba su nombre'
                              : null,
                    ),
                    const SizedBox(height: 20),
                    _SectionTitle('¿Cómo se llama su finca?'),
                    const SizedBox(height: 12),
                    _BigField(
                      controller: _fincaCtrl,
                      hint: 'Ej: Finca El Mirador',
                      icon: Icons.home_rounded,
                      validator: (v) =>
                          v == null || v.trim().isEmpty
                              ? 'Por favor escriba el nombre de su finca'
                              : null,
                    ),
                    const SizedBox(height: 20),
                    _SectionTitle('¿En qué vereda queda? (opcional)'),
                    const SizedBox(height: 12),
                    _BigField(
                      controller: _veredaCtrl,
                      hint: 'Ej: El Encano, La Cocha...',
                      icon: Icons.place_rounded,
                    ),
                    const SizedBox(height: 32),
                    _NextButton(
                      label: 'Siguiente →',
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _step = 1);
                        }
                      },
                    ),
                  ],

                  // ── Paso 1: Datos de finca ────────────────────────────────
                  if (_step == 1) ...[
                    _SectionTitle('¿En qué municipio está su finca?'),
                    const SizedBox(height: 12),
                    _BigDropdown<String>(
                      value: _municipio,
                      items: _municipios
                          .map((m) =>
                              DropdownMenuItem(value: m, child: Text(m)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            _municipio = v;
                            _altitud =
                                municipiosNarino[v]!.altitud.toDouble();
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    _SectionTitle('¿A qué altura está su finca?'),
                    _SliderLabel(
                        value: _altitud, unit: 'm.s.n.m.', large: true),
                    Slider(
                      value: _altitud,
                      min: 1500,
                      max: 3600,
                      divisions: 210,
                      activeColor: AppColors.verde,
                      inactiveColor: AppColors.niebla,
                      onChanged: (v) => setState(() => _altitud = v),
                    ),
                    const SizedBox(height: 24),
                    _SectionTitle('¿Cuántas hectáreas tiene?'),
                    _SliderLabel(value: _hectareas, unit: 'ha', large: true),
                    Slider(
                      value: _hectareas,
                      min: 0.5,
                      max: 50,
                      divisions: 99,
                      activeColor: AppColors.verde,
                      inactiveColor: AppColors.niebla,
                      onChanged: (v) => setState(() => _hectareas = v),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20),
                            foregroundColor: AppColors.verde,
                            side: const BorderSide(color: AppColors.verde),
                          ),
                          onPressed: () => setState(() => _step = 0),
                          child: Text('← Atrás',
                              style: GoogleFonts.dmSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _NextButton(
                            label: 'Siguiente →',
                            onPressed: () => setState(() => _step = 2),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // ── Paso 2: Tipo de riego ─────────────────────────────────
                  if (_step == 2) ...[
                    _SectionTitle('¿Qué tipo de riego usa usted?'),
                    const SizedBox(height: 16),
                    ..._riegos.map((r) => _RiegoTile(
                          label: r,
                          selected: r == _riego,
                          onTap: () => setState(() => _riego = r),
                        )),
                    const SizedBox(height: 32),

                    // Resumen antes de guardar
                    _ResumenCard(
                      nombre: _nombreCtrl.text.trim(),
                      finca: _fincaCtrl.text.trim(),
                      municipio: _municipio,
                      altitud: _altitud,
                      hectareas: _hectareas,
                      riego: _riego,
                    ),
                    const SizedBox(height: 24),

                    BlocBuilder<FincaBloc, FincaState>(
                      builder: (context, state) {
                        final loading = state is FincaLoading;
                        return Column(
                          children: [
                            _NextButton(
                              label: loading
                                  ? 'Guardando…'
                                  : '✅ Empezar a usar AgroClima',
                              onPressed: loading ? null : _guardar,
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 52),
                                foregroundColor: AppColors.verde,
                                side:
                                    const BorderSide(color: AppColors.verde),
                              ),
                              onPressed: () => setState(() => _step = 1),
                              child: Text('← Corregir datos',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ],
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Widgets internos ──────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final int step;
  const _Header({required this.step});

  @override
  Widget build(BuildContext context) {
    const steps = ['Sus datos', 'Su finca', 'Confirmación'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Text('🌿', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 10),
          Text('AgroClima Nariño',
              style: GoogleFonts.fraunces(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.verdeOscuro)),
        ]),
        const SizedBox(height: 4),
        Text('Registro de su finca — Paso ${step + 1} de 3',
            style: GoogleFonts.dmSans(
                fontSize: 13, color: AppColors.gris)),
        const SizedBox(height: 12),
        Row(
          children: List.generate(3, (i) {
            final active = i == step;
            final done = i < step;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < 2 ? 6 : 0),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 6,
                      decoration: BoxDecoration(
                        color: done
                            ? AppColors.verdeMedio
                            : active
                                ? AppColors.verdeClaro
                                : AppColors.niebla,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(steps[i],
                        style: GoogleFonts.dmSans(
                            fontSize: 10,
                            color: active
                                ? AppColors.verde
                                : AppColors.gris,
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.w400)),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: GoogleFonts.fraunces(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.verdeOscuro,
            height: 1.3));
  }
}

class _BigField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;

  const _BigField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: GoogleFonts.dmSans(fontSize: 17, color: AppColors.verdeOscuro),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.dmSans(fontSize: 16, color: Colors.grey.shade400),
        prefixIcon: Icon(icon, color: AppColors.verde),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.niebla, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.niebla, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.verdeClaro, width: 2),
        ),
        filled: true,
        fillColor: AppColors.blanco,
      ),
    );
  }
}

class _BigDropdown<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _BigDropdown(
      {required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      style: GoogleFonts.dmSans(
          fontSize: 17, color: AppColors.verdeOscuro),
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.niebla, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.niebla, width: 2),
        ),
        filled: true,
        fillColor: AppColors.blanco,
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}

class _SliderLabel extends StatelessWidget {
  final double value;
  final String unit;
  final bool large;

  const _SliderLabel(
      {required this.value, required this.unit, this.large = false});

  @override
  Widget build(BuildContext context) {
    final display =
        value == value.roundToDouble() ? value.toInt().toString() : value.toStringAsFixed(1);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        '$display $unit',
        style: GoogleFonts.fraunces(
            fontSize: large ? 28 : 22,
            fontWeight: FontWeight.w900,
            color: AppColors.verde),
      ),
    );
  }
}

class _RiegoTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RiegoTile(
      {required this.label, required this.selected, required this.onTap});

  static const _icons = {
    'Lluvia': '🌧️',
    'Aspersión': '💦',
    'Goteo': '💧',
    'Canal / acequia': '🏞️',
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.verde : AppColors.blanco,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? AppColors.verde : AppColors.niebla,
              width: 2),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: AppColors.verde.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(_icons[label] ?? '🌿',
                style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 16),
            Text(label,
                style: GoogleFonts.dmSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? Colors.white
                        : AppColors.verdeOscuro)),
            const Spacer(),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 22),
          ],
        ),
      ),
    );
  }
}

class _ResumenCard extends StatelessWidget {
  final String nombre, finca, municipio, riego;
  final double altitud, hectareas;

  const _ResumenCard({
    required this.nombre,
    required this.finca,
    required this.municipio,
    required this.altitud,
    required this.hectareas,
    required this.riego,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.verdeOscuro, AppColors.verde],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Resumen de su finca',
              style: GoogleFonts.fraunces(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.menta)),
          const SizedBox(height: 12),
          _ResRow('👨‍🌾 Agricultor', nombre),
          _ResRow('🏡 Finca', finca),
          _ResRow('📍 Municipio', municipio),
          _ResRow('⛰️ Altitud', '${altitud.round()} m.s.n.m.'),
          _ResRow('🌾 Hectáreas', '${hectareas.toStringAsFixed(1)} ha'),
          _ResRow('💧 Riego', riego),
        ],
      ),
    );
  }
}

class _ResRow extends StatelessWidget {
  final String label, value;
  const _ResRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Text(label,
                  style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.65)))),
          Expanded(
              flex: 3,
              child: Text(value,
                  style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white))),
        ],
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _NextButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.verde,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: GoogleFonts.dmSans(
              fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
