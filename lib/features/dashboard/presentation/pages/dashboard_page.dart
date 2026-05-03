import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../pronostico/presentation/bloc/weather_bloc.dart';
import '../../../pronostico/presentation/bloc/weather_event_state.dart';
import '../../../pronostico/domain/entities/weather_forecast.dart';
import '../../../finca/presentation/bloc/finca_bloc.dart';
import '../../../finca/presentation/bloc/finca_event_state.dart';
import '../../../prediccion/domain/entities/frost_prediction.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.crema,
      body: RefreshIndicator(
        color: AppColors.verde,
        onRefresh: () async {
          final fb = context.read<FincaBloc>();
          final municipio = fb.state is FincaLoaded
              ? (fb.state as FincaLoaded).finca.municipio
              : 'Pasto';
          context.read<WeatherBloc>().add(FetchForecastEvent(municipio));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Top bar con fecha y estado
              _TopBar(),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  children: [
                    // HERO BANNER
                    _HeroBanner(),
                    const SizedBox(height: 20),
                    // ALERTAS
                    _AlertasSection(),
                    const SizedBox(height: 20),
                    // KPI GRID
                    _KpiGrid(),
                    const SizedBox(height: 20),
                    // SEMÁFORO + PRONÓSTICO
                    _BottomGrid(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── TOP BAR ──────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dias = ['dom', 'lun', 'mar', 'mié', 'jue', 'vie', 'sáb'];
    final meses = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    final dateStr = '${dias[now.weekday % 7]} ${now.day} ${meses[now.month - 1]} ${now.year}';

    return Container(
      color: AppColors.blanco,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Text('Panel principal',
              style: GoogleFonts.fraunces(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.verdeOscuro)),
          const Spacer(),
          Text(dateStr,
              style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.gris)),
          const SizedBox(width: 16),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: AppColors.verdeClaro, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text('API activa',
                  style: GoogleFonts.dmSans(
                      fontSize: 12, color: AppColors.verdeMedio)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── HERO BANNER ──────────────────────────────────────────────────────────────
class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FincaBloc, FincaState>(
      builder: (context, state) {
        final nombre = state is FincaLoaded ? state.finca.nombreAgricultero : 'Agricultor';
        final municipio = state is FincaLoaded ? state.finca.municipio : 'Nariño';
        final altitud = state is FincaLoaded ? '${state.finca.altitud} m.s.n.m.' : 'Configura tu finca';

        return BlocBuilder<WeatherBloc, WeatherState>(
          builder: (context, wState) {
            final tempStr = wState is WeatherLoaded && wState.forecast.days.isNotEmpty
                ? '${wState.forecast.days.first.tempMax.toInt()}°C ahora'
                : '—°C ahora';

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.verdeOscuro, AppColors.verde],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  // Emoji decorativo
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text('🌿',
                          style: const TextStyle(fontSize: 72, height: 1)
                              .copyWith(color: Colors.white.withValues(alpha: 0.15))),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Buenos días, $nombre 👋',
                          style: GoogleFonts.fraunces(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.1)),
                      const SizedBox(height: 8),
                      Text(
                        'Resumen del clima para tu finca en $municipio. Revisa las alertas antes de salir al campo.',
                        style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                            height: 1.6),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 20,
                        runSpacing: 8,
                        children: [
                          _MetaItem('📍', altitud),
                          _MetaItem('🌡️', tempStr),
                          _MetaItem('💧', '72% humedad'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _MetaItem extends StatelessWidget {
  final String emoji;
  final String text;
  const _MetaItem(this.emoji, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 6),
        Text(text,
            style: GoogleFonts.dmSans(
                fontSize: 13, color: Colors.white.withValues(alpha: 0.9))),
      ],
    );
  }
}

// ── ALERTAS ──────────────────────────────────────────────────────────────────
class _AlertasSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherBloc, WeatherState>(
      builder: (context, state) {
        if (state is WeatherLoaded && state.forecast.days.isNotEmpty) {
          final today = state.forecast.days.first;
          if (today.tempMin < 4) {
            return _AlertCard(
              type: _AlertType.alto,
              emoji: '🚨',
              title: '¡Alerta de helada esta noche!',
              body:
                  'Temperatura mínima de ${today.tempMin.toStringAsFixed(1)}°C en ${state.forecast.municipio}. Protege tus cultivos antes de las 6pm.',
            );
          }
        }
        return _AlertCard(
          type: _AlertType.info,
          emoji: 'ℹ️',
          title: 'Configura tu perfil',
          body:
              'Ve a "Mi finca" para personalizar las predicciones según tu altitud y cultivos.',
        );
      },
    );
  }
}

enum _AlertType { alto, medio, bajo, info }

class _AlertCard extends StatelessWidget {
  final _AlertType type;
  final String emoji;
  final String title;
  final String body;

  const _AlertCard(
      {required this.type,
      required this.emoji,
      required this.title,
      required this.body});

  @override
  Widget build(BuildContext context) {
    Color bg, border;
    switch (type) {
      case _AlertType.alto:
        bg = const Color(0xFFFCE8E0);
        border = AppColors.riskHigh;
        break;
      case _AlertType.medio:
        bg = const Color(0xFFFEF3C7);
        border = AppColors.acento;
        break;
      case _AlertType.bajo:
        bg = AppColors.niebla;
        border = AppColors.verdeClaro;
        break;
      case _AlertType.info:
        bg = const Color(0xFFDBEAFE);
        border = AppColors.azul;
        break;
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        border: Border(left: BorderSide(color: border, width: 4)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: AppColors.verdeOscuro,
                    height: 1.6),
                children: [
                  TextSpan(
                      text: '$title — ',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(text: body),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── KPI GRID ─────────────────────────────────────────────────────────────────
class _KpiGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherBloc, WeatherState>(
      builder: (context, state) {
        double temp = 14;
        int lluvia = 28;
        int viento = 12;
        String heladaLabel = 'MEDIO';
        Color heladaColor = AppColors.acento;

        if (state is WeatherLoaded && state.forecast.days.isNotEmpty) {
          final d = state.forecast.days.first;
          temp = d.tempMax;
          lluvia = d.rainProbability.toInt();
          viento = d.windSpeed.toInt();
          if (d.tempMin < 4) {
            heladaLabel = 'ALTO';
            heladaColor = AppColors.riskHigh;
          } else if (d.tempMin < 8) {
            heladaLabel = 'MEDIO';
            heladaColor = AppColors.acento;
          } else {
            heladaLabel = 'BAJO';
            heladaColor = AppColors.riskLow;
          }
        }

        return LayoutBuilder(
          builder: (_, constraints) {
            final crossCount = constraints.maxWidth > 600 ? 4 : 2;
            return GridView.count(
              crossAxisCount: crossCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.95,
              children: [
                _KpiCard(emoji: '🌡️', value: '${temp.toInt()}°C', label: 'Temperatura actual', sub: '↓ 2°C hasta la noche', subColor: AppColors.verdeMedio),
                _KpiCard(emoji: '💧', value: '$lluvia%', label: 'Prob. de lluvia', sub: 'Tarde: ${lluvia + 17}%', subColor: AppColors.azul),
                _KpiCard(emoji: '💨', value: '$viento km/h', label: 'Vel. del viento', sub: viento < 20 ? '✅ Apto para fumigar' : '⚠️ Viento fuerte', subColor: AppColors.verdeMedio),
                _KpiCard(emoji: '⚠️', value: heladaLabel, label: 'Riesgo de helada', sub: 'Noche: vigilar', subColor: heladaColor, valueColor: heladaColor),
              ],
            );
          },
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final String sub;
  final Color subColor;
  final Color? valueColor;

  const _KpiCard({
    required this.emoji,
    required this.value,
    required this.label,
    required this.sub,
    required this.subColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.niebla),
        boxShadow: const [BoxShadow(color: Color(0x0C1A3D2B), blurRadius: 16, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(value,
              style: GoogleFonts.fraunces(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: valueColor ?? AppColors.verdeOscuro)),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.gris)),
          const SizedBox(height: 3),
          Text(sub,
              style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: subColor)),
        ],
      ),
    );
  }
}

// ── SEMÁFORO + PRONÓSTICO ────────────────────────────────────────────────────
class _BottomGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final isWide = constraints.maxWidth > 600;
        final children = [
          _SemaforoCard(),
          const SizedBox(height: 16),
          _ForecastCard(),
        ];
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _SemaforoCard()),
              const SizedBox(width: 16),
              Expanded(child: _ForecastCard()),
            ],
          );
        }
        return Column(children: children);
      },
    );
  }
}

