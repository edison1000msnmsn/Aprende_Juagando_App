import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_state.dart';
import 'models.dart';

// ════════════════════════════════════════════════════════════════════════════════
//  ENTRY POINT
// ════════════════════════════════════════════════════════════════════════════════

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Bloquear modo horizontal – tablets y móviles en modo retrato para niños
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const ProviderScope(child: AprendeJugandoApp()));
}

// ════════════════════════════════════════════════════════════════════════════════
//  PALETA DE COLORES
// ════════════════════════════════════════════════════════════════════════════════

class _C {
  _C._();
  static const primary = Color(0xFF6941C6); // morado marca
  static const primaryLt = Color(0xFF9B6BE8); // morado claro
  static const primaryXlt = Color(0xFFEDE9FF); // morado muy claro
  static const orange = Color(0xFFFF7043); // naranja cálido
  static const yellow = Color(0xFFFFB300); // estrella amarilla
  static const yellowLt = Color(0xFFFFF8D9); // fondo estrella
  static const green = Color(0xFF22C55E); // éxito verde
  static const greenLt = Color(0xFFDCFCE7); // fondo verde
  static const redLt = Color(0xFFFFEBEE); // fondo rojo
  static const bg = Color(0xFFF5F0FF); // fondo general lavanda
  static const dark = Color(0xFF1C1033); // texto oscuro
  static const muted = Color(0xFF7C6F91); // texto apagado
}

// ════════════════════════════════════════════════════════════════════════════════
//  TEMA GLOBAL
// ════════════════════════════════════════════════════════════════════════════════

final _theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: _C.primary,
    brightness: Brightness.light,
  ).copyWith(primary: _C.primary),
  scaffoldBackgroundColor: _C.bg,
  fontFamily: 'sans-serif',
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w900,
      letterSpacing: -1,
      color: _C.dark,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w900,
      letterSpacing: -.5,
      color: _C.dark,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w900,
      color: _C.dark,
    ),
    bodyLarge: TextStyle(fontSize: 17, height: 1.5, color: _C.dark),
    bodyMedium: TextStyle(fontSize: 15, height: 1.4, color: _C.muted),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: const BorderSide(color: _C.primary, width: 2.5),
    ),
    labelStyle: const TextStyle(color: _C.muted),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size.fromHeight(64),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: _C.primary,
      foregroundColor: Colors.white,
      elevation: 5,
      shadowColor: _C.primary.withValues(alpha: .4),
      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
    ),
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
    color: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    titleTextStyle: TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.w900,
      color: _C.dark,
    ),
    iconTheme: IconThemeData(color: _C.dark),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: Colors.white,
    indicatorColor: _C.primaryXlt,
    iconTheme: WidgetStateProperty.resolveWith(
      (s) => IconThemeData(
        color: s.contains(WidgetState.selected) ? _C.primary : _C.muted,
        size: 28,
      ),
    ),
    labelTextStyle: WidgetStateProperty.resolveWith(
      (s) => TextStyle(
        color: s.contains(WidgetState.selected) ? _C.primary : _C.muted,
        fontWeight: FontWeight.w800,
        fontSize: 13,
      ),
    ),
  ),
);

// ════════════════════════════════════════════════════════════════════════════════
//  RAÍZ DE LA APP
// ════════════════════════════════════════════════════════════════════════════════

class AprendeJugandoApp extends ConsumerStatefulWidget {
  const AprendeJugandoApp({super.key});

  @override
  ConsumerState<AprendeJugandoApp> createState() => _AprendeJugandoAppState();
}

class _AprendeJugandoAppState extends ConsumerState<AprendeJugandoApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(appControllerProvider.notifier).restoreSession(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    return MaterialApp(
      title: 'AprendeJugando',
      debugShowCheckedModeBanner: false,
      theme: _theme,
      home: switch (state.phase) {
        SessionPhase.loading => const SplashScreen(),
        SessionPhase.signedOut => const LoginScreen(),
        SessionPhase.needsProfile => const FirstProfileScreen(),
        SessionPhase.ready =>
          state.activity != null
              ? ActivityScreen(key: ValueKey(state.activity!.id))
              : state.activeModule != null
              ? const LevelMapScreen()
              : const MainShell(),
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
//  SPLASH SCREEN — animación elástica de entrada
// ════════════════════════════════════════════════════════════════════════════════

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  late final AnimationController _textCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 550),
  );

  late final _logoScale = CurvedAnimation(
    parent: _logoCtrl,
    curve: Curves.elasticOut,
  );
  late final _textFade = CurvedAnimation(
    parent: _textCtrl,
    curve: Curves.easeOut,
  );
  late final _textSlide = Tween<Offset>(
    begin: const Offset(0, .4),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));

  @override
  void initState() {
    super.initState();
    _logoCtrl.forward().then((_) => _textCtrl.forward());
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4A1A9E), Color(0xFF6941C6), Color(0xFF9B6BE8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(scale: _logoScale, child: const AppLogo(size: 120)),
            const SizedBox(height: 30),
            FadeTransition(
              opacity: _textFade,
              child: SlideTransition(
                position: _textSlide,
                child: Column(
                  children: [
                    const Text(
                      'AprendeJugando',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '¡Aprender es una aventura! 🚀',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .82),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 64),
            const _BouncingDots(),
          ],
        ),
      ),
    ),
  );
}

// Puntos que rebotan en la pantalla de carga
class _BouncingDots extends StatefulWidget {
  const _BouncingDots();
  @override
  State<_BouncingDots> createState() => _BouncingDotsState();
}

