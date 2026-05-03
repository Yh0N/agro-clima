import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class HistorialPage extends StatefulWidget {
  const HistorialPage({super.key});

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> with SingleTickerProviderStateMixin {
  late TabController _tabs;

  // Datos simulados (en producción vendrían de SQLite/API)
  final _tempData = [7.2, 6.8, 5.9, 6.1, 4.3, 5.6, 7.1, 6.4, 5.2, 4.1,
    3.8, 5.0, 6.3, 7.0, 6.6, 5.4, 4.9, 6.1, 7.3, 6.8,
    5.7, 4.5, 3.9, 5.2, 6.4, 7.1, 5.8, 6.0];
  final _mensual = [7.2, 7.8, 8.1, 8.5, 8.3, 7.1, 6.9, 7.0, 7.8, 8.2, 7.9, 7.1];
  final _lluvia = [85, 92, 110, 145, 130, 60, 55, 58, 105, 135, 120, 80];

  static const _heladas = [
    ('2024-12-08', '-1.2°C', '> 2.800m', 'Papa, Mora', 'alto'),
    ('2024-08-14', '1.4°C', '> 2.600m', 'Papa', 'medio'),
    ('2024-07-22', '0.8°C', '> 2.700m', 'Papa, Arveja', 'medio'),
    ('2024-02-03', '-0.5°C', '> 2.900m', 'Papa', 'alto'),
    ('2023-12-15', '-2.1°C', '> 2.500m', 'Papa, Mora, Hortalizas', 'alto'),
    ('2023-08-05', '1.9°C', '> 2.800m', 'Papa', 'bajo'),
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.crema,
      body: Column(
        children: [
          Container(
            color: AppColors.blanco,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(children: [
                    Text('📊 Historial Climático',
                        style: GoogleFonts.fraunces(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.verdeOscuro)),
                    const Spacer(),
                    Text('Datos históricos de Nariño',
                        style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.gris)),
                  ]),
                ),
                TabBar(
                  controller: _tabs,
                  labelStyle: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w400),
                  labelColor: AppColors.verde,
                  unselectedLabelColor: AppColors.gris,
                  indicatorColor: AppColors.verde,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: const [
                    Tab(text: 'Temperatura'),
                    Tab(text: 'Heladas'),
                    Tab(text: 'Lluvia mensual'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _TempTab(tempData: _tempData, mensual: _mensual),
                _HeladasTab(heladas: _heladas),
                _LluviaTab(lluvia: _lluvia),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TempTab extends StatelessWidget {
  final List<double> tempData;
  final List<double> mensual;
  const _TempTab({required this.tempData, required this.mensual});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _HistCard(
            title: 'Temperatura mínima — Últimas 4 semanas',
            child: _Sparkline(data: tempData, colorize: true, unit: '°C'),
            footer: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Hace 28 días', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.gris)),
              Text('Hoy', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.gris)),
            ]),
            alert: 'Las temperaturas mínimas han bajado un promedio de 1.8°C respecto al mes anterior. '
                'Riesgo de helada aumentado en la zona alta.',
            alertType: _AlertType.medio,
          ),
          const SizedBox(height: 16),
          _HistCard(
            title: 'Temperatura promedio por mes — 2024',
            child: _Sparkline(data: mensual, colorize: false, unit: '°C'),
            footer: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Enero', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.gris)),
              Text('Diciembre', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.gris)),
            ]),
            alert: 'Fuente: IDEAM + ERA5 Copernicus. Datos calibrados para altitud de 2.500 m.s.n.m. en la zona andina de Nariño.',
            alertType: _AlertType.info,
          ),
        ],
      ),
    );
  }
}

class _HeladasTab extends StatelessWidget {
  final List<(String, String, String, String, String)> heladas;
  const _HeladasTab({required this.heladas});

