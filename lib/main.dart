import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_it/get_it.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

import 'injection_container.dart' as di;
import 'core/constants/app_colors.dart';

import 'features/prediccion/presentation/bloc/prediction_bloc.dart';
import 'features/pronostico/presentation/bloc/weather_bloc.dart';
import 'features/pronostico/presentation/bloc/weather_event_state.dart';
import 'features/finca/presentation/bloc/finca_bloc.dart';
import 'features/finca/presentation/bloc/finca_event_state.dart';

// Pages
import 'features/splash/presentation/pages/splash_page.dart';
import 'features/registro/presentation/pages/registro_finca_page.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/prediccion/presentation/pages/prediction_page.dart';
import 'features/pronostico/presentation/pages/forecast_page.dart';
import 'features/finca/presentation/pages/finca_page.dart';
import 'features/cultivos/presentation/pages/cultivos_page.dart';
import 'features/historial/presentation/pages/historial_page.dart';
import 'features/calendario/presentation/pages/calendario_page.dart';
import 'features/ajustes/presentation/pages/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await di.init();
  runApp(const AgroClimaApp());
}

class AgroClimaApp extends StatelessWidget {
  const AgroClimaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.dmSansTextTheme();
    final theme = ThemeData(
      colorScheme: AppColors.colorScheme,
      useMaterial3: true,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.crema,
      cardTheme: CardTheme(
        color: AppColors.blanco,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.niebla, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.blanco,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.fraunces(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.verdeOscuro,
        ),
        iconTheme: const IconThemeData(color: AppColors.verdeOscuro),
        toolbarHeight: 60,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.verde,
          foregroundColor: AppColors.blanco,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle:
              GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.verde,
          foregroundColor: AppColors.blanco,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle:
              GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.blanco,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFDDE8E0), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFDDE8E0), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: AppColors.verdeClaro, width: 1.5),
        ),
        labelStyle: GoogleFonts.dmSans(
            fontSize: 13, fontWeight: FontWeight.w600),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.verdeClaro,
        inactiveTrackColor: const Color(0xFFDDE8E0),
        thumbColor: AppColors.verde,
        overlayColor: AppColors.verde.withValues(alpha: 0.15),
        trackHeight: 6,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.blanco,
        selectedColor: AppColors.verde,
        labelStyle: GoogleFonts.dmSans(
            fontSize: 13, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
          side: const BorderSide(color: AppColors.niebla),
        ),
        checkmarkColor: AppColors.blanco,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.niebla,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: AppColors.verdeOscuro,
        contentTextStyle: GoogleFonts.dmSans(color: AppColors.crema),
      ),
    );

    // BLoCs globales — disponibles en toda la app
    return MultiBlocProvider(
      providers: [
        BlocProvider<FincaBloc>(
          create: (_) => GetIt.I<FincaBloc>(),
        ),
        BlocProvider<PredictionBloc>(
          create: (_) => GetIt.I<PredictionBloc>(),
        ),
        BlocProvider<WeatherBloc>(
          create: (_) => GetIt.I<WeatherBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'AgroClima Nariño',
        debugShowCheckedModeBanner: false,
        theme: theme,
        // ── Rutas nombradas ─────────────────────────────────────────────────
        initialRoute: '/splash',
        routes: {
          '/splash': (_) => const SplashPage(),
          '/registro': (_) => const RegistroFincaPage(),
          '/home': (_) => const AppShell(),
        },
      ),
    );
  }
}