class _BouncingDotsState extends State<_BouncingDots>
    with TickerProviderStateMixin {
  late final List<AnimationController> _cs = List.generate(
    3,
    (i) => AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 420 + i * 100),
    )..repeat(reverse: true),
  );
  @override
  void dispose() {
    for (final c in _cs) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(
      3,
      (i) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: AnimatedBuilder(
          animation: _cs[i],
          builder: (_, _) => Transform.translate(
            offset: Offset(0, -12 * _cs[i].value),
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .5 + .5 * _cs[i].value),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

// ════════════════════════════════════════════════════════════════════════════════
//  LOGIN SCREEN
// ════════════════════════════════════════════════════════════════════════════════

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool obscure = true;
  bool registering = false;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();
    final ctrl = ref.read(appControllerProvider.notifier);
    registering
        ? await ctrl.register(email.text, password.text)
        : await ctrl.login(email.text, password.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    return Scaffold(
      body: Stack(
        children: [
          // Cabecera con degradado morado
          Container(
            height: MediaQuery.of(context).size.height * .36,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4A1A9E), _C.primaryLt],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(52)),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      const AppLogo(size: 88),
                      const SizedBox(height: 18),
                      Text(
                        registering
                            ? 'Crear cuenta familiar'
                            : 'Zona familiar 🏠',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        registering
                            ? 'Registra al adulto responsable y crea el primer perfil infantil.'
                            : 'El adulto responsable inicia sesión y el niño elige su perfil.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .82),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Tarjeta de formulario
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(34),
                          boxShadow: [
                            BoxShadow(
                              color: _C.primary.withValues(alpha: .14),
                              blurRadius: 36,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: email,
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: const [AutofillHints.username],
                                decoration: const InputDecoration(
                                  labelText: 'Correo del adulto',
                                  prefixIcon: Icon(Icons.mail_outline_rounded),
                                ),
                                validator: (v) {
                                  final t = v?.trim() ?? '';
                                  return t.contains('@') && t.contains('.')
                                      ? null
                                      : 'Ingresa un correo válido';
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: password,
                                obscureText: obscure,
                                autofillHints: const [AutofillHints.password],
                                decoration: InputDecoration(
                                  labelText: 'Contraseña',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () =>
                                        setState(() => obscure = !obscure),
                                    icon: Icon(
                                      obscure
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                  ),
                                ),
                                validator: (v) => (v?.length ?? 0) < 10
                                    ? 'Usa al menos 10 caracteres'
                                    : null,
                              ),
                              if (registering) ...[
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: confirmPassword,
                                  obscureText: obscure,
                                  decoration: const InputDecoration(
                                    labelText: 'Confirmar contraseña',
                                    prefixIcon: Icon(
                                      Icons.verified_user_outlined,
                                    ),
                                  ),
                                  validator: (v) => v != password.text
                                      ? 'Las contraseñas no coinciden'
                                      : null,
                                ),
                              ],
                              if (state.error != null) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _C.redLt,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    state.error!,
                                    style: const TextStyle(
                                      color: Color(0xFFB42318),
                                      fontWeight: FontWeight.w700,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 22),
                              ElevatedButton(
                                onPressed: state.busy ? null : submit,
                                child: state.busy
                                    ? const SizedBox.square(
                                        dimension: 26,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        registering
                                            ? 'Crear cuenta y agregar hijo'
                                            : 'Entrar y elegir perfil',
                                      ),
                              ),
                              const SizedBox(height: 10),
                              TextButton(
                                onPressed: state.busy
                                    ? null
                                    : () {
                                        setState(() {
                                          registering = !registering;
                                          confirmPassword.clear();
                                          if (registering) {
                                            email.clear();
                                            password.clear();
                                          }
                                        });
                                        ref
                                            .read(
                                              appControllerProvider.notifier,
                                            )
                                            .clearError();
                                      },
                                child: Text(
                                  registering
                                      ? 'Ya tengo cuenta: iniciar sesión'
                                      : 'Soy nuevo: crear una cuenta',
                                ),
                              ),
                              if (!registering)
                                const Text(
                                  'Ingresa con tu cuenta familiar o crea una nueva cuenta si es tu primera vez.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _C.muted,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
//  PRIMER PERFIL INFANTIL
// ════════════════════════════════════════════════════════════════════════════════

class FirstProfileScreen extends ConsumerWidget {
  const FirstProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(
      title: const Text('Primer perfil infantil'),
      actions: [
        TextButton(
          onPressed: () => ref.read(appControllerProvider.notifier).logout(),
          child: const Text('Salir'),
        ),
      ],
    ),
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: _C.primary.withValues(alpha: .10),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: _ProfileEditor(
                title: '¿Quién va a aprender? 🎒',
                description:
                    'Usa un apodo y evita guardar el nombre completo del niño.',
                submitLabel: 'Crear perfil y comenzar',
                onSave:
                    ({
                      required nickname,
                      required age,
                      grade,
                      required avatar,
                    }) => ref
                        .read(appControllerProvider.notifier)
                        .createProfile(
                          nickname: nickname,
                          age: age,
                          grade: grade,
                          avatar: avatar,
                        ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

typedef ProfileSaveCallback =
    Future<bool> Function({
      required String nickname,
      required int age,
      String? grade,
      required String avatar,
    });

class _ProfileEditor extends ConsumerStatefulWidget {
  const _ProfileEditor({
    required this.title,
    required this.description,
    required this.submitLabel,
    required this.onSave,
    this.initial,
    this.closeOnSuccess = false,
  });
  final String title;
  final String description;
  final String submitLabel;
  final ProfileSaveCallback onSave;
  final ChildProfile? initial;
  final bool closeOnSuccess;
  @override
  ConsumerState<_ProfileEditor> createState() => _ProfileEditorState();
}

class _ProfileEditorState extends ConsumerState<_ProfileEditor> {
  // 8 opciones de avatar para inicial
  static const avatars = [
    'fox',
    'owl',
    'bear',
    'lion',
    'panda',
    'penguin',
    'frog',
    'dragon',
  ];

  final formKey = GlobalKey<FormState>();
  late final TextEditingController nickname;
  late final TextEditingController grade;
  late int age;
  late String avatar;

  @override
  void initState() {
    super.initState();
    nickname = TextEditingController(text: widget.initial?.nickname ?? '');
    grade = TextEditingController(text: widget.initial?.grade ?? '');
    age = widget.initial?.age ?? 5;
    avatar = widget.initial?.avatar ?? avatars.first;
    if (!avatars.contains(avatar)) avatar = avatars.first;
  }

  @override
  void dispose() {
    nickname.dispose();
    grade.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();
    final saved = await widget.onSave(
      nickname: nickname.text,
      age: age,
      grade: grade.text,
      avatar: avatar,
    );
    if (saved && widget.closeOnSuccess && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(widget.description, style: const TextStyle(color: _C.muted)),
          const SizedBox(height: 22),
          // Vista previa del avatar seleccionado
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Text(
                _avatar(avatar),
                key: ValueKey(avatar),
                style: const TextStyle(fontSize: 72),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Selector de avatar en cuadrícula visual
          const Text(
            'Elige tu personaje',
            style: TextStyle(fontWeight: FontWeight.w700, color: _C.muted),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: avatars.map((av) {
              final selected = av == avatar;
              return _BounceButton(
                onTap: () => setState(() => avatar = av),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: selected ? _C.primaryXlt : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: selected ? _C.primary : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _avatar(av),
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: nickname,
            textCapitalization: TextCapitalization.words,
            maxLength: 40,
            decoration: const InputDecoration(
              labelText: 'Apodo del niño',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            validator: (v) => (v?.trim().length ?? 0) < 2
                ? 'Escribe un apodo de al menos 2 caracteres'
                : null,
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<int>(
            initialValue: age,
            decoration: const InputDecoration(
              labelText: 'Edad',
              prefixIcon: Icon(Icons.cake_outlined),
            ),
            items: [
              for (var v = 3; v <= 8; v++)
                DropdownMenuItem(value: v, child: Text('$v años')),
            ],
            onChanged: state.busy
                ? null
                : (v) => setState(() => age = v ?? age),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: grade,
            maxLength: 40,
            decoration: const InputDecoration(
              labelText: 'Grado (opcional)',
              prefixIcon: Icon(Icons.school_outlined),
              hintText: 'Ejemplo: Jardín de niños',
            ),
          ),
          if (state.error != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _C.redLt,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                state.error!,
                style: const TextStyle(
                  color: Color(0xFFB42318),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const SizedBox(height: 22),
          ElevatedButton(
            onPressed: state.busy ? null : save,
            child: state.busy
                ? const SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  )
                : Text(widget.submitLabel),
          ),
        ],
      ),
    );
  }
}

Future<void> _openProfileEditor(
  BuildContext context,
  WidgetRef ref, {
  ChildProfile? profile,
}) async {
  ref.read(appControllerProvider.notifier).clearError();
  await showDialog<void>(
    context: context,
    builder: (ctx) => Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(26),
          child: _ProfileEditor(
            initial: profile,
            closeOnSuccess: true,
            title: profile == null
                ? 'Agregar otro hijo 🧒'
                : 'Editar perfil ✏️',
            description: profile == null
                ? 'Cada hijo tendrá progreso y estrellas independientes.'
                : 'Actualiza el apodo, edad, grado o avatar.',
            submitLabel: profile == null ? 'Crear perfil' : 'Guardar cambios',
            onSave:
                ({required nickname, required age, grade, required avatar}) {
                  final ctrl = ref.read(appControllerProvider.notifier);
                  return profile == null
                      ? ctrl.createProfile(
                          nickname: nickname,
                          age: age,
                          grade: grade,
                          avatar: avatar,
                        )
                      : ctrl.updateProfile(
                          id: profile.id,
                          nickname: nickname,
                          age: age,
                          grade: grade,
                          avatar: avatar,
                        );
                },
          ),
        ),
      ),
    ),
  );
}

// ════════════════════════════════════════════════════════════════════════════════
//  SHELL PRINCIPAL — navegación inferior
// ════════════════════════════════════════════════════════════════════════════════

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});
  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    final pages = const [
      HomeView(),
      WorldsView(),
      ProgressView(),
      ProfileView(),
    ];

    ref.listen(appControllerProvider.select((v) => v.error), (_, next) {
      if (next != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next), behavior: SnackBarBehavior.floating),
        );
        ref.read(appControllerProvider.notifier).clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            const AppLogo(size: 44),
            const SizedBox(width: 10),
            const Text(
              'AprendeJugando',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        actions: [
          _Pill(
            icon: Icons.star_rounded,
            text: '${state.stars}',
            color: _C.yellow,
          ),
          const SizedBox(width: 10),
          // Avatar del niño activo
          GestureDetector(
            onTap: () => setState(() => index = 3),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: _C.yellowLt,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _avatar(state.selectedProfile?.avatar ?? 'owl'),
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
        ],
      ),
      body: Stack(
        children: [
          pages[index],
          if (state.busy) const Positioned.fill(child: _LoadingOverlay()),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (v) {
          HapticFeedback.selectionClick();
          setState(() => index = v);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'Mundos',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'Progreso',
          ),
          NavigationDestination(
            icon: Icon(Icons.face_outlined),
            selectedIcon: Icon(Icons.face_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
//  HOME VIEW — pantalla principal del niño
// ════════════════════════════════════════════════════════════════════════════════

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});
  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    return Stack(
      children: [
        const Positioned.fill(child: _AnimatedHomeBackground()),
        ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 36),
          children: [
            // ── Banner de bienvenida ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4A1A9E),
                    Color(0xFF6941C6),
                    Color(0xFF9B6BE8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(34),
                boxShadow: [
                  BoxShadow(
                    color: _C.primary.withValues(alpha: .38),
                    blurRadius: 30,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¡HOLA DE NUEVO!',
                          style: TextStyle(
                            color: Colors.yellow.shade200,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${state.selectedProfile?.nickname ?? ''}! 👋',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 30,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '¿Listo para una nueva aventura?',
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _Pill(
                              icon: Icons.star_rounded,
                              text: '${state.stars} estrellas',
                              color: _C.yellow,
                            ),
                            _Pill(
                              icon: Icons.local_fire_department_rounded,
                              text: '¡Racha activa!',
                              color: _C.orange,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Avatar animado flotante
                  AnimatedBuilder(
                    animation: _floatCtrl,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(0, -7 * _floatCtrl.value),
                      child: child,
                    ),
                    child: Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .18),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _avatar(state.selectedProfile?.avatar ?? 'owl'),
                          style: const TextStyle(fontSize: 50),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Módulos de aprendizaje ────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '¡Elige una aventura! 🚀',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _C.primaryXlt,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${state.modules.length} mundos',
                    style: const TextStyle(
                      color: _C.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: .88,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: state.modules.length,
              itemBuilder: (context, i) => ModuleCard(module: state.modules[i]),
            ),

            const SizedBox(height: 22),

            // ── Reto diario ───────────────────────────────────────────────────────
            _DailyChallengeCard(stars: state.stars),
          ],
        ),
      ],
    );
  }
}

class _AnimatedHomeBackground extends StatefulWidget {
  const _AnimatedHomeBackground();

  @override
  State<_AnimatedHomeBackground> createState() =>
      _AnimatedHomeBackgroundState();
}

class _AnimatedHomeBackgroundState extends State<_AnimatedHomeBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 5200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (context, child) {
      final t = _ctrl.value;
      return DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFFBFF), Color(0xFFF4EDFF), Color(0xFFEAF7FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            _FloatingBlob(
              top: 24 + (18 * t),
              left: -32,
              size: 132,
              color: _C.primary.withValues(alpha: .12),
            ),
            _FloatingBlob(
              top: 170 - (22 * t),
              right: -44,
              size: 156,
              color: _C.green.withValues(alpha: .10),
            ),
            _FloatingBlob(
              bottom: 96 + (18 * t),
              left: 28,
              size: 92,
              color: _C.yellow.withValues(alpha: .16),
            ),
            _FloatingBlob(
              bottom: 18 - (12 * t),
              right: 36,
              size: 118,
              color: const Color(0xFFEC4899).withValues(alpha: .10),
            ),
          ],
        ),
      );
    },
  );
}

class _FloatingBlob extends StatelessWidget {
  const _FloatingBlob({
    this.top,
    this.left,
    this.right,
    this.bottom,
    required this.size,
    required this.color,
  });
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Positioned(
    top: top,
    left: left,
    right: right,
    bottom: bottom,
    child: IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: .30),
              blurRadius: 36,
              spreadRadius: 8,
            ),
          ],
        ),
      ),
    ),
  );
}

// ════════════════════════════════════════════════════════════════════════════════
//  TARJETA DE MÓDULO
// ════════════════════════════════════════════════════════════════════════════════

class ModuleCard extends ConsumerWidget {
  const ModuleCard({super.key, required this.module});
  final LearningModule module;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _hex(module.color);
    return Semantics(
      button: true,
      label: 'Empezar ${module.name}',
      child: _BounceButton(
        onTap: () =>
            ref.read(appControllerProvider.notifier).openModule(module),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: .92),
                color.withValues(alpha: .13),
                color.withValues(alpha: .06),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(34),
            border: Border.all(color: color.withValues(alpha: .22), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: .16),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ícono con gradiente
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: .7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: .35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  _moduleIcon(module.id),
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const Spacer(),
              Text(
                module.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                module.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: _C.muted),
              ),
              const SizedBox(height: 10),
              // Barra de progreso mini
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (module.completedActivities / 10).clamp(
                          0.0,
                          1.0,
                        ),
                        minHeight: 7,
                        color: color,
                        backgroundColor: color.withValues(alpha: .14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${module.completedActivities}',
                    style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Icon(Icons.star_rounded, size: 13, color: color),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
//  WORLDS VIEW — explorador de mundos
// ════════════════════════════════════════════════════════════════════════════════

class WorldsView extends ConsumerWidget {
  const WorldsView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modules = ref.watch(appControllerProvider).modules;
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          'Mundos de aprendizaje 🌍',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        const Text(
          'Cada mundo tiene niveles y retos especiales para ti.',
          style: TextStyle(color: _C.muted),
        ),
        const SizedBox(height: 22),
        for (final module in modules) ...[
          _BounceButton(
            onTap: () =>
                ref.read(appControllerProvider.notifier).openModule(module),
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: _hex(module.color).withValues(alpha: .18),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: _hex(module.color),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      _moduleIcon(module.id),
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          module.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          module.description,
                          style: const TextStyle(color: _C.muted, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: (module.completedActivities / 10).clamp(
                              0.0,
                              1.0,
                            ),
                            minHeight: 8,
                            color: _hex(module.color),
                            backgroundColor: _hex(
                              module.color,
                            ).withValues(alpha: .12),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${module.completedActivities} actividades completadas',
                          style: TextStyle(
                            fontSize: 11,
                            color: _hex(module.color),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.play_circle_fill_rounded,
                    color: _hex(module.color),
                    size: 36,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
//  PROGRESS VIEW — estadísticas y logros
// ════════════════════════════════════════════════════════════════════════════════

class ProgressView extends ConsumerWidget {
  const ProgressView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final completed = state.modules.fold(
      0,
      (t, m) => t + m.completedActivities,
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          'Mi progreso 📊',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 18),
        // Métricas principales (2x2)
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.star_rounded,
                value: '${state.stars}',
                label: 'Estrellas',
                color: _C.yellow,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                icon: Icons.check_circle_rounded,
                value: '$completed',
                label: 'Completadas',
                color: _C.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.local_fire_department_rounded,
                value: '3',
                label: 'Días racha',
                color: _C.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                icon: Icons.emoji_events_rounded,
                value:
                    '${state.modules.where((m) => m.completedActivities > 0).length}',
                label: 'Mundos activos',
                color: _C.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        const Text(
          'Avance por mundo',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        const SizedBox(height: 14),
        for (final module in state.modules) _ProgressRow(module: module),
        const SizedBox(height: 26),
        const Text(
          'Logros 🏆',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _AchievementBadge(
              emoji: '⭐',
              label: 'Primera\nestrella',
              unlocked: state.stars > 0,
            ),
            _AchievementBadge(
              emoji: '🔥',
              label: '3 días\nracha',
              unlocked: true,
            ),
            _AchievementBadge(
              emoji: '🧮',
              label: 'Matemático',
              unlocked: state.modules.any(
                (m) => m.id == 'mathematics' && m.completedActivities > 0,
              ),
            ),
            _AchievementBadge(
              emoji: '📖',
              label: 'Lector',
              unlocked: state.modules.any(
                (m) => m.id == 'letters' && m.completedActivities > 0,
              ),
            ),
            _AchievementBadge(
              emoji: '🎨',
              label: 'Artista',
              unlocked: state.modules.any(
                (m) => m.id == 'art' && m.completedActivities > 0,
              ),
            ),
            _AchievementBadge(
              emoji: '🧩',
              label: 'Lógico',
              unlocked: state.modules.any(
                (m) => m.id == 'logic' && m.completedActivities > 0,
              ),
            ),
            _AchievementBadge(
              emoji: '🏆',
              label: '10\nestrellas',
              unlocked: state.stars >= 10,
            ),
            _AchievementBadge(
              emoji: '🚀',
              label: '25\nestrellas',
              unlocked: state.stars >= 25,
            ),
            _AchievementBadge(
              emoji: '💎',
              label: '50\nestrellas',
              unlocked: state.stars >= 50,
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
//  PROFILE VIEW — perfil y familia
// ════════════════════════════════════════════════════════════════════════════════

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final selected = state.selectedProfile!;
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          'Perfil y familia 👨‍👩‍👧',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 22),
        // Avatar grande con datos
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_C.primaryXlt, _C.yellowLt],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            children: [
              Text(
                _avatar(selected.avatar),
                style: const TextStyle(fontSize: 88),
              ),
              const SizedBox(height: 10),
              Text(
                selected.nickname,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                '${selected.age} años${selected.grade == null ? '' : ' · ${selected.grade}'}',
                style: const TextStyle(color: _C.muted),
              ),
              const SizedBox(height: 14),
              // Mini-resumen de progreso
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Pill(
                    icon: Icons.star_rounded,
                    text: '${state.stars} estrellas',
                    color: _C.yellow,
                  ),
                  const SizedBox(width: 10),
                  _Pill(
                    icon: Icons.emoji_events_rounded,
                    text: 'Nivel Pro',
                    color: _C.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Cambiar perfil',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
        ),
        const SizedBox(height: 10),
        for (final profile in state.profiles)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: profile.id == selected.id ? _C.primaryXlt : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: profile.id == selected.id
                  ? Border.all(color: _C.primary, width: 2)
                  : null,
            ),
            child: ListTile(
              leading: Text(
                _avatar(profile.avatar),
                style: const TextStyle(fontSize: 34),
              ),
              title: Text(
                profile.nickname,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                '${profile.age} años${profile.grade == null ? '' : ' · ${profile.grade}'}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (profile.id == selected.id)
                    const Icon(Icons.check_circle_rounded, color: _C.green),
                  IconButton(
                    tooltip: 'Editar ${profile.nickname}',
                    onPressed: () =>
                        _openProfileEditor(context, ref, profile: profile),
                    icon: const Icon(Icons.edit_outlined, color: _C.muted),
                  ),
                ],
              ),
              onTap: () => ref
                  .read(appControllerProvider.notifier)
                  .selectProfile(profile),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        const SizedBox(height: 14),
        ElevatedButton.icon(
          onPressed: () => _openProfileEditor(context, ref),
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text('Agregar otro hijo'),
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(58),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: () => ref.read(appControllerProvider.notifier).logout(),
          icon: const Icon(Icons.logout),
          label: const Text('Cerrar sesión familiar'),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
//  LEVEL MAP SCREEN — mapa de niveles del módulo
// ════════════════════════════════════════════════════════════════════════════════

class LevelMapScreen extends ConsumerWidget {
  const LevelMapScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final module = state.activeModule!;
    final color = _hex(module.color);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: state.busy
              ? null
              : () => ref.read(appControllerProvider.notifier).closeModule(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(module.name),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _Pill(
              icon: Icons.star_rounded,
              text: '${state.stars}',
              color: _C.yellow,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            children: [
              // Cabecera del módulo
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: .7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: .35),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .22),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _moduleIcon(module.id),
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mapa de ${module.name}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            module.description,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: .85),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              if (state.levels.isEmpty)
                const _EmptyLevels()
              else
                for (var i = 0; i < state.levels.length; i++)
                  _LevelNode(
                    level: state.levels[i],
                    isLast: i == state.levels.length - 1,
                    moduleColor: color,
                  ),
            ],
          ),
          if (state.busy) const Positioned.fill(child: _LoadingOverlay()),
        ],
      ),
    );
  }
}

class _LevelNode extends ConsumerWidget {
  const _LevelNode({
    required this.level,
    required this.isLast,
    required this.moduleColor,
  });
  final LevelModel level;
  final bool isLast;
  final Color moduleColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final available = level.unlocked && level.activities.isNotEmpty;
    return Column(
      children: [
        Semantics(
          button: available,
          label: available
              ? 'Abrir nivel ${level.number}, ${level.title}'
              : 'Nivel ${level.number} bloqueado',
          child: _BounceButton(
            onTap: available
                ? () =>
                      ref.read(appControllerProvider.notifier).openLevel(level)
                : null,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: available ? Colors.white : const Color(0xFFEDEAF1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: available
                      ? moduleColor.withValues(alpha: .35)
                      : const Color(0xFFE0DCE5),
                  width: 2,
                ),
                boxShadow: available
                    ? [
                        BoxShadow(
                          color: moduleColor.withValues(alpha: .12),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  // Número o candado
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: available
                          ? LinearGradient(
                              colors: [
                                moduleColor,
                                moduleColor.withValues(alpha: .75),
                              ],
                            )
                          : null,
                      color: available ? null : const Color(0xFFAAA3B3),
                      shape: BoxShape.circle,
                    ),
                    child: available
                        ? Center(
                            child: Text(
                              '${level.number}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.lock_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          level.title,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: available ? _C.dark : _C.muted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${level.activities.length} actividades',
                          style: const TextStyle(color: _C.muted, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    available
                        ? Icons.play_circle_fill_rounded
                        : Icons.lock_outline_rounded,
                    color: available ? moduleColor : const Color(0xFF9992A2),
                    size: 38,
                  ),
                ],
              ),
            ),
          ),
        ),
        // Conector de camino entre niveles
        if (!isLast)
          Container(
            width: 5,
            height: 30,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  moduleColor.withValues(alpha: .5),
                  moduleColor.withValues(alpha: .15),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}

class _EmptyLevels extends StatelessWidget {
  const _EmptyLevels();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 70),
    child: Column(
      children: [
        Text('🛠️', style: TextStyle(fontSize: 72)),
        SizedBox(height: 18),
        Text(
          'Este mundo está preparando nuevas aventuras.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 17,
            color: _C.muted,
          ),
        ),
      ],
    ),
  );
}

// ════════════════════════════════════════════════════════════════════════════════
//  ACTIVITY SCREEN — pantalla de reto / actividad
// ════════════════════════════════════════════════════════════════════════════════

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});
  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  bool answered = false;

  Future<void> submit(JsonMap answer) async {
    if (answered) return;
    HapticFeedback.lightImpact();
    final result = await ref
        .read(appControllerProvider.notifier)
        .answer(answer);
    if (result == null || !mounted) return;
    setState(() => answered = result.correct);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CelebrationDialog(
        correct: result.correct,
        feedback: result.feedback,
        onContinue: () => Navigator.pop(context),
      ),
    );

    if (result.correct && mounted) {
      await ref.read(appControllerProvider.notifier).finishActivity();
    } else if (mounted) {
      // Permitir reintentar
      setState(() => answered = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    final activity = state.activity!;
    final total = state.activeLevel?.activities.length ?? 1;
    final pos = state.activityPosition + 1;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: state.busy
              ? null
              : () => ref.read(appControllerProvider.notifier).exitActivity(),
          icon: const Icon(Icons.close_rounded),
        ),
        title: Text(state.activeModule?.name ?? 'Actividad'),
        actions: [
          // Vidas (corazones fijos)
          const Padding(
            padding: EdgeInsets.only(right: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('❤️', style: TextStyle(fontSize: 22)),
                Text('❤️', style: TextStyle(fontSize: 22)),
                Text('❤️', style: TextStyle(fontSize: 22)),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Barra de progreso del nivel
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Reto $pos de $total',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: _C.muted,
                          ),
                        ),
                        Text(
                          '${((pos - 1) / total * 100).round()}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: _C.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (pos - 1) / total,
                        minHeight: 11,
                        color: _C.primary,
                        backgroundColor: _C.primaryXlt,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Tarjeta principal de la actividad
                Container(
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: _C.primary.withValues(alpha: .10),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: _C.primaryXlt,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'RETO $pos DE $total',
                          style: const TextStyle(
                            color: _C.primary,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        activity.instruction,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 24),
                      ActivityInteraction(activity: activity, onAnswer: submit),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Mascota animadora
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _C.primaryXlt,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('🦉', style: TextStyle(fontSize: 40)),
                      SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          '¡Piensa con calma, tú puedes lograrlo! 💪',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: _C.primary,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (state.busy) const Positioned.fill(child: _LoadingOverlay()),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
//  ACTIVITY INTERACTION — enrutador de tipo de actividad
// ════════════════════════════════════════════════════════════════════════════════

class ActivityInteraction extends StatelessWidget {
  const ActivityInteraction({
    super.key,
    required this.activity,
    required this.onAnswer,
  });
  final ActivityModel activity;
  final ValueChanged<JsonMap> onAnswer;

  @override
  Widget build(BuildContext context) => switch (activity.type) {
    'visual_count' => _CountActivity(
      payload: activity.payload,
      onAnswer: onAnswer,
    ),
    'image_word_match' => _WordActivity(
      payload: activity.payload,
      onAnswer: onAnswer,
    ),
    'paint_shape' => _PaintActivity(
      payload: activity.payload,
      onAnswer: onAnswer,
    ),
    'memory_pairs' => _MemoryActivity(
      payload: activity.payload,
      onAnswer: onAnswer,
    ),
    'multiple_choice' => _ChoiceActivity(
      payload: activity.payload,
      onAnswer: onAnswer,
    ),
    'pattern_completion' => _PatternActivity(
      payload: activity.payload,
      onAnswer: onAnswer,
    ),
    _ => Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _C.primaryXlt,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Este tipo de actividad estará disponible pronto. 🔧',
          textAlign: TextAlign.center,
          style: TextStyle(color: _C.primary, fontWeight: FontWeight.w700),
        ),
      ),
    ),
  };
}

// ════════════════════════════════════════════════════════════════════════════════
//  ACTIVIDAD: CONTAR ELEMENTOS
// ════════════════════════════════════════════════════════════════════════════════

String _payloadText(JsonMap payload, String key, [String fallback = '']) {
  final value = payload[key];
  return value == null ? fallback : value.toString();
}

List<dynamic> _payloadList(JsonMap payload, String key) {
  final value = payload[key];
  return value is List ? value : const [];
}

String _displayValue(dynamic value, [Map<String, dynamic>? display]) {
  final key = value.toString();
  final mapped = display?[key];
  return mapped == null ? key : mapped.toString();
}

class _ActivityHint extends StatelessWidget {
  const _ActivityHint(this.text, {this.icon = Icons.auto_awesome_rounded});
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _C.primaryXlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.primary.withValues(alpha: .12)),
      ),
      child: Row(
        children: [
          Icon(icon, color: _C.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: _C.primary,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceActivity extends StatelessWidget {
  const _ChoiceActivity({required this.payload, required this.onAnswer});
  final JsonMap payload;
  final ValueChanged<JsonMap> onAnswer;

  @override
  Widget build(BuildContext context) {
    final options = _payloadList(payload, 'options');
    final scene = _payloadText(payload, 'scene');
    final question = _payloadText(
      payload,
      'question',
      'Elige la mejor respuesta',
    );
    final hint = _payloadText(payload, 'hint');
    return Column(
      children: [
        _ActivityHint(scene, icon: Icons.travel_explore_rounded),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _C.primary.withValues(alpha: .14)),
            boxShadow: [
              BoxShadow(
                color: _C.primary.withValues(alpha: .08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text('🧠', style: TextStyle(fontSize: 46)),
              const SizedBox(height: 10),
              Text(
                question,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: _C.dark,
                ),
              ),
              if (hint.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  hint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _C.muted, height: 1.35),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        _AnswerGrid(
          options: options,
          onSelected: (v) => onAnswer({'value': v}),
        ),
      ],
    );
  }
}

class _PatternActivity extends StatelessWidget {
  const _PatternActivity({required this.payload, required this.onAnswer});
  final JsonMap payload;
  final ValueChanged<JsonMap> onAnswer;

  @override
  Widget build(BuildContext context) {
    final sequence = _payloadList(payload, 'sequence');
    final options = _payloadList(payload, 'options');
    final display = payload['display'] is Map
        ? Map<String, dynamic>.from(payload['display'] as Map)
        : <String, dynamic>{};
    final scene = _payloadText(payload, 'scene');
    final hint = _payloadText(
      payload,
      'hint',
      'Mira el orden y completa el hueco.',
    );
    return Column(
      children: [
        _ActivityHint(scene, icon: Icons.route_rounded),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFFBEB), Color(0xFFFFF7ED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _C.yellow.withValues(alpha: .20)),
          ),
          child: Column(
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final item in sequence)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 260),
                      width: 58,
                      height: 58,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: item.toString() == '?'
                            ? Colors.white
                            : _C.yellowLt,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: item.toString() == '?'
                              ? _C.primary
                              : _C.yellow.withValues(alpha: .45),
                          width: item.toString() == '?' ? 3 : 1.5,
                        ),
                      ),
                      child: Text(
                        item.toString() == '?'
                            ? '?'
                            : _displayValue(item, display),
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                hint,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _C.muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _AnswerGrid(
          options: options,
          display: display,
          onSelected: (v) => onAnswer({'value': v}),
        ),
      ],
    );
  }
}

class _CountActivity extends StatelessWidget {
  const _CountActivity({required this.payload, required this.onAnswer});
  final JsonMap payload;
  final ValueChanged<JsonMap> onAnswer;

  @override
  Widget build(BuildContext context) {
    final rawItems = _payloadList(payload, 'items');
    final items = rawItems.isNotEmpty && rawItems.first is Map
        ? JsonMap.from(rawItems.first as Map)
        : <String, dynamic>{};
    final count = items['count'] is int ? items['count'] as int : 0;
    final emoji =
        items['emoji']?.toString() ??
        items['display']?.toString() ??
        _emojiForKey(items['value']?.toString() ?? items['kind']?.toString());
    final options = _payloadList(payload, 'options');
    final question = _payloadText(payload, 'question', '¿Cuántos hay?');
    return Column(
      children: [
        // Mostrar elementos a contar en cuadrícula
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _C.yellowLt,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: List.generate(
              count,
              (i) => Text(emoji, style: const TextStyle(fontSize: 44)),
            ),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 17,
            color: _C.muted,
          ),
        ),
        const SizedBox(height: 14),
        _AnswerGrid(
          options: options,
          onSelected: (v) => onAnswer({'value': v}),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
//  ACTIVIDAD: LETRA / PALABRA
// ════════════════════════════════════════════════════════════════════════════════

String _emojiForKey(String? key) {
  const icons = {
    'apple': '🍎',
    'banana': '🍌',
    'orange': '🍊',
    'star': '⭐',
    'rocket': '🚀',
    'book': '📘',
    'bee': '🐝',
    'frog': '🐸',
    'fish': '🐟',
    'flower': '🌸',
    'tree': '🌳',
    'moon': '🌙',
    'sun': '☀️',
    'rainbow': '🌈',
    'heart': '❤️',
    'key': '🔑',
    'shell': '🐚',
    'drum': '🥁',
    'brush': '🖌️',
    'gem': '💎',
  };
  return icons[key] ?? '🍎';
}

class _WordActivity extends StatelessWidget {
  const _WordActivity({required this.payload, required this.onAnswer});
  final JsonMap payload;
  final ValueChanged<JsonMap> onAnswer;

  @override
  Widget build(BuildContext context) {
    final options = _payloadList(payload, 'options');
    final letter = payload['letter'].toString();
    final question = _payloadText(
      payload,
      'question',
      '¿Qué empieza con "$letter"?',
    );
    final scene = _payloadText(payload, 'scene');
    return Column(
      children: [
        _ActivityHint(scene, icon: Icons.menu_book_rounded),
        Container(
          width: 120,
          height: 120,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: .35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            letter,
            style: const TextStyle(
              fontSize: 72,
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 17,
            color: _C.muted,
          ),
        ),
        const SizedBox(height: 14),
        _AnswerGrid(
          options: options,
          onSelected: (v) => onAnswer({'value': v}),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
//  ACTIVIDAD: PINTAR / COLOREAR
// ════════════════════════════════════════════════════════════════════════════════

class _PaintActivity extends StatefulWidget {
  const _PaintActivity({required this.payload, required this.onAnswer});
  final JsonMap payload;
  final ValueChanged<JsonMap> onAnswer;
  @override
  State<_PaintActivity> createState() => _PaintActivityState();
}

class _PaintActivityState extends State<_PaintActivity> {
  String? selected;
  static const _colorMap = {
    'red': Color(0xFFEF5350),
    'yellow': Color(0xFFFFD028),
    'blue': Color(0xFF3B82F6),
    'green': Color(0xFF36A269),
    'orange': Color(0xFFFF7043),
    'pink': Color(0xFFEC4899),
    'purple': Color(0xFF8B5CF6),
    'brown': Color(0xFF92400E),
  };
  static const _colorNames = {
    'red': 'Rojo',
    'yellow': 'Amarillo',
    'blue': 'Azul',
    'green': 'Verde',
    'orange': 'Naranja',
    'pink': 'Rosa',
    'purple': 'Morado',
    'brown': 'Café',
  };

  @override
  Widget build(BuildContext context) {
    final options = _payloadList(
      widget.payload,
      'colors',
    ).map((v) => v.toString()).toList();
    final shape = _payloadText(widget.payload, 'shape', 'star');
    final scene = _payloadText(widget.payload, 'scene');
    final clue = _payloadText(widget.payload, 'clue');
    final activeColor = selected == null
        ? const Color(0xFFE6E1EC)
        : _colorMap[selected]!;
    return Column(
      children: [
        _ActivityHint(scene, icon: Icons.palette_rounded),
        _ActivityHint(clue, icon: Icons.lightbulb_outline_rounded),
        // Figura a colorear
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
          child: Icon(_shapeIcon(shape), size: 140, color: activeColor),
        ),
        if (selected != null) ...[
          const SizedBox(height: 8),
          Text(
            _colorNames[selected] ?? selected!,
            style: TextStyle(
              color: activeColor,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
        ],
        const SizedBox(height: 20),
        // Selector de colores grande
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: options.map((name) {
            final c = _colorMap[name] ?? Colors.grey;
            final isSelected = selected == name;
            return Semantics(
              label: _colorNames[name] ?? name,
              button: true,
              child: _BounceButton(
                onTap: () => setState(() => selected = name),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF1C1033)
                          : Colors.white,
                      width: isSelected ? 4 : 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: c.withValues(alpha: .4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 26),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: selected == null
                ? Colors.grey.shade400
                : _C.primary,
          ),
          onPressed: selected == null
              ? null
              : () => widget.onAnswer({'color': selected}),
          child: const Text('¡Confirmar color! 🎨'),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
//  ACTIVIDAD: MEMORIA DE PARES
// ════════════════════════════════════════════════════════════════════════════════

IconData _shapeIcon(String shape) => switch (shape) {
  'heart' => Icons.favorite_rounded,
  'circle' => Icons.circle_rounded,
  'square' => Icons.square_rounded,
  'flower' => Icons.local_florist_rounded,
  'brush' => Icons.brush_rounded,
  'shield' => Icons.shield_rounded,
  'bolt' => Icons.bolt_rounded,
  'rocket' => Icons.rocket_launch_rounded,
  'water' => Icons.water_drop_rounded,
  'leaf' => Icons.eco_rounded,
  _ => Icons.star_rounded,
};

class _MemoryActivity extends StatelessWidget {
  const _MemoryActivity({required this.payload, required this.onAnswer});
  final JsonMap payload;
  final ValueChanged<JsonMap> onAnswer;

  @override
  Widget build(BuildContext context) {
    final pairs = _payloadList(
      payload,
      'pairs',
    ).map((v) => v.toString()).toList();
    final symbols = payload['symbols'] is Map
        ? Map<String, dynamic>.from(payload['symbols'] as Map)
        : <String, dynamic>{};
    final scene = _payloadText(payload, 'scene');
    return Column(
      children: [
        _ActivityHint(scene, icon: Icons.psychology_rounded),
        const Text(
          'Encuentra los pares iguales 🔍',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: _C.muted,
          ),
        ),
        const SizedBox(height: 16),
        _MemoryGrid(pairs: pairs, symbols: symbols, onAnswer: onAnswer),
      ],
    );
  }
}

class _MemoryGrid extends StatefulWidget {
  const _MemoryGrid({
    required this.pairs,
    required this.symbols,
    required this.onAnswer,
  });
  final List<String> pairs;
  final Map<String, dynamic> symbols;
  final ValueChanged<JsonMap> onAnswer;
  @override
  State<_MemoryGrid> createState() => _MemoryGridState();
}

class _MemoryGridState extends State<_MemoryGrid> {
  static const _icons = {
    'moon': '🌙',
    'sun': '☀️',
    'rainbow': '🌈',
    'star': '⭐',
    'heart': '❤️',
    'flower': '🌸',
    'bird': '🐦',
    'fish': '🐟',
  };
  late final List<String> cards;
  final Set<int> visible = {};
  final Set<int> matched = {};
  bool locked = false;

  @override
  void initState() {
    super.initState();
    cards = [...widget.pairs, ...widget.pairs]..shuffle();
  }

  Future<void> reveal(int index) async {
    if (locked || visible.contains(index) || matched.contains(index)) return;
    HapticFeedback.selectionClick();
    setState(() => visible.add(index));
    final open = visible.where((i) => !matched.contains(i)).toList();
    if (open.length < 2) return;
    locked = true;
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (cards[open[0]] == cards[open[1]]) {
      matched.addAll(open);
      if (matched.length == cards.length) {
        HapticFeedback.heavyImpact();
        widget.onAnswer({'pairs': cards.length ~/ 2});
      }
    } else {
      visible.removeAll(open);
    }
    locked = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 4,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
    ),
    itemCount: cards.length,
    itemBuilder: (_, i) {
      final isRevealed = visible.contains(i);
      final isMatched = matched.contains(i);
      return _FlipCard(
        isRevealed: isRevealed,
        isMatched: isMatched,
        emoji:
            widget.symbols[cards[i]]?.toString() ??
            _icons[cards[i]] ??
            _emojiForKey(cards[i]),
        onTap: () => reveal(i),
      );
    },
  );
}

// Tarjeta con animación "flip" para el juego de memoria
class _FlipCard extends StatefulWidget {
  const _FlipCard({
    required this.isRevealed,
    required this.isMatched,
    required this.emoji,
    required this.onTap,
  });
  final bool isRevealed;
  final bool isMatched;
  final String emoji;
  final VoidCallback onTap;
  @override
  State<_FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<_FlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );
  // Secuencia de escala: comprime → expande ligeramente → vuelve
  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.80), weight: 45),
    TweenSequenceItem(tween: Tween(begin: 0.80, end: 1.08), weight: 35),
    TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0), weight: 20),
  ]).animate(_ctrl);

  bool _shown = false;

  @override
  void initState() {
    super.initState();
    _shown = widget.isRevealed || widget.isMatched;
  }

  @override
  void didUpdateWidget(_FlipCard old) {
    super.didUpdateWidget(old);
    final nowShown = widget.isRevealed || widget.isMatched;
    if (nowShown != _shown) {
      setState(() => _shown = nowShown);
      if (nowShown) _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: widget.onTap,
    child: AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: widget.isMatched
              ? _C.greenLt
              : _shown
              ? const Color(0xFFFFF4CF)
              : _C.primary,
          borderRadius: BorderRadius.circular(16),
          border: widget.isMatched
              ? Border.all(color: _C.green, width: 3)
              : _shown
              ? Border.all(color: const Color(0xFFFFD28E), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color:
                  (widget.isMatched
                          ? _C.green
                          : _shown
                          ? _C.yellow
                          : _C.primary)
                      .withValues(alpha: .22),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: _shown
                ? Text(
                    widget.emoji,
                    key: const ValueKey('f'),
                    style: const TextStyle(fontSize: 30),
                  )
                : const Text(
                    '⭐',
                    key: ValueKey('b'),
                    style: TextStyle(fontSize: 26, color: Colors.white),
                  ),
          ),
        ),
      ),
    ),
  );
}

// ════════════════════════════════════════════════════════════════════════════════
//  CUADRÍCULA DE RESPUESTAS
// ════════════════════════════════════════════════════════════════════════════════

class _AnswerGrid extends StatelessWidget {
  const _AnswerGrid({
    required this.options,
    required this.onSelected,
    this.display = const {},
  });
  final List<dynamic> options;
  final ValueChanged<dynamic> onSelected;
  final Map<String, dynamic> display;

  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 2.2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
    ),
    itemCount: options.length,
    itemBuilder: (_, i) => _BounceButton(
      onTap: () => onSelected(options[i]),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _C.primary.withValues(alpha: .30),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _C.primary.withValues(alpha: .08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          _displayValue(options[i], display),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: _C.dark,
          ),
        ),
      ),
    ),
  );
}

// ════════════════════════════════════════════════════════════════════════════════
//  MÉTRICAS / TARJETA DE ESTADÍSTICA
// ════════════════════════════════════════════════════════════════════════════════

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: color.withValues(alpha: .20), width: 1.5),
    ),
    child: Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 30),
        ),
        Text(label, style: const TextStyle(color: _C.muted, fontSize: 13)),
      ],
    ),
  );
}

