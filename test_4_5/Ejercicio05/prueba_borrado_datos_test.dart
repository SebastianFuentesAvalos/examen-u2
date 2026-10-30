import 'package:flutter_test/flutter_test.dart';
import 'package:gameon/core/services/offline_clients_repository.dart';

import '../simulados_guardado_local.dart';

void main() {
  test('5(b): borrar datos vacía el archivo y elimina la clave', () async {
    final file = ArchivoLocalSimulado();
    final cipher = CifradoSimulado();
    final repository = crearRepositorio(file, cipher);
    await repository.save(const [
      OfflineClient(id: '1', name: 'Cliente Prueba', email: 'prueba@gameon.pe'),
    ]);

    await repository.clear();

    expect(file.content, isEmpty);
    expect(cipher.keyDeleted, isTrue);
  });
}
