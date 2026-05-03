import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../features/pronostico/domain/entities/weather_forecast.dart';
import '../../../finca/presentation/bloc/finca_bloc.dart';
import '../bloc/finca_event_state.dart';
import '../../domain/entities/finca.dart';

class FincaPage extends StatefulWidget {
  const FincaPage({super.key});

  @override
  State<FincaPage> createState() => _FincaPageState();
}

class _FincaPageState extends State<FincaPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreCtrl;
  late TextEditingController _fincaCtrl;
  late TextEditingController _veredaCtrl;
  String _municipio = 'Pasto';
  double _altitud = 2527;
  double _hectareas = 3.0;
  String _riego = 'Lluvia';

  int? _editingId;
  List<Finca> _fincas = [];

  final _municipios = municipiosNarino.keys.toList();
  final _riegos = ['Lluvia', 'Aspersión', 'Goteo', 'Canal / acequia'];

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController();
    _fincaCtrl = TextEditingController();
    _veredaCtrl = TextEditingController();
    final state = context.read<FincaBloc>().state;
    if (state is FincaLoaded) {
      _fincas = state.fincas;
      _applyFinca(state.finca);
    }
  }

  void _applyFinca(Finca? f) {
    if (f == null) {
      _editingId = null;
      _nombreCtrl.clear();
      _fincaCtrl.clear();
      _veredaCtrl.clear();
      setState(() {
        _municipio = 'Pasto';
        _altitud = 2527;
        _hectareas = 3.0;
        _riego = 'Lluvia';
      });
      return;
    }
    _editingId = f.id;
    _nombreCtrl.text = f.nombreAgricultero;
    _fincaCtrl.text = f.nombreFinca;
    _veredaCtrl.text = f.vereda;
    setState(() {
      _municipio = f.municipio;
      _altitud = f.altitud.toDouble();
      _hectareas = f.hectareas;
      _riego = f.tipoRiego;
    });
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      context.read<FincaBloc>().add(SaveFincaEvent(Finca(
        id: _editingId,
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

  void _eliminar() {
    if (_editingId != null) {
      context.read<FincaBloc>().add(DeleteFincaEvent(_editingId!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Finca eliminada')),
      );
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _fincaCtrl.dispose();
    _veredaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.crema,
      body: BlocListener<FincaBloc, FincaState>(
        listener: (context, state) {
          if (state is FincaSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('¡Finca guardada exitosamente! 🌿')),
            );
          }
          if (state is FincaLoaded) {
            setState(() {
              _fincas = state.fincas;
            });
            // Sólo aplicamos si acabamos de guardar o cambiar algo activamente
            if (state.finca.id != _editingId && _editingId != null) {
              _applyFinca(state.finca);
            } else if (_editingId == null && _fincas.isNotEmpty && state is! FincaSaved) {
               _applyFinca(state.finca);
            }
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: AppColors.blanco,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Text('🏡 Perfil de Finca',
                        style: GoogleFonts.fraunces(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.verdeOscuro)),
                    const Spacer(),
                    Text('Registra los datos para predicciones personalizadas',
                        style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.gris)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: LayoutBuilder(
                    builder: (_, constraints) {
                      final isWide = constraints.maxWidth > 600;
                      final col1 = Column(
                        children: [
                          if (_fincas.isNotEmpty)
                            _FincaCard(
                              title: 'Tus Fincas',
                              children: [
                                DropdownButtonFormField<int?>(
                                  value: _editingId,
                                  decoration: InputDecoration(
                                    labelText: 'Seleccionar Finca',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  items: [
                                    ..._fincas.map((f) => DropdownMenuItem(
                                          value: f.id,
                                          child: Text('${f.nombreFinca} (${f.municipio})'),
                                        )),
                                    const DropdownMenuItem(
                                      value: null,
                                      child: Text('➕ Crear nueva finca', style: TextStyle(color: AppColors.verde)),
                                    ),
                                  ],
                                  onChanged: (id) {
                                    if (id == null) {
                                      _applyFinca(null);
                                    } else {
                                      final f = _fincas.firstWhere((f) => f.id == id);
                                      _applyFinca(f);
                                      context.read<FincaBloc>().add(SelectActiveFincaEvent(f));
                                    }
                                  },
                                ),
                              ],
                            ),
                          const SizedBox(height: 16),
                          _FincaCard(
                            title: _editingId == null ? 'Nueva finca' : 'Datos básicos',
                            children: [
                              _AgroField(ctrl: _nombreCtrl, label: 'Tu nombre', placeholder: 'Ej: Don Carlos Erazo',
                                  validator: (v) => v!.isEmpty ? 'Ingresa tu nombre' : null),
                              _AgroField(ctrl: _fincaCtrl, label: 'Nombre de tu finca', placeholder: 'Ej: Finca El Mirador',
                                  validator: (v) => v!.isEmpty ? 'Ingresa el nombre de la finca' : null),
                              _AgroField(ctrl: _veredaCtrl, label: 'Vereda (opcional)', placeholder: 'Ej: El Encano, La Cocha...'),
                              _AgroDropdown<String>(
                                label: 'Municipio',
                                value: _municipio,
                                items: _municipios.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                                onChanged: (v) {
                                  if (v != null) setState(() {
                                    _municipio = v;
                                    _altitud = municipiosNarino[v]!.altitud.toDouble();
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      );
                      final col2 = Column(
                        children: [
                          _FincaCard(
                            title: 'Características de la finca',
                            children: [
                              _AgroSliderSection(
                                label: 'Altitud',
                                value: _altitud,
                                unit: 'm.s.n.m.',
                                min: 1500, max: 3600, divisions: 210,
                                onChanged: (v) => setState(() => _altitud = v),
                              ),
                              _AgroSliderSection(
                                label: 'Tamaño de la finca',
                                value: _hectareas,
                                unit: 'ha',
                                min: 0.5, max: 50, divisions: 99,
                                onChanged: (v) => setState(() => _hectareas = v),
                              ),
                              const SizedBox(height: 8),
                              Text('Acceso a riego',
                                  style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.verdeOscuro)),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8, runSpacing: 8,
                                children: _riegos.map((r) {
                                  final sel = r == _riego;
                                  return GestureDetector(
                                    onTap: () => setState(() => _riego = r),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: sel ? AppColors.verde : AppColors.blanco,
                                        borderRadius: BorderRadius.circular(50),
                                        border: Border.all(color: sel ? AppColors.verde : AppColors.niebla, width: 2),
                                      ),
                                      child: Text(r,
                                          style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500,
                                              color: sel ? Colors.white : AppColors.verdeOscuro)),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ],
                      );
                      return Column(
                        children: [
                          if (isWide)
                            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Expanded(child: col1), const SizedBox(width: 20), Expanded(child: col2)
                            ])
                          else ...[col1, const SizedBox(height: 16), col2],
                          const SizedBox(height: 20),
                          Row(children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.save_rounded),
                                label: Text('Guardar perfil de finca',
                                    style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600)),
                                style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    backgroundColor: AppColors.verde, foregroundColor: Colors.white),
                                onPressed: _guardar,
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (_editingId != null)
                              OutlinedButton.icon(
                                icon: const Icon(Icons.delete_rounded, color: AppColors.riskHigh),
                                label: Text('Eliminar', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, color: AppColors.riskHigh)),
                                style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                    side: const BorderSide(color: AppColors.riskHigh)),
                                onPressed: _eliminar,
                              ),
                          ]),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FincaCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _FincaCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(title, style: GoogleFonts.fraunces(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.verdeOscuro)),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}

class _AgroField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, placeholder;
  final String? Function(String?)? validator;
  const _AgroField({required this.ctrl, required this.label, required this.placeholder, this.validator});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.verdeOscuro)),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            validator: validator,
            style: GoogleFonts.dmSans(fontSize: 14),
            decoration: InputDecoration(hintText: placeholder,
                hintStyle: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey.shade400)),
          ),
        ],
      ),
    );
  }
}

class _AgroDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  const _AgroDropdown({required this.label, required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.verdeOscuro)),
          const SizedBox(height: 6),
          DropdownButtonFormField<T>(
            value: value,
            style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.verdeOscuro),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFDDE8E0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFDDE8E0))),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            items: items,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _AgroSliderSection extends StatelessWidget {
  final String label, unit;
  final double value, min, max;
  final int divisions;
  final ValueChanged<double> onChanged;
  const _AgroSliderSection({required this.label, required this.value, required this.unit,
      required this.min, required this.max, required this.divisions, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(label, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.verdeOscuro)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(color: AppColors.niebla, borderRadius: BorderRadius.circular(6)),
              child: Text('${value == value.roundToDouble() ? value.toInt() : value.toStringAsFixed(1)} $unit',
                  style: GoogleFonts.fraunces(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.verde)),
            ),
          ]),
          Slider(value: value, min: min, max: max, divisions: divisions, onChanged: onChanged,
              activeColor: AppColors.verdeClaro, inactiveColor: const Color(0xFFDDE8E0)),
        ],
      ),
    );
  }
}