// ════════════════════════════════════════════════════════════════════════════════
//  LOGRO (BADGE DE ACHIEVEMENT)
// ════════════════════════════════════════════════════════════════════════════════

class _AchievementBadge extends StatelessWidget {
  const _AchievementBadge({
    required this.emoji,
    required this.label,
    required this.unlocked,
  });
  final String emoji;
  final String label;
  final bool unlocked;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: unlocked ? _C.yellowLt : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: unlocked ? _C.yellow : Colors.grey.shade300,
        width: 2,
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          emoji,
          style: TextStyle(fontSize: 32, color: unlocked ? null : null),
        ),
        if (!unlocked) const Text('🔒', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: unlocked ? const Color(0xFF92660A) : Colors.grey.shade400,
          ),
        ),
      ],
    ),
  );
}

// ════════════════════════════════════════════════════════════════════════════════
//  FILA DE PROGRESO POR MÓDULO
// ════════════════════════════════════════════════════════════════════════════════

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.module});
  final LearningModule module;

  @override
  Widget build(BuildContext context) {
    final color = _hex(module.color);
    final value = (module.completedActivities / 10).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  _moduleIcon(module.id),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  module.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                '${module.completedActivities}',
                style: TextStyle(fontWeight: FontWeight.w900, color: color),
              ),
              Icon(Icons.star_rounded, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 12,
              color: color,
              backgroundColor: color.withValues(alpha: .12),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
//  PILL — etiqueta pequeña con ícono
// ════════════════════════════════════════════════════════════════════════════════

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.text, required this.color});
  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .14),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 13,
          ),
        ),
      ],
    ),
  );
}

