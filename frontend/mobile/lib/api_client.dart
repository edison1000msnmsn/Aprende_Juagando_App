import 'package:dio/dio.dart';

import 'models.dart';

const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:3000/api/v1',
);

class ApiClient {
  ApiClient()
    : _dio = Dio(
        BaseOptions(
          baseUrl: apiBaseUrl,
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
          headers: const {'Content-Type': 'application/json'},
        ),
      );

  final Dio _dio;
  String? _accessToken;

  void useToken(String? token) {
    _accessToken = token;
  }

  Options get _authorized => Options(
    headers: {
      if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
    },
  );

  Future<JsonMap> login(String email, String password) async {
    return _map(
      await _dio.post(
        '/auth/login',
        data: {'email': email.trim(), 'password': password},
      ),
    );
  }

  Future<List<ChildProfile>> profiles() async {
    final data = _list(await _dio.get('/profiles', options: _authorized));
    return data.map(ChildProfile.fromJson).toList();
  }

  Future<List<LearningModule>> modules(String profileId) async {
    final data = _list(
      await _dio.get(
        '/modules',
        queryParameters: {'profileId': profileId},
        options: _authorized,
      ),
    );
    return data.map(LearningModule.fromJson).toList();
  }

  Future<List<LevelModel>> levels(String moduleId, String profileId) async {
    final response = _map(
      await _dio.get(
        '/modules/$moduleId/levels',
        queryParameters: {'profileId': profileId},
        options: _authorized,
      ),
    );
    return (response['levels'] as List)
        .map(
          (item) => LevelModel.fromJson((item as Map).cast<String, dynamic>()),
        )
        .toList();
  }

  Future<ActivityModel> activity(String activityId, String profileId) async {
    return ActivityModel.fromJson(
      _map(
        await _dio.get(
          '/activities/$activityId',
          queryParameters: {'profileId': profileId},
          options: _authorized,
        ),
      ),
    );
  }

  Future<AttemptResult> submitAttempt({
    required String activityId,
    required String profileId,
    required String clientAttemptId,
    required JsonMap answer,
  }) async {
    final response = await _dio.post(
      '/activities/$activityId/attempts',
      data: {
        'profileId': profileId,
        'clientAttemptId': clientAttemptId,
        'answer': answer,
        'elapsedMs': 2000,
      },
      options: _authorized,
    );
    return AttemptResult.fromJson(_map(response));
  }

  JsonMap _map(Response<dynamic> response) =>
      (response.data as Map).cast<String, dynamic>();
  List<JsonMap> _list(Response<dynamic> response) => (response.data as List)
      .map((item) => (item as Map).cast<String, dynamic>())
      .toList();
}

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

String friendlyApiError(Object error) {
  if (error is ApiException) return error.message;
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['message'] != null) {
      final message = data['message'];
      return message is List ? message.join('\n') : message.toString();
    }
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout) {
      return 'No se pudo conectar con la API. Verifica Docker y la dirección del servidor.';
    }
  }
  return 'Ocurrió un problema. Inténtalo nuevamente.';
}