class _SemaforoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherBloc, WeatherState>(
      builder: (context, state) {
        RiskLevel level = RiskLevel.low;
        double heladaPct = 0.25;
        double fumigPct = 0.8;
        String texto = 'Todo bien — Condiciones normales hoy';

        if (state is WeatherLoaded && state.forecast.days.isNotEmpty) {
          final d = state.forecast.days.first;
          if (d.tempMin < 4) {
            level = RiskLevel.high;
            heladaPct = 0.85;
            fumigPct = d.windSpeed < 20 ? 0.65 : 0.3;
            texto = '⚠️ Peligro — Protege tus cultivos esta noche';
          } else if (d.tempMin < 8) {
            level = RiskLevel.medium;
            heladaPct = 0.55;
            fumigPct = 0.7;
            texto = 'Precaución — Revisa temperatura esta noche';
          } else {
            fumigPct = d.windSpeed < 20 ? 0.88 : 0.5;
          }
        }

        return _AgroCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🚦 Semáforo del día',
                  style: GoogleFonts.fraunces(
                      fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.verdeOscuro)),
              Text('Estado general de tu finca',
                  style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.gris)),
              const SizedBox(height: 16),
              // Semáforo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SemaforoDot(emoji: '🔴', active: level == RiskLevel.high, color: AppColors.riskHigh),
                  const SizedBox(width: 12),
                  _SemaforoDot(emoji: '🟡', active: level == RiskLevel.medium, color: AppColors.riskMedium),
                  const SizedBox(width: 12),
                  _SemaforoDot(emoji: '🟢', active: level == RiskLevel.low, color: AppColors.riskLow),
                ],
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(texto,
                    style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.gris),
                    textAlign: TextAlign.center),
              ),
              const SizedBox(height: 16),
              _ProgressRow(label: 'Riesgo helada', value: heladaPct,
                  color: level == RiskLevel.high ? AppColors.riskHigh : AppColors.acento),
              const SizedBox(height: 8),
              _ProgressRow(label: 'Condición fumigación', value: fumigPct, color: AppColors.verdeClaro),
            ],
          ),
        );
      },
    );
  }
}

