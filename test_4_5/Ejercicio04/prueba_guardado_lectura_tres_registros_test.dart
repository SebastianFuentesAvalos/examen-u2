import 'package:flutter_test/flutter_test.dart';
import 'package:gameon/core/services/offline_clients_repository.dart';

import '../simulados_guardado_local.dart';

void main() {
  test('4(b): guarda y lee los mismos tres registros', () async {
    final repository = crearRepositorio(
      ArchivoLocalSimulado(),
      CifradoSimulado(),
    );
    const original = [
      OfflineClient(id: '1', name: 'Ana', email: 'ana@gameon.pe'),
      OfflineClient(id: '2', name: 'Bruno', email: 'bruno@gameon.pe'),
      OfflineClient(id: '3', name: 'Carla', email: 'carla@gameon.pe'),
    ];

    await repository.save(original);
    final result = await repository.read();

    expect(result.message, isNull);
    expect(result.clients, equals(original));
  });
}
