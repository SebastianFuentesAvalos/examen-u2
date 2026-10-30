import 'dart:convert';

/// Contrato del archivo local donde se conserva la caché sin conexión.

abstract interface class OfflineFile {
  Future<String?> read();
  Future<void> write(String content);
}

/// Contrato del cifrado de la caché local.
abstract interface class OfflineCipher {
  Future<String> encrypt(String plainText);
  Future<String> decrypt(String encryptedText);
  Future<void> deleteKey();
}

/// Registro mínimo que se conserva para consultar clientes sin conexión.
class OfflineClient {
  const OfflineClient({
    required this.id,
    required this.name,
    required this.email,
  });

  final String id;
  final String name;
  final String email;

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email};

  factory OfflineClient.fromJson(Map<String, dynamic> json) => OfflineClient(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
  );

  @override
  bool operator ==(Object other) =>
      other is OfflineClient &&
      other.id == id &&
      other.name == name &&
      other.email == email;

  @override
  int get hashCode => Object.hash(id, name, email);
}

/// Resultado de una lectura local, incluido un mensaje apto para mostrar al usuario.
class OfflineClientsReadResult {
  const OfflineClientsReadResult({required this.clients, this.message});

  final List<OfflineClient> clients;
  final String? message;
}

/// Guarda una lista de clientes como JSON cifrado y la recupera de forma segura.
class OfflineClientsRepository {
  OfflineClientsRepository({
    required OfflineFile file,
    required OfflineCipher cipher,
  }) : _file = file,
       _cipher = cipher;

  static const unavailableMessage =
      'Datos locales no disponibles, conéctese para actualizar';

  final OfflineFile _file;
  final OfflineCipher _cipher;

  Future<void> save(List<OfflineClient> clients) async {
    final plainText = jsonEncode(
      clients.map((client) => client.toJson()).toList(),
    );
    await _file.write(await _cipher.encrypt(plainText));
  }

  Future<OfflineClientsReadResult> read() async {
    final encryptedText = await _file.read();
    if (encryptedText == null || encryptedText.isEmpty) {
      return const OfflineClientsReadResult(clients: []);
    }

    try {
      final decoded =
          jsonDecode(await _cipher.decrypt(encryptedText)) as List<dynamic>;
      final clients = decoded
          .map((item) => OfflineClient.fromJson(item as Map<String, dynamic>))
          .toList();
      return OfflineClientsReadResult(clients: clients);
    } catch (_) {
      return const OfflineClientsReadResult(
        clients: [],
        message: unavailableMessage,
      );
    }
  }

  /// Vacía el archivo y elimina la clave asociada a su cifrado.
  Future<void> clear() async {
    await _file.write('');
    await _cipher.deleteKey();
  }
}