// ════════════════════════════════════════════════════════════════════════════════
//  LOADING OVERLAY
// ════════════════════════════════════════════════════════════════════════════════

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Colors.black.withValues(alpha: .18),
    child: Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(strokeWidth: 3),
            SizedBox(height: 14),
            Text(
              'Un momento...',
              style: TextStyle(fontWeight: FontWeight.w700, color: _C.muted),
            ),
          ],
        ),
      ),
    ),
  );
}

// ════════════════════════════════════════════════════════════════════════════════
//  CELEBRATION DIALOG — respuesta correcta o incorrecta con animación
// ════════════════════════════════════════════════════════════════════════════════

class _CelebrationDialog extends StatefulWidget {
  const _CelebrationDialog({
    required this.correct,
    required this.feedback,
    required this.onContinue,
  });
  final bool correct;
  final String feedback;
  final VoidCallback onContinue;
  @override
  State<_CelebrationDialog> createState() => _CelebrationDialogState();
}

class _CelebrationDialogState extends State<_CelebrationDialog>
    with TickerProviderStateMixin {
  late final AnimationController _entryCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  late final AnimationController _starsCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  late final _entryScale = CurvedAnimation(
    parent: _entryCtrl,
    curve: Curves.elasticOut,
  );

  @override
  void initState() {
    super.initState();
    _entryCtrl.forward();
    if (widget.correct) {
      HapticFeedback.heavyImpact();
      _starsCtrl.forward();
    } else {
      HapticFeedback.mediumImpact();
    }
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _starsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.transparent,
    insetPadding: const EdgeInsets.all(22),
    child: ScaleTransition(
      scale: _entryScale,
      child: Container(
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(38),
          boxShadow: [
            BoxShadow(
              color: (widget.correct ? _C.green : _C.primary).withValues(
                alpha: .28,
              ),
              blurRadius: 46,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Zona de animación con estrellas
            if (widget.correct)
              AnimatedBuilder(
                animation: _starsCtrl,
                builder: (_, _) {
                  final t = _starsCtrl.value;
                  return SizedBox(
                    width: 160,
                    height: 160,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Resplandor
                        AnimatedContainer(
                          duration: Duration.zero,
                          width: 110 * t,
                          height: 110 * t,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _C.yellow.withValues(alpha: .18 * t),
                          ),
                        ),
                        // Estrellas volando
                        ...List.generate(8, (i) {
                          final angle = (i / 8) * 2 * pi;
                          final radius = 65.0 * t;
                          return Transform.translate(
                            offset: Offset(
                              cos(angle) * radius,
                              sin(angle) * radius,
                            ),
                            child: Opacity(
                              opacity: (1 - t).clamp(0.0, 1.0),
                              child: Transform.scale(
                                scale: 0.4 + 0.6 * t,
                                child: const Text(
                                  '⭐',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                          );
                        }),
                        // Emoji central
                        const Text('🌟', style: TextStyle(fontSize: 72)),
                      ],
                    ),
                  );
                },
              )
            else
              const Text('💡', style: TextStyle(fontSize: 80)),

            const SizedBox(height: 14),

            Text(
              widget.correct ? '¡Excelente! 🎉' : '¡Casi lo tienes! 💪',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: widget.correct ? _C.green : _C.dark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              widget.feedback,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: _C.muted,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.correct ? _C.green : _C.primary,
                ),
                onPressed: widget.onContinue,
                child: Text(
                  widget.correct ? '¡Continuar! →' : 'Volver a intentar',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ════════════════════════════════════════════════════════════════════════════════
//  RETO DIARIO — tarjeta de motivación en Home
// ════════════════════════════════════════════════════════════════════════════════

class _DailyChallengeCard extends StatelessWidget {
  const _DailyChallengeCard({required this.stars});
  final int stars;

  @override
  Widget build(BuildContext context) {
    // Progreso ficticio hasta 5 estrellas de reto diario
    final progress = (stars % 5) / 5;
    final completed = stars >= 5;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8D9),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFFFD028).withValues(alpha: .5),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          const Text('🎯', style: TextStyle(fontSize: 46)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Reto diario',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    if (completed)
                      const _Pill(
                        icon: Icons.check_circle_rounded,
                        text: '¡Listo!',
                        color: _C.green,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Completa actividades y gana estrellas.',
                  style: TextStyle(color: _C.muted, fontSize: 13),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: completed ? 1.0 : progress,
                    minHeight: 10,
                    color: completed ? _C.green : _C.yellow,
                    backgroundColor: _C.yellow.withValues(alpha: .20),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  completed
                      ? '¡Reto completado hoy! 🌟'
                      : '${(stars % 5)}/5 estrellas de hoy',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: completed ? _C.green : _C.yellow,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
//  LOGO DE LA APP
// ════════════════════════════════════════════════════════════════════════════════

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, required this.size});
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF7B52D1), Color(0xFFEC4899)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(size * .28),
      boxShadow: [
        BoxShadow(
          color: const Color(0x446941C6),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Text(
      'AJ',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w900,
        fontSize: size * .34,
        letterSpacing: -1,
      ),
    ),
  );
}

// ════════════════════════════════════════════════════════════════════════════════
//  BOUNCE BUTTON — rebote táctil + háptico en cualquier widget
// ════════════════════════════════════════════════════════════════════════════════

class _BounceButton extends StatefulWidget {
  const _BounceButton({required this.child, required this.onTap});
  final Widget child;
  final VoidCallback? onTap;
  @override
  State<_BounceButton> createState() => _BounceButtonState();
}

class _BounceButtonState extends State<_BounceButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 130),
  );
  late final Animation<double> _sc = Tween<double>(
    begin: 1.0,
    end: 0.93,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _handle() async {
    if (widget.onTap == null) return;
    HapticFeedback.lightImpact();
    await _ctrl.forward();
    await _ctrl.reverse();
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: _handle,
    child: AnimatedBuilder(
      animation: _sc,
      builder: (_, child) => Transform.scale(scale: _sc.value, child: child),
      child: widget.child,
    ),
  );
}

// ════════════════════════════════════════════════════════════════════════════════
//  UTILIDADES
// ════════════════════════════════════════════════════════════════════════════════

Color _hex(String value) {
  final clean = value.replaceFirst('#', '');
  return Color(int.parse('FF$clean', radix: 16));
}

IconData _moduleIcon(String id) => switch (id) {
  'mathematics' => Icons.calculate_rounded,
  'letters' => Icons.menu_book_rounded,
  'logic' => Icons.extension_rounded,
  'art' => Icons.palette_rounded,
  _ => Icons.auto_awesome_rounded,
};

/// Devuelve el emoji del avatar según su identificador
String _avatar(String value) => switch (value) {
  'panda' => '🐼',
  'fox' => '🦊',
  'bear' => '🐻',
  'lion' => '🦁',
  'penguin' => '🐧',
  'frog' => '🐸',
  'dragon' => '🐲',
  _ => '🦉', // owl por defecto
};
