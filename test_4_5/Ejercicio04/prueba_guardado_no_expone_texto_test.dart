import 'package:flutter_test/flutter_test.dart';
import 'package:gameon/core/services/offline_clients_repository.dart';

import '../simulados_guardado_local.dart';

void main() {
  test('4(a): el archivo cifrado no expone a Cliente Prueba', () async {
    final file = ArchivoLocalSimulado();
    final cipher = CifradoSimulado();
    final repository = crearRepositorio(file, cipher);

    await repository.save(const [
      OfflineClient(id: '1', name: 'Cliente Prueba', email: 'prueba@gameon.pe'),
    ]);

    expect(file.content, isNotNull);
    expect(file.content, isNot(contains('Cliente Prueba')));
  });
}