// ── AppShell ──────────────────────────────────────────────────────────────────

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static const _navItems = [
    _NavItem(
        icon: Icons.home_rounded,
        label: 'Panel principal',
        section: 'Principal'),
    _NavItem(
        icon: Icons.wb_sunny_rounded,
        label: 'Pronóstico',
        section: 'Principal'),
    _NavItem(
        icon: Icons.psychology_rounded,
        label: 'Predicción IA',
        section: 'Principal',
        badge: 'IA'),
    _NavItem(
        icon: Icons.cottage_rounded,
        label: 'Mi finca',
        section: 'Mi Finca'),
    _NavItem(
        icon: Icons.spa_rounded,
        label: 'Mis cultivos',
        section: 'Mi Finca'),
    _NavItem(
        icon: Icons.bar_chart_rounded,
        label: 'Historial',
        section: 'Mi Finca'),
    _NavItem(
        icon: Icons.calendar_month_rounded,
        label: 'Calendario',
        section: 'Herramientas'),
    _NavItem(
        icon: Icons.settings_rounded,
        label: 'Ajustes',
        section: 'Herramientas'),
  ];

  static const _pages = [
    DashboardPage(),
    ForecastPage(),
    PredictionPage(),
    FincaPage(),
    CultivosPage(),
    HistorialPage(),
    CalendarioPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    // Al entrar al shell, cargamos la finca y el pronóstico inicial.
    final fincaBloc = context.read<FincaBloc>();
    final state = fincaBloc.state;
    // Si venimos del splash ya tiene datos; si no, disparamos carga.
    if (state is! FincaLoaded && state is! FincaSaved) {
      fincaBloc.add(LoadFincaEvent());
    }

    // Pronóstico inicial con el municipio de la finca o 'Pasto' por defecto.
    final municipio = state is FincaLoaded ? state.finca.municipio : 'Pasto';
    context.read<WeatherBloc>().add(FetchForecastEvent(municipio));
  }

  @override
  Widget build(BuildContext context) {
    // Cuando la finca carga, refresca el pronóstico con su municipio
    return BlocListener<FincaBloc, FincaState>(
      listener: (context, state) {
        if (state is FincaLoaded || state is FincaSaved) {
          final f = state is FincaLoaded
              ? state.finca
              : (state as FincaSaved).finca;
          context
              .read<WeatherBloc>()
              .add(FetchForecastEvent(f.municipio));
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          if (isWide) {
            return Scaffold(
              body: Row(
                children: [
                  _Sidebar(
                    selectedIndex: _selectedIndex,
                    items: _navItems,
                    onTap: (i) => setState(() => _selectedIndex = i),
                  ),
                  Expanded(child: _pages[_selectedIndex]),
                ],
              ),
            );
          }
          // Móvil: drawer lateral
          return Scaffold(
            appBar: AppBar(
              title: Text(_navItems[_selectedIndex].label),
              leading: Builder(
                builder: (ctx) => IconButton(
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                  icon: const Icon(Icons.menu_rounded),
                ),
              ),
            ),
            drawer: Drawer(
              backgroundColor: AppColors.verdeOscuro,
              child: _SidebarContent(
                selectedIndex: _selectedIndex,
                items: _navItems,
                onTap: (i) {
                  setState(() => _selectedIndex = i);
                  Navigator.pop(context);
                },
              ),
            ),
            body: _pages[_selectedIndex],
          );
        },
      ),
    );
  }
}

// ── Nav item model ────────────────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final String label;
  final String section;
  final String? badge;
  const _NavItem(
      {required this.icon,
      required this.label,
      required this.section,
      this.badge});
}

// ── Sidebar (tablet/escritorio) ───────────────────────────────────────────────

class _Sidebar extends StatelessWidget {
  final int selectedIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  const _Sidebar(
      {required this.selectedIndex,
      required this.items,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: AppColors.verdeOscuro,
        boxShadow: [
          BoxShadow(
              color: Color(0x22000000),
              blurRadius: 16,
              offset: Offset(4, 0))
        ],
      ),
      child: _SidebarContent(
          selectedIndex: selectedIndex, items: items, onTap: onTap),
    );
  }
}

class _SidebarContent extends StatelessWidget {
  final int selectedIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  const _SidebarContent(
      {required this.selectedIndex,
      required this.items,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final sections = <String>[];
    for (final item in items) {
      if (!sections.contains(item.section)) sections.add(item.section);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo
        Container(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
          decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.08))),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🌿 AgroClima\nNariño',
                  style: GoogleFonts.fraunces(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.menta,
                      height: 1.1)),
              const SizedBox(height: 4),
              Text('IA para el campo andino',
                  style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.4),
                      letterSpacing: 0.8)),
            ],
          ),
        ),

        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              for (final section in sections) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Text(section.toUpperCase(),
                      style: GoogleFonts.dmSans(
                          fontSize: 10,
                          letterSpacing: 2,
                          color: Colors.white.withValues(alpha: 0.3),
                          fontWeight: FontWeight.w500)),
                ),
                for (int i = 0; i < items.length; i++)
                  if (items[i].section == section)
                    _SidebarBtn(
                      item: items[i],
                      selected: selectedIndex == i,
                      onTap: () => onTap(i),
                    ),
              ],
            ],
          ),
        ),

        // Chip de finca actual
        BlocBuilder<FincaBloc, FincaState>(
          builder: (context, state) {
            final nombre = state is FincaLoaded
                ? state.finca.nombreAgricultero
                : 'Tu finca';
            final altitud = state is FincaLoaded
                ? '${state.finca.altitud} m.s.n.m.'
                : '— m.s.n.m.';
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.08))),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.verdeClaro,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                          child: Text('👨‍🌾',
                              style: TextStyle(fontSize: 14))),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(nombre,
                              style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.crema),
                              overflow: TextOverflow.ellipsis),
                          Text(altitud,
                              style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  color: Colors.white
                                      .withValues(alpha: 0.4))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SidebarBtn extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarBtn(
      {required this.item,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.verdeClaro.withValues(alpha: 0.15)
              : Colors.transparent,
          border: Border(
            left: BorderSide(
              color:
                  selected ? AppColors.verdeClaro : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(item.icon,
                size: 18,
                color: selected
                    ? AppColors.menta
                    : Colors.white.withValues(alpha: 0.65)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(item.label,
                  style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: selected
                          ? AppColors.menta
                          : Colors.white.withValues(alpha: 0.65),
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.w400)),
            ),
            if (item.badge != null)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.riskHigh,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(item.badge!,
                    style: GoogleFonts.dmSans(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w700)),
              ),
          ],
        ),
      ),
    );
  }
}
