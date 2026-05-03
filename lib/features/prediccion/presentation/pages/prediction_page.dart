import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../prediccion/presentation/bloc/prediction_bloc.dart';
import '../../../prediccion/presentation/bloc/prediction_event_state.dart';
import '../../../prediccion/domain/entities/frost_prediction.dart';

class PredictionPage extends StatefulWidget {
  const PredictionPage({super.key});

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  double _altitud = 2527;
  double _tempMin = 6;
  double _humedad = 75;
  double _viento = 12;
  double _nubosidad = 40;
  int _mes = DateTime.now().month;

  static const _meses = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];

  void _predict() {
    context.read<PredictionBloc>().add(PredictFrostEvent(
      altitud: _altitud.round(),
      tempMin: _tempMin,
      humedad: _humedad,
      mes: _mes,
      viento: _viento,
      nubosidad: _nubosidad,
    ));
  }

  @override
  void initState() {
    super.initState();
    _predict();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.crema,
      body: Column(
        children: [
          Container(
            color: AppColors.blanco,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Text('🤖 Predicción IA',
                    style: GoogleFonts.fraunces(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.verdeOscuro)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCE8E0),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('NUEVO',
                      style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.riskHigh)),
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;
                final inputPanel = _InputPanel(
                  altitud: _altitud, tempMin: _tempMin, humedad: _humedad,
                  viento: _viento, nubosidad: _nubosidad, mes: _mes,
                  meses: _meses,
                  onAltitudChanged: (v) { setState(() => _altitud = v); _predict(); },
                  onTempChanged: (v) { setState(() => _tempMin = v); _predict(); },
                  onHumedadChanged: (v) { setState(() => _humedad = v); _predict(); },
                  onVientoChanged: (v) { setState(() => _viento = v); _predict(); },
                  onNubosidadChanged: (v) { setState(() => _nubosidad = v); _predict(); },
                  onMesChanged: (v) { setState(() => _mes = v); _predict(); },
                );
                final resultPanel = const _ResultPanel();

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: inputPanel)),
                      Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: resultPanel)),
                    ],
                  );
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(children: [inputPanel, const SizedBox(height: 16), resultPanel]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InputPanel extends StatelessWidget {
  final double altitud, tempMin, humedad, viento, nubosidad;
  final int mes;
  final List<String> meses;
  final ValueChanged<double> onAltitudChanged, onTempChanged, onHumedadChanged,
      onVientoChanged, onNubosidadChanged;
  final ValueChanged<int> onMesChanged;

  const _InputPanel({
    required this.altitud, required this.tempMin, required this.humedad,
    required this.viento, required this.nubosidad, required this.mes,
    required this.meses, required this.onAltitudChanged, required this.onTempChanged,
    required this.onHumedadChanged, required this.onVientoChanged,
    required this.onNubosidadChanged, required this.onMesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text('🌡️ Predicción de Riesgo de Helada',
              style: GoogleFonts.fraunces(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.verdeOscuro)),
          const SizedBox(height: 20),
          _AgroSlider(label: 'Altitud de tu finca', value: altitud, unit: 'm.s.n.m.',
              min: 1500, max: 3600, divisions: 210, onChanged: onAltitudChanged),
          _AgroSlider(label: 'Temperatura mínima esta noche', value: tempMin, unit: '°C',
              min: -5, max: 20, divisions: 50, onChanged: onTempChanged),
          _AgroSlider(label: 'Humedad relativa', value: humedad, unit: '%',
              min: 20, max: 100, divisions: 80, onChanged: onHumedadChanged),
          _AgroSlider(label: 'Velocidad del viento', value: viento, unit: 'km/h',
              min: 0, max: 60, divisions: 60, onChanged: onVientoChanged),
          _AgroSlider(label: 'Nubosidad', value: nubosidad, unit: '%',
              min: 0, max: 100, divisions: 100, onChanged: onNubosidadChanged),
          const SizedBox(height: 4),
          Text('Mes del año',
              style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.verdeOscuro)),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: mes,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFDDE8E0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFDDE8E0))),
            ),
            style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.verdeOscuro),
            items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text(meses[i]))),
            onChanged: (v) { if (v != null) onMesChanged(v); },
          ),
        ],
      ),
    );
  }
}

class _AgroSlider extends StatelessWidget {
  final String label;
  final double value, min, max;
  final int divisions;
  final String unit;
  final ValueChanged<double> onChanged;

