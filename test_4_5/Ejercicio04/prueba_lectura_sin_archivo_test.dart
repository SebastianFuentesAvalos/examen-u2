import 'package:flutter_test/flutter_test.dart';

import '../simulados_guardado_local.dart';

void main() {
  test(
    '4(c): sin archivo, la lectura devuelve una lista vacía sin error',
    () async {
      final repository = crearRepositorio(
        ArchivoLocalSimulado(),
        CifradoSimulado(),
      );

      final result = await repository.read();

      expect(result.clients, isEmpty);
      expect(result.message, isNull);
    },
  );
}
