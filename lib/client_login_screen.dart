import 'package:archi_manager/Service/portal_service.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/colors.dart';
import '../service/portal_service.dart' hide PortalService;
import 'client_portal_screen.dart';

class ClientLoginScreen extends StatefulWidget {
  const ClientLoginScreen({super.key});

  @override
  State<ClientLoginScreen> createState() => _ClientLoginScreenState();
}

class _ClientLoginScreenState extends State<ClientLoginScreen> {
  final _formKey       = GlobalKey<FormState>();
  final _emailCtrl     = TextEditingController();
  final _passwordCtrl  = TextEditingController();

  bool _loading       = false;
  bool _showPassword  = false;
  String? _errorMsg;

  // ── Validation email ───────────────────────────────────────────
  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'L\'email est obligatoire';
    final regex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-z]{2,}$', caseSensitive: false);
    if (!regex.hasMatch(v.trim())) return 'Format email invalide';
    return null;
  }

  // ── Validation mot de passe ───────────────────────────────────
  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Le mot de passe est obligatoire';
    if (v.length < 6) return 'Minimum 6 caractères';
    return null;
  }

  Future<void> _login() async {
    setState(() => _errorMsg = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await PortalService.login(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ClientPortalScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _loading  = false;
        _errorMsg = 'Email ou mot de passe incorrect';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 24 : 0,
            vertical: 32,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // ── Logo / Brand ──────────────────────────────────
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: kAccent,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: kAccent.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(LucideIcons.building2,
                      color: Colors.white, size: 28),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Portail Client',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Suivez l\'avancement de vos projets',
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                ),

                const SizedBox(height: 32),

                // ── Card formulaire ───────────────────────────────
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // Email
                        _FieldLabel(label: 'Adresse email'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                          style: const TextStyle(
                              fontSize: 14, color: Color(0xFF111827)),
                          decoration: _inputDecoration(
                            hint: 'votre@email.com',
                            icon: LucideIcons.mail,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Mot de passe
                        _FieldLabel(label: 'Mot de passe'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: !_showPassword,
                          validator: _validatePassword,
                          style: const TextStyle(
                              fontSize: 14, color: Color(0xFF111827)),
                          decoration: _inputDecoration(
                            hint: '••••••••',
                            icon: LucideIcons.lock,
                          ).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPassword
                                    ? LucideIcons.eyeOff
                                    : LucideIcons.eye,
                                size: 16,
                                color: const Color(0xFF9CA3AF),
                              ),
                              onPressed: () => setState(
                                  () => _showPassword = !_showPassword),
                            ),
                          ),
                        ),

                        // Erreur connexion
                        if (_errorMsg != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: kRed.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: kRed.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Icon(LucideIcons.alertCircle,
                                    size: 14, color: kRed),
                                const SizedBox(width: 8),
                                Text(_errorMsg!,
                                    style: TextStyle(
                                        color: kRed, fontSize: 13)),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Bouton connexion
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kAccent,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12)),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white),
                                  )
                                : const Text(
                                    'Se connecter',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Note accès
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: kAccent.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kAccent.withOpacity(0.15)),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.info,
                          size: 14, color: kAccent),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Vos identifiants vous ont été transmis par votre architecte.',
                          style: TextStyle(
                              color: Color(0xFF374151), fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
      {required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFD1D5DB)),
      prefixIcon: Icon(icon, size: 15, color: const Color(0xFF9CA3AF)),
      isDense: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: kAccent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: kRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: kRed, width: 2),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF374151),
          letterSpacing: 0.2,
        ),
      );
}