  const _AgroSlider({required this.label, required this.value, required this.unit,
      required this.min, required this.max, required this.divisions, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.verdeOscuro)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: AppColors.niebla, borderRadius: BorderRadius.circular(6)),
                child: Text('${value == value.toInt() ? value.toInt() : value.toStringAsFixed(1)} $unit',
                    style: GoogleFonts.fraunces(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.verde)),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
              activeTrackColor: AppColors.verdeClaro, inactiveTrackColor: const Color(0xFFDDE8E0),
              thumbColor: AppColors.verde,
            ),
            child: Slider(value: value, min: min, max: max, divisions: divisions, onChanged: onChanged),
          ),
        ],
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PredictionBloc, PredictionState>(
      builder: (context, state) {
        if (state is PredictionLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.verde));
        }
        if (state is PredictionLoaded) {
          return Column(
            children: [
              _FrostResultCard(prediction: state.prediction),
              const SizedBox(height: 16),
              if (state.spray != null) _SprayCard(spray: state.spray!),
              const SizedBox(height: 16),
              _DecisionTreeCard(prediction: state.prediction),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _FrostResultCard extends StatelessWidget {
  final FrostPrediction prediction;
  const _FrostResultCard({required this.prediction});

  Color get _riskColor {
    switch (prediction.level) {
      case RiskLevel.high: return AppColors.riskHigh;
      case RiskLevel.medium: return AppColors.riskMedium;
      case RiskLevel.low: return AppColors.riskLow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.niebla),
        boxShadow: const [BoxShadow(color: Color(0x0C1A3D2B), blurRadius: 16, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Text('Resultado: Riesgo de Helada',
              style: GoogleFonts.fraunces(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.verdeOscuro)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SemaforoDot2(emoji: '❄️', label: 'ALTO', active: prediction.level == RiskLevel.high, color: AppColors.riskHigh),
              const SizedBox(width: 12),
              _SemaforoDot2(emoji: '⚠️', label: 'MEDIO', active: prediction.level == RiskLevel.medium, color: AppColors.riskMedium),
              const SizedBox(width: 12),
              _SemaforoDot2(emoji: '✅', label: 'BAJO', active: prediction.level == RiskLevel.low, color: AppColors.riskLow),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              color: _riskColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _riskColor),
            ),
            child: Text(
              '${prediction.level == RiskLevel.high ? '🔴' : prediction.level == RiskLevel.medium ? '🟡' : '🟢'} Riesgo ${prediction.levelLabel}',
              style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w700, color: _riskColor),
            ),
          ),
          const SizedBox(height: 12),
          Text(prediction.recommendation,
              style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.gris, height: 1.6),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Confianza del modelo',
                    style: GoogleFonts.dmSans(fontSize: 11, letterSpacing: 0.5, color: AppColors.gris, fontWeight: FontWeight.w600)),
                Text('${(prediction.confidence * 100).toInt()}%',
                    style: GoogleFonts.fraunces(fontSize: 14, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: prediction.confidence,
                  minHeight: 8,
                  backgroundColor: AppColors.niebla,
                  valueColor: AlwaysStoppedAnimation<Color>(_riskColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SemaforoDot2 extends StatelessWidget {
  final String emoji, label;
  final bool active;
  final Color color;
  const _SemaforoDot2({required this.emoji, required this.label, required this.active, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: 56, height: 56,
      decoration: BoxDecoration(
        color: active ? color.withValues(alpha: 0.18) : AppColors.niebla,
        shape: BoxShape.circle,
        boxShadow: active ? [BoxShadow(color: color.withValues(alpha: 0.45), blurRadius: 18, spreadRadius: 2)] : null,
      ),
      child: Center(child: Text(emoji, style: TextStyle(fontSize: 24, color: active ? color : Colors.grey.shade400))),
    );
  }
}

class _SprayCard extends StatelessWidget {
  final SprayDecision spray;
  const _SprayCard({required this.spray});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.niebla),
        boxShadow: const [BoxShadow(color: Color(0x0C1A3D2B), blurRadius: 16, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Text('💊 ¿Es buen día para fumigar?',
              style: GoogleFonts.fraunces(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.verdeOscuro)),
          const SizedBox(height: 14),
          Text(spray.isGood ? '✅' : '❌', style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 6),
          Text(
            spray.isGood ? 'SÍ — Condiciones ideales' : 'NO — Espera otro día',
            style: GoogleFonts.fraunces(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.verdeOscuro),
          ),
          const SizedBox(height: 10),
          Text(spray.isGood
              ? 'Viento bajo y sin lluvia pronosticada. El agroquímico no se desperdiciaría.'
              : spray.windOk ? 'Alta probabilidad de lluvia. El producto se lavaría.' : 'Viento muy fuerte. El producto no llegaría bien.',
              style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.gris, height: 1.6),
              textAlign: TextAlign.center),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _IndBox(label: '💨 Viento', ok: spray.windOk)),
              const SizedBox(width: 10),
              Expanded(child: _IndBox(label: '🌧️ Lluvia', ok: spray.rainOk)),
            ],
          ),
        ],
      ),
    );
  }
}

class _IndBox extends StatelessWidget {
  final String label;
  final bool ok;
  const _IndBox({required this.label, required this.ok});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: AppColors.niebla, borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Text(label, style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.gris, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(ok ? '✅ OK' : '❌',
              style: GoogleFonts.fraunces(fontSize: 15, fontWeight: FontWeight.w700,
                  color: ok ? AppColors.riskLow : AppColors.riskHigh)),
        ],
      ),
    );
  }
}

class _DecisionTreeCard extends StatelessWidget {
  final FrostPrediction prediction;
  const _DecisionTreeCard({required this.prediction});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text('🌳 Árbol de decisión (simplificado)',
              style: GoogleFonts.fraunces(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.verdeOscuro)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1F14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Altitud > 2800m → SÍ\n└─ Temp.min < 4°C → SÍ\n   └─ Humedad > 80% → ALTO ❄️\n   └─ Humedad ≤ 80% → MEDIO ⚠️\n└─ Temp.min ≥ 4°C → BAJO ✅',
              style: GoogleFonts.dmSans(
                  fontSize: 12.5, color: const Color(0xFFC9E8D0), height: 1.9),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              border: const Border(left: BorderSide(color: AppColors.azul, width: 4)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Text('💡 ', style: TextStyle(fontSize: 18)),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: GoogleFonts.dmSans(fontSize: 12, height: 1.6),
                      children: const [
                        TextSpan(text: 'Modelo entrenado con '),
                        TextSpan(text: '2 años de datos del IDEAM ', style: TextStyle(fontWeight: FontWeight.w700)),
                        TextSpan(text: 'para altitudes entre 1.800–3.500 m.s.n.m. en Nariño. Precisión: '),
                        TextSpan(text: '87%', style: TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (prediction.factors.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Factores detectados:',
                style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            ...prediction.factors.map((f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(children: [
                const Text('• ', style: TextStyle(color: AppColors.verde)),
                Expanded(child: Text(f, style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.gris))),
              ]),
            )),
          ],
        ],
      ),
    );
  }
}
