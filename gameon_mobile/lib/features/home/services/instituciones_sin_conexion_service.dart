import 'dart:convert';
import 'dart:io';

import 'package:gameon/features/home/models/institucion_deportiva.dart';
import 'package:path_provider/path_provider.dart';

/// Guarda la lista visible de instalaciones en el almacenamiento privado de la app.
/// El archivo se conserva en texto claro para poder revisarlo con `adb shell run-as`
/// durante la demostración del ejercicio.
class InstitucionesSinConexionService {
  static const nombreArchivo = 'instituciones_sin_conexion.json';

  Future<File> _archivo() async {
    final directorio = await getApplicationDocumentsDirectory();
    return File('${directorio.path}/$nombreArchivo');
  }

  Future<void> guardar(List<InstitucionDeportiva> instituciones) async {
    final archivo = await _archivo();
    final contenido = {
      'guardadoEn': DateTime.now().toIso8601String(),
      'instituciones': instituciones
          .map((institucion) => institucion.toJson())
          .toList(),
    };
    await archivo.writeAsString(
      const JsonEncoder.withIndent('  ').convert(contenido),
    );
  }

  /// Devuelve null cuando todavía no hay una lista guardada.
  Future<List<InstitucionDeportiva>?> leer() async {
    final archivo = await _archivo();
    if (!await archivo.exists()) return null;

    final contenido =
        jsonDecode(await archivo.readAsString()) as Map<String, dynamic>;
    final registros = (contenido['instituciones'] as List<dynamic>?) ?? [];
    return registros
        .map(
          (registro) => InstitucionDeportiva.fromJson(
            Map<String, dynamic>.from(registro as Map),
          ),
        )
        .toList();
  }
}