class _SemaforoDot extends StatelessWidget {
  final String emoji;
  final bool active;
  final Color color;

  const _SemaforoDot({required this.emoji, required this.active, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: active ? color.withValues(alpha: 0.18) : const Color(0xFFF0F4F1),
        shape: BoxShape.circle,
        boxShadow: active
            ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 16, spreadRadius: 2)]
            : null,
      ),
      child: Center(
        child: Text(emoji,
            style: TextStyle(
                fontSize: 22,
                color: active ? color : Colors.grey.shade400)),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _ProgressRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.verdeOscuro)),
            Text('${(value * 100).toInt()}%',
                style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: AppColors.niebla,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

// ── FORECAST CARD ─────────────────────────────────────────────────────────────
class _ForecastCard extends StatefulWidget {
  @override
  State<_ForecastCard> createState() => _ForecastCardState();
}

class _ForecastCardState extends State<_ForecastCard> {
  int? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherBloc, WeatherState>(
      builder: (context, state) {
        final days = state is WeatherLoaded ? state.forecast.days : <WeatherDay>[];

        return _AgroCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📅 Próximos 7 días',
                  style: GoogleFonts.fraunces(
                      fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.verdeOscuro)),
              Text('Toca un día para ver detalles',
                  style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.gris)),
              const SizedBox(height: 12),
              if (state is WeatherLoading)
                const Center(child: CircularProgressIndicator())
              else if (days.isEmpty)
                Text('Sin datos. Desliza para actualizar.',
                    style: GoogleFonts.dmSans(color: AppColors.gris, fontSize: 13))
              else ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(days.length, (i) {
                      final d = days[i];
                      final sel = _selectedDay == i;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedDay = sel ? null : i),
                        child: _ForecastDayChip(day: d, selected: sel, isFirst: i == 0),
                      );
                    }),
                  ),
                ),
                if (_selectedDay != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.niebla,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(days[_selectedDay!].emoji,
                            style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${days[_selectedDay!].dayName} — '
                            '${days[_selectedDay!].tempMin.toInt()}° / ${days[_selectedDay!].tempMax.toInt()}°C · '
                            'Lluvia: ${days[_selectedDay!].rainProbability.toInt()}% · '
                            'Viento: ${days[_selectedDay!].windSpeed.toInt()} km/h'
                            '${days[_selectedDay!].isGoodForSpray ? ' · ✅ Buen día para fumigar' : ''}',
                            style: GoogleFonts.dmSans(
                                fontSize: 12, color: AppColors.verdeOscuro),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ForecastDayChip extends StatelessWidget {
  final WeatherDay day;
  final bool selected;
  final bool isFirst;

  const _ForecastDayChip({required this.day, required this.selected, this.isFirst = false});

  @override
  Widget build(BuildContext context) {
    final isBest = day.isGoodForSpray;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 80,
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.verdeClaro
            : isBest
                ? const Color(0xFFFFF9E6)
                : AppColors.niebla,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected
              ? AppColors.verdeMedio
              : isBest
                  ? AppColors.acento
                  : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(isFirst ? 'Hoy' : day.dayName.substring(0, 3),
              style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: selected ? Colors.white : AppColors.verdeOscuro)),
          const SizedBox(height: 4),
          Text(day.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text('${day.tempMin.toInt()}°/${day.tempMax.toInt()}°',
              style: GoogleFonts.fraunces(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.verdeOscuro)),
          Text('💧${day.rainProbability.toInt()}%',
              style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: selected ? Colors.white70 : AppColors.azul)),
          if (isBest && !selected)
            Text('✅ Fumigar',
                style: GoogleFonts.dmSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.tierra)),
        ],
      ),
    );
  }
}

// ── REUSABLE CARD ─────────────────────────────────────────────────────────────
class _AgroCard extends StatelessWidget {
  final Widget child;
  const _AgroCard({required this.child});

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
      child: child,
    );
  }
}
