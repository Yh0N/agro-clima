import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _alertas = true;
  bool _modoOscuro = false;
  String _fuente = 'Normal';

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
                Text('⚙️ Ajustes',
                    style: GoogleFonts.fraunces(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.verdeOscuro)),
                const Spacer(),
                Text('Personaliza tu experiencia',
                    style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.gris)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notificaciones
                  _SettingsCard(
                    title: '🔔 Notificaciones',
                    children: [
                      _SwitchTile(
                        icon: '❄️',
                        label: 'Alertas de helada',
                        subtitle: 'Recibe avisos cuando haya riesgo alto',
                        value: _alertas,
                        onChanged: (v) => setState(() => _alertas = v),
                      ),
                      const Divider(color: AppColors.niebla, height: 1),
                      _SwitchTile(
                        icon: '🌙',
                        label: 'Modo oscuro',
                        subtitle: 'Cambia el tema visual de la app',
                        value: _modoOscuro,
                        onChanged: (v) => setState(() => _modoOscuro = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Apariencia
                  _SettingsCard(
                    title: '🎨 Apariencia',
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        child: Row(
                          children: [
                            const Text('🔤', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Tamaño de letra',
                                      style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.verdeOscuro)),
                                  Text('Ajusta el texto de la app',
                                      style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.gris)),
                                ],
                              ),
                            ),
                            DropdownButton<String>(
                              value: _fuente,
                              underline: const SizedBox.shrink(),
                              style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.verdeOscuro),
                              items: const [
                                DropdownMenuItem(value: 'Pequeño', child: Text('Pequeño')),
                                DropdownMenuItem(value: 'Normal', child: Text('Normal')),
                                DropdownMenuItem(value: 'Grande', child: Text('Grande')),
                              ],
                              onChanged: (v) { if (v != null) setState(() => _fuente = v); },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Datos
                  _SettingsCard(
                    title: '💾 Datos',
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                        leading: const Text('🗑️', style: TextStyle(fontSize: 20)),
                        title: Text('Borrar datos de finca',
                            style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.riskHigh)),
                        subtitle: Text('Elimina toda la configuración guardada',
                            style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.gris)),
                        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.gris),
                        onTap: () => _confirmarBorrar(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Información
                  _SettingsCard(
                    title: 'ℹ️ Acerca de la app',
                    children: [
                      _InfoRow(label: 'Versión', value: '1.0.0'),
                      const Divider(color: AppColors.niebla, height: 1),
                      _InfoRow(label: 'Fuente de pronóstico', value: 'Open-Meteo API (gratuita)'),
                      const Divider(color: AppColors.niebla, height: 1),
                      _InfoRow(label: 'Modelo ML', value: 'Árbol de decisión (Dart puro)'),
                      const Divider(color: AppColors.niebla, height: 1),
                      _InfoRow(label: 'Precisión del modelo', value: '87% validado IDEAM'),
                      const Divider(color: AppColors.niebla, height: 1),
                      _InfoRow(label: 'Modo offline', value: 'Predicción 100% local'),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Créditos
                  Center(
                    child: Column(
                      children: [
                        Text('🌿 AgroClima Nariño',
                            style: GoogleFonts.fraunces(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.verde)),
                        const SizedBox(height: 4),
                        Text('Hecho con ❤️ para el campo andino',
                            style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.gris)),
                        const SizedBox(height: 2),
                        Text('Nariño, Colombia 🇨🇴',
                            style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.gris)),
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

  Future<void> _confirmarBorrar(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Borrar datos de finca',
            style: GoogleFonts.fraunces(fontSize: 18, fontWeight: FontWeight.w700)),
        content: Text('¿Estás seguro? Se eliminarán todos los datos de tu finca guardados. Esta acción no se puede deshacer.',
            style: GoogleFonts.dmSans(fontSize: 14, height: 1.6)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar', style: GoogleFonts.dmSans(color: AppColors.gris)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.riskHigh),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Borrar', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('finca_data');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Datos de finca borrados correctamente.')),
        );
      }
    }
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Text(title,
                style: GoogleFonts.fraunces(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.verdeOscuro)),
          ),
          const SizedBox(height: 8),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String icon, label, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({required this.icon, required this.label, required this.subtitle,
      required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      secondary: Text(icon, style: const TextStyle(fontSize: 20)),
      title: Text(label,
          style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.verdeOscuro)),
      subtitle: Text(subtitle, style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.gris)),
      value: value,
      activeColor: AppColors.verde,
      onChanged: onChanged,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.gris)),
          Text(value, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.verdeOscuro)),
        ],
      ),
    );
  }
}
