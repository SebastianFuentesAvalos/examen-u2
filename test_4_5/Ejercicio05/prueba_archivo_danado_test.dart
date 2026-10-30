import 'package:flutter_test/flutter_test.dart';
import 'package:gameon/core/services/offline_clients_repository.dart';

import '../simulados_guardado_local.dart';

void main() {
  test(
    '5(a): si el descifrado falla, retorna lista vacía y mensaje amigable',
    () async {
      final file = ArchivoLocalSimulado()..content = 'contenido alterado';
      final cipher = CifradoSimulado()..failOnDecrypt = true;
      final repository = crearRepositorio(file, cipher);

      final result = await repository.read();

      expect(result.clients, isEmpty);
      expect(result.message, OfflineClientsRepository.unavailableMessage);
    },
  );
}
