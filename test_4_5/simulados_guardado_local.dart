import 'dart:convert';

import 'package:gameon/core/services/offline_clients_repository.dart';

/// Reemplazo simulado del archivo privado de la aplicación.
class ArchivoLocalSimulado implements OfflineFile {
  String? content;

  @override
  Future<String?> read() async => content;

  @override
  Future<void> write(String value) async {
    content = value;
  }
}

/// Reemplazo simulado del cifrado. Base64 permite verificar el flujo sin usar
/// claves reales ni un emulador; también puede simular un descifrado fallido.
class CifradoSimulado implements OfflineCipher {
  bool failOnDecrypt = false;
  bool keyDeleted = false;

  @override
  Future<String> encrypt(String plainText) async =>
      'simulated-v1:${base64Encode(utf8.encode(plainText))}';

  @override
  Future<String> decrypt(String encryptedText) async {
    if (failOnDecrypt) throw const FormatException('Archivo alterado');
    const prefix = 'simulated-v1:';
    if (!encryptedText.startsWith(prefix)) {
      throw const FormatException('Formato cifrado inválido');
    }
    return utf8.decode(base64Decode(encryptedText.substring(prefix.length)));
  }

  @override
  Future<void> deleteKey() async {
    keyDeleted = true;
  }
}

OfflineClientsRepository crearRepositorio(
  ArchivoLocalSimulado file,
  CifradoSimulado cipher,
) => OfflineClientsRepository(file: file, cipher: cipher);