  Color _riskColor(String level) {
    switch (level) {
      case 'alto': return AppColors.riskHigh;
      case 'medio': return AppColors.riskMedium;
      default: return AppColors.riskLow;
    }
  }
  Color _riskBg(String level) {
    switch (level) {
      case 'alto': return const Color(0xFFFCE8E0);
      case 'medio': return const Color(0xFFFEF3C7);
      default: return AppColors.niebla;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.blanco,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.niebla),
          boxShadow: const [BoxShadow(color: Color(0x0C1A3D2B), blurRadius: 16, offset: Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Registro de eventos de helada — Últimas 52 semanas',
                  style: GoogleFonts.fraunces(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.verdeOscuro)),
            ),
            const Divider(height: 1, color: AppColors.niebla),
            // Header
            Container(
              color: AppColors.niebla,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(flex: 3, child: Text('Fecha', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: AppColors.verdeOscuro))),
                  Expanded(flex: 2, child: Text('Temp. mín', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: AppColors.verdeOscuro))),
                  Expanded(flex: 3, child: Text('Altitud', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: AppColors.verdeOscuro))),
                  Expanded(flex: 4, child: Text('Cultivos', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: AppColors.verdeOscuro))),
                  Expanded(flex: 2, child: Text('Nivel', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: AppColors.verdeOscuro))),
                ],
              ),
            ),
            ...heladas.map((h) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.niebla))),
              child: Row(
                children: [
                  Expanded(flex: 3, child: Text(h.$1, style: GoogleFonts.dmSans(fontSize: 13))),
                  Expanded(flex: 2, child: Text(h.$2, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600))),
                  Expanded(flex: 3, child: Text(h.$3, style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.gris))),
                  Expanded(flex: 4, child: Text(h.$4, style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.gris))),
                  Expanded(flex: 2, child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: _riskBg(h.$5), borderRadius: BorderRadius.circular(20)),
                    child: Text(h.$5.toUpperCase(),
                        style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w700, color: _riskColor(h.$5))),
                  )),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _LluviaTab extends StatelessWidget {
  final List<int> lluvia;
  const _LluviaTab({required this.lluvia});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: _HistCard(
        title: 'Precipitación mensual 2024 (mm)',
        child: _LluviaChart(data: lluvia),
        footer: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Enero', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.gris)),
            Text('Diciembre', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.gris)),
          ],
        ),
        alert: 'Nariño tiene régimen bimodal. Los meses más lluviosos son marzo–mayo y septiembre–noviembre. '
            'Planea tus fumigaciones para junio–agosto y diciembre–febrero.',
        alertType: _AlertType.bajo,
      ),
    );
  }
}

// ── SPARK CHART ──────────────────────────────────────────────────────────────
class _Sparkline extends StatelessWidget {
  final List<double> data;
  final bool colorize;
  final String unit;
  const _Sparkline({required this.data, required this.colorize, required this.unit});

  @override
  Widget build(BuildContext context) {
    final max = data.reduce((a, b) => a > b ? a : b);
    final min = data.reduce((a, b) => a < b ? a : b);
    return SizedBox(
      height: 70,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((v) {
          final pct = (max - min) == 0 ? 1.0 : (v - min) / (max - min);
          Color color = AppColors.verdeClaro;
          if (colorize) {
            if (v < 2) color = const Color(0xFF60A5FA);
            else if (v < 5) color = const Color(0xFF94C5F8);
          }
          return Expanded(
            child: Tooltip(
              message: '${v.toStringAsFixed(1)}$unit',
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                height: (pct * 55 + 10).clamp(6.0, 65.0),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(3), topRight: Radius.circular(3)),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _LluviaChart extends StatelessWidget {
  final List<int> data;
  const _LluviaChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final max = data.reduce((a, b) => a > b ? a : b);
    return SizedBox(
      height: 90,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((v) {
          final pct = v / max;
          return Expanded(
            child: Tooltip(
              message: '${v}mm',
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                height: (pct * 75 + 8).clamp(6.0, 83.0),
                decoration: BoxDecoration(
                  color: AppColors.azul.withValues(alpha: 0.7),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(3), topRight: Radius.circular(3)),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── REUSABLE HIST CARD ────────────────────────────────────────────────────────
enum _AlertType { alto, medio, bajo, info }

class _HistCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget footer;
  final String alert;
  final _AlertType alertType;

  const _HistCard({required this.title, required this.child, required this.footer,
      required this.alert, required this.alertType});

  @override
  Widget build(BuildContext context) {
    Color bg, border;
    String emoji;
    switch (alertType) {
      case _AlertType.alto: bg = const Color(0xFFFCE8E0); border = AppColors.riskHigh; emoji = '🚨'; break;
      case _AlertType.medio: bg = const Color(0xFFFEF3C7); border = AppColors.acento; emoji = '📉'; break;
      case _AlertType.bajo: bg = AppColors.niebla; border = AppColors.verdeClaro; emoji = '🌧️'; break;
      case _AlertType.info: bg = const Color(0xFFDBEAFE); border = AppColors.azul; emoji = '📊'; break;
    }
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
          Text(title, style: GoogleFonts.fraunces(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.verdeOscuro)),
          const SizedBox(height: 16),
          child,
          const SizedBox(height: 6),
          footer,
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bg,
              border: Border(left: BorderSide(color: border, width: 4)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(child: Text(alert, style: GoogleFonts.dmSans(fontSize: 13, height: 1.5))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
