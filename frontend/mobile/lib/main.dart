import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_state.dart';
import 'models.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: AprendeJugandoApp()));
}

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

final _theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF6941C6),
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: const Color(0xFFF8F6FC),
  fontFamily: 'sans-serif',
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.w900,
      letterSpacing: -1,
    ),
    headlineMedium: TextStyle(
      fontSize: 27,
      fontWeight: FontWeight.w900,
      letterSpacing: -.5,
    ),
    titleLarge: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
    bodyLarge: TextStyle(fontSize: 16, height: 1.4),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0xFF6941C6), width: 2),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size.fromHeight(58),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      backgroundColor: const Color(0xFF6941C6),
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
    ),
  ),
);

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppLogo(size: 88),
          SizedBox(height: 20),
          Text(
            'AprendeJugando',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 24),
          CircularProgressIndicator(),
        ],
      ),
    ),
  );
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final email = TextEditingController(text: 'familia@demo.local');
  final password = TextEditingController(text: 'DemoAprende123!');
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
    final controller = ref.read(appControllerProvider.notifier);
    if (registering) {
      await controller.register(email.text, password.text);
    } else {
      await controller.login(email.text, password.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(child: AppLogo(size: 76)),
                    const SizedBox(height: 22),
                    Text(
                      registering ? 'Crear cuenta familiar' : 'Zona familiar',
                      style: Theme.of(context).textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      registering
                          ? 'Registra al adulto responsable y luego crea el primer perfil infantil.'
                          : 'El adulto responsable inicia sesión y luego el niño elige su perfil.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF716A7C), height: 1.4),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.username],
                      decoration: const InputDecoration(
                        labelText: 'Correo del adulto',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        return text.contains('@') && text.contains('.')
                            ? null
                            : 'Ingresa un correo válido';
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: password,
                      obscureText: obscure,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => obscure = !obscure),
                          icon: Icon(
                            obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) => (value?.length ?? 0) < 10
                          ? 'Usa al menos 10 caracteres'
                          : null,
                    ),
                    if (registering) ...[
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: confirmPassword,
                        obscureText: obscure,
                        decoration: const InputDecoration(
                          labelText: 'Confirmar contraseña',
                          prefixIcon: Icon(Icons.verified_user_outlined),
                        ),
                        validator: (value) => value != password.text
                            ? 'Las contraseñas no coinciden'
                            : null,
                      ),
                    ],
                    if (state.error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Text(
                          state.error!,
                          style: const TextStyle(
                            color: Color(0xFFB42318),
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: state.busy ? null : submit,
                      child: state.busy
                          ? const SizedBox.square(
                              dimension: 24,
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
                    const SizedBox(height: 8),
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
                                  .read(appControllerProvider.notifier)
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
                        'Cuenta demo incluida para desarrollo local.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8A8395),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FirstProfileScreen extends ConsumerWidget {
  const FirstProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'Primer perfil infantil',
        style: TextStyle(fontWeight: FontWeight.w900),
      ),
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
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: _ProfileEditor(
                  title: '¿Quién va a aprender?',
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
  static const avatars = ['fox', 'owl', 'bear', 'lion', 'panda'];
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
          Text(
            widget.description,
            style: const TextStyle(color: Color(0xFF716A7C)),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: nickname,
            textCapitalization: TextCapitalization.words,
            maxLength: 40,
            decoration: const InputDecoration(
              labelText: 'Apodo del niño',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            validator: (value) => (value?.trim().length ?? 0) < 2
                ? 'Escribe un apodo de al menos 2 caracteres'
                : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: age,
            decoration: const InputDecoration(
              labelText: 'Edad',
              prefixIcon: Icon(Icons.cake_outlined),
            ),
            items: [
              for (var value = 4; value <= 8; value++)
                DropdownMenuItem(value: value, child: Text('$value años')),
            ],
            onChanged: state.busy
                ? null
                : (value) => setState(() => age = value ?? age),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: grade,
            maxLength: 40,
            decoration: const InputDecoration(
              labelText: 'Grado (opcional)',
              prefixIcon: Icon(Icons.school_outlined),
              hintText: 'Ejemplo: 1° primaria',
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: avatar,
            decoration: const InputDecoration(
              labelText: 'Avatar',
              prefixIcon: Icon(Icons.face_outlined),
            ),
            items: [
              for (final value in avatars)
                DropdownMenuItem(
                  value: value,
                  child: Text('${_avatar(value)}  ${_avatarName(value)}'),
                ),
            ],
            onChanged: state.busy
                ? null
                : (value) => setState(() => avatar = value ?? avatar),
          ),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                state.error!,
                style: const TextStyle(
                  color: Color(0xFFB42318),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: state.busy ? null : save,
            child: state.busy
                ? const SizedBox.square(
                    dimension: 22,
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
    builder: (dialogContext) => Dialog(
      insetPadding: const EdgeInsets.all(18),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: _ProfileEditor(
            initial: profile,
            closeOnSuccess: true,
            title: profile == null ? 'Agregar otro hijo' : 'Editar perfil',
            description: profile == null
                ? 'Cada hijo tendrá progreso y estrellas independientes.'
                : 'Actualiza el apodo, edad, grado o avatar.',
            submitLabel: profile == null ? 'Crear perfil' : 'Guardar cambios',
            onSave:
                ({required nickname, required age, grade, required avatar}) {
                  final controller = ref.read(appControllerProvider.notifier);
                  return profile == null
                      ? controller.createProfile(
                          nickname: nickname,
                          age: age,
                          grade: grade,
                          avatar: avatar,
                        )
                      : controller.updateProfile(
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
    final pages = [
      const HomeView(),
      const WorldsView(),
      const ProgressView(),
      const ProfileView(),
    ];
    ref.listen(appControllerProvider.select((value) => value.error), (_, next) {
      if (next != null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next)));
        ref.read(appControllerProvider.notifier).clearError();
      }
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Row(
          children: [
            AppLogo(size: 42),
            SizedBox(width: 10),
            Text(
              'AprendeJugando',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        actions: [
          _Pill(
            icon: Icons.star_rounded,
            text: '${state.stars}',
            color: const Color(0xFFFFB000),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            backgroundColor: const Color(0xFFFFD34F),
            child: Text(
              state.selectedProfile?.nickname.characters.first ?? '?',
              style: const TextStyle(fontWeight: FontWeight.w900),
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
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Mundos',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Progreso',
          ),
          NavigationDestination(
            icon: Icon(Icons.face_outlined),
            selectedIcon: Icon(Icons.face),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6941C6), Color(0xFF9B6BE8)],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x336941C6),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TU AVENTURA DE HOY',
                      style: TextStyle(
                        color: Color(0xFFFFE58A),
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '¡Hola, ${state.selectedProfile?.nickname ?? ''}! 👋',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tu curiosidad es tu superpoder.',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ],
                ),
              ),
              const Text('🦉', style: TextStyle(fontSize: 72)),
            ],
          ),
        ),
        const SizedBox(height: 26),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Elige una aventura',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Text(
              '4 mundos',
              style: TextStyle(
                color: Color(0xFF756E80),
                fontWeight: FontWeight.w700,
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
            childAspectRatio: .86,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: state.modules.length,
          itemBuilder: (context, index) =>
              ModuleCard(module: state.modules[index]),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF2C7),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Row(
            children: [
              Text('🎯', style: TextStyle(fontSize: 38)),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reto diario',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text('Completa una actividad y suma estrellas.'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ModuleCard extends ConsumerWidget {
  const ModuleCard({super.key, required this.module});
  final LearningModule module;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _hex(module.color);
    return Semantics(
      button: true,
      label: 'Empezar ${module.name}',
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () =>
            ref.read(appControllerProvider.notifier).openModule(module),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: color.withValues(alpha: .11),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withValues(alpha: .24), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  _moduleIcon(module.id),
                  color: Colors.white,
                  size: 30,
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
                style: const TextStyle(fontSize: 12, color: Color(0xFF706A79)),
              ),
              const SizedBox(height: 10),
              Text(
                '${module.completedActivities} actividades',
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WorldsView extends ConsumerWidget {
  const WorldsView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modules = ref.watch(appControllerProvider).modules;
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          'Mundos de aprendizaje',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        const Text(
          'Cada mundo contiene niveles cortos creados por el equipo.',
          style: TextStyle(color: Color(0xFF716A7C)),
        ),
        const SizedBox(height: 20),
        for (final module in modules)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              child: ListTile(
                minTileHeight: 92,
                leading: CircleAvatar(
                  radius: 27,
                  backgroundColor: _hex(module.color),
                  child: Icon(_moduleIcon(module.id), color: Colors.white),
                ),
                title: Text(
                  module.name,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(module.description),
                trailing: const Icon(Icons.arrow_forward_ios_rounded),
                onTap: () =>
                    ref.read(appControllerProvider.notifier).openModule(module),
              ),
            ),
          ),
      ],
    );
  }
}

class ProgressView extends ConsumerWidget {
  const ProgressView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final completed = state.modules.fold(
      0,
      (total, module) => total + module.completedActivities,
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text('Mi progreso', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.star_rounded,
                value: '${state.stars}',
                label: 'Estrellas',
                color: const Color(0xFFFFB000),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                icon: Icons.task_alt_rounded,
                value: '$completed',
                label: 'Completadas',
                color: const Color(0xFF2E9F69),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        for (final module in state.modules) _ProgressRow(module: module),
      ],
    );
  }
}

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
          'Perfil y familia',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            _avatar(selected.avatar),
            style: const TextStyle(fontSize: 86),
          ),
        ),
        Text(
          selected.nickname,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(
          '${selected.age} años${selected.grade == null ? '' : ' · ${selected.grade}'}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF716A7C)),
        ),
        const SizedBox(height: 24),
        const Text(
          'Cambiar perfil',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        for (final profile in state.profiles)
          Card(
            elevation: 0,
            child: ListTile(
              leading: Text(
                _avatar(profile.avatar),
                style: const TextStyle(fontSize: 32),
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
                    const Icon(Icons.check_circle, color: Color(0xFF2E9F69)),
                  IconButton(
                    tooltip: 'Editar ${profile.nickname}',
                    onPressed: () =>
                        _openProfileEditor(context, ref, profile: profile),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                ],
              ),
              onTap: () => ref
                  .read(appControllerProvider.notifier)
                  .selectProfile(profile),
            ),
          ),
        const SizedBox(height: 14),
        ElevatedButton.icon(
          onPressed: () => _openProfileEditor(context, ref),
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text('Agregar otro hijo'),
        ),
        const SizedBox(height: 22),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
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

class LevelMapScreen extends ConsumerWidget {
  const LevelMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final module = state.activeModule!;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: state.busy
              ? null
              : () => ref.read(appControllerProvider.notifier).closeModule(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          module.name,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _Pill(
              icon: Icons.star_rounded,
              text: '${state.stars}',
              color: const Color(0xFFFFB000),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: _hex(module.color).withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: _hex(module.color),
                      child: Icon(
                        _moduleIcon(module.id),
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mapa de ${module.name}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            module.description,
                            style: const TextStyle(color: Color(0xFF716A7C)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              if (state.levels.isEmpty)
                const _EmptyLevels()
              else
                for (var index = 0; index < state.levels.length; index++)
                  _LevelNode(
                    level: state.levels[index],
                    isLast: index == state.levels.length - 1,
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
  const _LevelNode({required this.level, required this.isLast});
  final LevelModel level;
  final bool isLast;

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
          child: InkWell(
            onTap: available
                ? () =>
                      ref.read(appControllerProvider.notifier).openLevel(level)
                : null,
            borderRadius: BorderRadius.circular(22),
            child: Ink(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: available ? Colors.white : const Color(0xFFEDEAF1),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: available
                      ? const Color(0xFFD8CCF3)
                      : const Color(0xFFE0DCE5),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: available
                        ? const Color(0xFF6941C6)
                        : const Color(0xFFAAA3B3),
                    child: available
                        ? Text(
                            '${level.number}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          )
                        : const Icon(Icons.lock_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          level.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${level.activities.length} actividades',
                          style: const TextStyle(color: Color(0xFF716A7C)),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    available
                        ? Icons.play_circle_fill_rounded
                        : Icons.lock_outline_rounded,
                    color: available
                        ? const Color(0xFF6941C6)
                        : const Color(0xFF9992A2),
                    size: 34,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!isLast)
          Container(width: 4, height: 28, color: const Color(0xFFD8CCF3)),
      ],
    );
  }
}

class _EmptyLevels extends StatelessWidget {
  const _EmptyLevels();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 60),
    child: Column(
      children: [
        Text('🛠️', style: TextStyle(fontSize: 62)),
        SizedBox(height: 14),
        Text(
          'Este mundo está preparando nuevas aventuras.',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
      ],
    ),
  );
}

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});
  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  bool answered = false;

  Future<void> submit(JsonMap answer) async {
    if (answered) return;
    final result = await ref
        .read(appControllerProvider.notifier)
        .answer(answer);
    if (result == null || !mounted) return;
    setState(() => answered = result.correct);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Text(
          result.correct ? '🌟' : '💡',
          style: const TextStyle(fontSize: 58),
        ),
        title: Text(
          result.correct ? '¡Lo lograste!' : 'Intentemos otra vez',
          textAlign: TextAlign.center,
        ),
        content: Text(result.feedback, textAlign: TextAlign.center),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(result.correct ? 'Continuar' : 'Volver a intentar'),
          ),
        ],
      ),
    );
    if (result.correct && mounted) {
      await ref.read(appControllerProvider.notifier).finishActivity();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    final activity = state.activity!;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: state.busy
              ? null
              : () => ref.read(appControllerProvider.notifier).exitActivity(),
          icon: const Icon(Icons.close_rounded),
        ),
        title: Text(
          state.activeModule?.name ?? 'Actividad',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _Pill(
              icon: Icons.favorite_rounded,
              text: '3',
              color: const Color(0xFFEF5350),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const LinearProgressIndicator(
                  value: 1,
                  minHeight: 9,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 24,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'RETO ${state.activityPosition + 1} DE ${state.activeLevel?.activities.length ?? 1}',
                        style: TextStyle(
                          color: Color(0xFF6941C6),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        activity.instruction,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 22),
                      ActivityInteraction(activity: activity, onAnswer: submit),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🦉', style: TextStyle(fontSize: 42)),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Mira con calma. ¡Tú puedes!',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF716A7C),
                        ),
                      ),
                    ),
                  ],
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

class ActivityInteraction extends StatelessWidget {
  const ActivityInteraction({
    super.key,
    required this.activity,
    required this.onAnswer,
  });
  final ActivityModel activity;
  final ValueChanged<JsonMap> onAnswer;

  @override
  Widget build(BuildContext context) {
    return switch (activity.type) {
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
      _ => const Text('Tipo de actividad pendiente de implementar.'),
    };
  }
}

class _CountActivity extends StatelessWidget {
  const _CountActivity({required this.payload, required this.onAnswer});
  final JsonMap payload;
  final ValueChanged<JsonMap> onAnswer;
  @override
  Widget build(BuildContext context) {
    final items = (payload['items'] as List).first as JsonMap;
    final count = items['count'] as int;
    final options = payload['options'] as List;
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: List.generate(
            count,
            (_) => const Text('🍎', style: TextStyle(fontSize: 48)),
          ),
        ),
        const SizedBox(height: 24),
        _AnswerGrid(
          options: options,
          onSelected: (value) => onAnswer({'value': value}),
        ),
      ],
    );
  }
}

class _WordActivity extends StatelessWidget {
  const _WordActivity({required this.payload, required this.onAnswer});
  final JsonMap payload;
  final ValueChanged<JsonMap> onAnswer;
  @override
  Widget build(BuildContext context) {
    final options = payload['options'] as List;
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFE9F7EF),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Text(
            payload['letter'].toString(),
            style: const TextStyle(
              fontSize: 64,
              color: Color(0xFF2E9F69),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _AnswerGrid(
          options: options,
          onSelected: (value) => onAnswer({'value': value}),
        ),
      ],
    );
  }
}

class _PaintActivity extends StatefulWidget {
  const _PaintActivity({required this.payload, required this.onAnswer});
  final JsonMap payload;
  final ValueChanged<JsonMap> onAnswer;
  @override
  State<_PaintActivity> createState() => _PaintActivityState();
}

class _PaintActivityState extends State<_PaintActivity> {
  String? selected;
  static const colors = {
    'red': Color(0xFFEF5350),
    'yellow': Color(0xFFFFD028),
    'blue': Color(0xFF3B82F6),
    'green': Color(0xFF36A269),
  };
  @override
  Widget build(BuildContext context) {
    final options = (widget.payload['colors'] as List).cast<String>();
    return Column(
      children: [
        Icon(
          Icons.star_rounded,
          size: 130,
          color: selected == null ? const Color(0xFFE6E1EC) : colors[selected],
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 14,
          children: options
              .map(
                (name) => Semantics(
                  label: name,
                  button: true,
                  child: InkWell(
                    onTap: () => setState(() => selected = name),
                    borderRadius: BorderRadius.circular(40),
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: colors[name],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected == name
                              ? const Color(0xFF292236)
                              : Colors.white,
                          width: 4,
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: selected == null
              ? null
              : () => widget.onAnswer({'color': selected}),
          child: const Text('Comprobar color'),
        ),
      ],
    );
  }
}

class _MemoryActivity extends StatefulWidget {
  const _MemoryActivity({required this.payload, required this.onAnswer});
  final JsonMap payload;
  final ValueChanged<JsonMap> onAnswer;
  @override
  State<_MemoryActivity> createState() => _MemoryActivityState();
}

class _MemoryActivityState extends State<_MemoryActivity> {
  late final List<String> cards;
  final Set<int> visible = {};
  final Set<int> matched = {};
  bool locked = false;
  static const icons = {
    'moon': '🌙',
    'sun': '☀️',
    'rainbow': '🌈',
    'star': '⭐',
  };

  @override
  void initState() {
    super.initState();
    final pairs = (widget.payload['pairs'] as List).cast<String>();
    cards = [...pairs, ...pairs]..shuffle();
  }

  Future<void> reveal(int index) async {
    if (locked || visible.contains(index) || matched.contains(index)) return;
    setState(() => visible.add(index));
    final open = visible.where((item) => !matched.contains(item)).toList();
    if (open.length < 2) return;
    locked = true;
    await Future<void>.delayed(const Duration(milliseconds: 550));
    if (cards[open[0]] == cards[open[1]]) {
      matched.addAll(open);
      if (matched.length == cards.length) {
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
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
    ),
    itemCount: cards.length,
    itemBuilder: (context, index) {
      final shown = visible.contains(index) || matched.contains(index);
      return InkWell(
        onTap: () => reveal(index),
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: shown ? const Color(0xFFFFF4CF) : const Color(0xFF6941C6),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              shown ? icons[cards[index]]! : '?',
              style: const TextStyle(
                fontSize: 27,
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _AnswerGrid extends StatelessWidget {
  const _AnswerGrid({required this.options, required this.onSelected});
  final List<dynamic> options;
  final ValueChanged<dynamic> onSelected;
  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 2.1,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
    ),
    itemCount: options.length,
    itemBuilder: (context, index) => OutlinedButton(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: const BorderSide(color: Color(0xFFD9D1E6), width: 2),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
      ),
      onPressed: () => onSelected(options[index]),
      child: Text(options[index].toString()),
    ),
  );
}

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
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      children: [
        Icon(icon, color: color, size: 34),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 28),
        ),
        Text(label, style: const TextStyle(color: Color(0xFF716A7C))),
      ],
    ),
  );
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.module});
  final LearningModule module;
  @override
  Widget build(BuildContext context) {
    final color = _hex(module.color);
    final value = (module.completedActivities / 10).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_moduleIcon(module.id), color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  module.name,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              Text('${module.completedActivities} completadas'),
            ],
          ),
          const SizedBox(height: 9),
          LinearProgressIndicator(
            value: value,
            minHeight: 10,
            color: color,
            backgroundColor: color.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.text, required this.color});
  final IconData icon;
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .13),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(color: color, fontWeight: FontWeight.w900),
        ),
      ],
    ),
  );
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Colors.white70,
    child: Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const CircularProgressIndicator(),
      ),
    ),
  );
}

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
        colors: [Color(0xFF7B52D1), Color(0xFFEF7DB6)],
      ),
      borderRadius: BorderRadius.circular(size * .3),
      boxShadow: const [
        BoxShadow(
          color: Color(0x336941C6),
          blurRadius: 16,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: Text(
      'AJ',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w900,
        fontSize: size * .34,
      ),
    ),
  );
}

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

String _avatar(String value) => switch (value) {
  'panda' => '🐼',
  'fox' => '🦊',
  'bear' => '🐻',
  'lion' => '🦁',
  _ => '🦉',
};

String _avatarName(String value) => switch (value) {
  'panda' => 'Panda',
  'fox' => 'Zorro',
  'bear' => 'Oso',
  'lion' => 'León',
  _ => 'Búho',
};
