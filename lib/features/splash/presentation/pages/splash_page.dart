import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../finca/presentation/bloc/finca_bloc.dart';
import '../../../finca/presentation/bloc/finca_event_state.dart';

/// SplashPage — punto de entrada.
///
/// Flujo:
///   1. Muestra animación de carga mientras el FincaBloc verifica SQLite.
///   2. Si hay finca guardada  → AppShell (dashboard completo).
///   3. Si NO hay finca         → RegistroFincaPage (primera vez).
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );

    // Dispara la carga de la finca desde SQLite
    context.read<FincaBloc>().add(LoadFincaEvent());
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FincaBloc, FincaState>(
      listener: (context, state) {
        if (state is FincaLoaded || state is FincaError) {
          // La finca es opcional, siempre vamos al shell principal
          _goToShell(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.verdeOscuro,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo animado
                ScaleTransition(
                  scale: _scale,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.verde,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              AppColors.verdeClaro.withValues(alpha: 0.40),
                          blurRadius: 40,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🌿',
                          style: TextStyle(fontSize: 56, height: 1)),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                Text(
                  'AgroClima Nariño',
                  style: GoogleFonts.fraunces(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppColors.menta,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'IA para el campo andino',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    color: Colors.white.withValues(alpha: 0.55),
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 56),

                const CircularProgressIndicator(
                  color: AppColors.verdeClaro,
                  strokeWidth: 2.5,
                ),

                const SizedBox(height: 20),

                Text(
                  'Cargando tu información…',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goToShell(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _goToRegistro(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/registro');
  }
}
