import 'package:aprendejugando_mobile/main.dart';
import 'package:aprendejugando_mobile/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra la identidad visual nativa', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AppLogo(size: 76))),
    );

    expect(find.text('AJ'), findsOneWidget);
  });

  testWidgets('la actividad de conteo envía la respuesta elegida', (
    tester,
  ) async {
    JsonMap? answer;
    const activity = ActivityModel(
      id: 'math-l01-a01',
      type: 'visual_count',
      instruction: 'Cuenta las cuatro manzanas',
      payload: {
        'items': [
          {'count': 4},
        ],
        'options': [3, 4, 5, 6],
      },
      rewardStars: 10,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActivityInteraction(
            activity: activity,
            onAnswer: (value) => answer = value,
          ),
        ),
      ),
    );
    await tester.tap(find.text('4'));
    await tester.pumpAndSettle();

    expect(answer, {'value': 4});
  });

  testWidgets('permite cambiar de inicio de sesión a registro', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen())),
    );

    await tester.tap(find.text('Soy nuevo: crear una cuenta'));
    await tester.pump();

    expect(find.text('Crear cuenta familiar'), findsOneWidget);
    expect(find.text('Confirmar contraseña'), findsOneWidget);
    expect(find.text('Crear cuenta y agregar hijo'), findsOneWidget);
  });

  testWidgets('solicita los datos del primer perfil infantil', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: FirstProfileScreen())),
    );

    expect(find.textContaining('Quién va a aprender'), findsOneWidget);
    expect(find.text('Apodo del niño'), findsOneWidget);
    expect(find.text('Crear perfil y comenzar'), findsOneWidget);
  });
}
