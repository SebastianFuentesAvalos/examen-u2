import 'package:gameon/features/home/models/institucion_deportiva.dart';
import 'package:gameon/features/home/services/instituciones_sin_conexion_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer; // Para logs más estructurados

// Sugerencia: si prefieres usar debugPrint en lugar de developer.log,
// reemplaza developer.log(...) por debugPrint(...).

// ViewModel encargado de la lógica para obtener instalaciones deportivas
class HomeViewModel {
  HomeViewModel({InstitucionesSinConexionService? sinConexionService})
    : _sinConexionService =
          sinConexionService ?? InstitucionesSinConexionService();

  final InstitucionesSinConexionService _sinConexionService;
  bool _mostrandoDatosSinConexion = false;

  bool get mostrandoDatosSinConexion => _mostrandoDatosSinConexion;

  Future<void> guardarSinConexion(List<InstitucionDeportiva> instituciones) =>
      _sinConexionService.guardar(instituciones);

  // Obtiene la lista de instalaciones deportivas activas desde Supabase
  Future<List<InstitucionDeportiva>> fetchInstituciones() async {
    try {
      final client = Supabase.instance.client;
      final session = client.auth.currentSession;
      developer.log(
        'fetchInstituciones: iniciando. Authenticated=${session != null} userId=${session?.user.id}',
        name: 'HomeViewModel',
      );
      developer.log(
        'fetchInstituciones: ejecutando query instituciones_deportivas (estado=1)...',
        name: 'HomeViewModel',
      );

      // Realiza la consulta a la tabla 'instituciones_deportivas' filtrando por estado = 1
      final data = await client
          .from('instituciones_deportivas')
          .select()
          .eq('estado', 1);

      developer.log(
        'fetchInstituciones: respuesta raw tipo=${data.runtimeType} tamaño=${data.length}',
        name: 'HomeViewModel',
      );

      // Convierte la respuesta en una lista de objetos InstitucionDeportiva
      final lista = (data as List)
          .map((json) => InstitucionDeportiva.fromJson(json))
          .toList();

      developer.log(
        'fetchInstituciones: mapeo completado. Registros=${lista.length}',
        name: 'HomeViewModel',
      );

      _mostrandoDatosSinConexion = false;
      return lista;
    } on PostgrestException catch (e, st) {
      // Logs detallados de la excepción de Postgrest (RLS / permisos / sintaxis)
      developer.log(
        'PostgrestException al consultar instituciones. code=${e.code} message=${e.message} details=${e.details} hint=${e.hint}',
        name: 'HomeViewModel',
        error: e,
        stackTrace: st,
        level: 1000,
      );
      return _recuperarListaGuardadaOReenviar(e);
    } catch (e, st) {
      developer.log(
        'Error inesperado al consultar instituciones: $e',
        name: 'HomeViewModel',
        error: e,
        stackTrace: st,
        level: 1000,
      );
      return _recuperarListaGuardadaOReenviar(e);
    } finally {
      developer.log('fetchInstituciones: finalizado', name: 'HomeViewModel');
    }
  }

  Future<List<InstitucionDeportiva>> _recuperarListaGuardadaOReenviar(
    Object errorOriginal,
  ) async {
    try {
      final guardadas = await _sinConexionService.leer();
      if (guardadas != null) {
        _mostrandoDatosSinConexion = true;
        developer.log(
          'fetchInstituciones: se muestran ${guardadas.length} registros guardados sin conexión.',
          name: 'HomeViewModel',
        );
        return guardadas;
      }
    } catch (error, stackTrace) {
      developer.log(
        'No fue posible leer el archivo sin conexión.',
        name: 'HomeViewModel',
        error: error,
        stackTrace: stackTrace,
        level: 1000,
      );
    }
    _mostrandoDatosSinConexion = false;
    throw errorOriginal;
  }
}
