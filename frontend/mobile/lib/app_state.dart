import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import 'api_client.dart';
import 'models.dart';

enum SessionPhase { loading, signedOut, ready }

class AppState {
  const AppState({
    this.phase = SessionPhase.loading,
    this.busy = false,
    this.error,
    this.profiles = const [],
    this.selectedProfile,
    this.modules = const [],
    this.levels = const [],
    this.activity,
    this.activeModule,
    this.activeLevel,
    this.activityPosition = 0,
    this.stars = 0,
  });

  final SessionPhase phase;
  final bool busy;
  final String? error;
  final List<ChildProfile> profiles;
  final ChildProfile? selectedProfile;
  final List<LearningModule> modules;
  final List<LevelModel> levels;
  final ActivityModel? activity;
  final LearningModule? activeModule;
  final LevelModel? activeLevel;
  final int activityPosition;
  final int stars;

  AppState copyWith({
    SessionPhase? phase,
    bool? busy,
    String? error,
    bool clearError = false,
    List<ChildProfile>? profiles,
    ChildProfile? selectedProfile,
    List<LearningModule>? modules,
    List<LevelModel>? levels,
    ActivityModel? activity,
    bool clearActivity = false,
    LearningModule? activeModule,
    bool clearModule = false,
    LevelModel? activeLevel,
    bool clearLevel = false,
    int? activityPosition,
    int? stars,
  }) {
    return AppState(
      phase: phase ?? this.phase,
      busy: busy ?? this.busy,
      error: clearError ? null : error ?? this.error,
      profiles: profiles ?? this.profiles,
      selectedProfile: selectedProfile ?? this.selectedProfile,
      modules: modules ?? this.modules,
      levels: clearModule ? const [] : levels ?? this.levels,
      activity: clearActivity ? null : activity ?? this.activity,
      activeModule: clearModule ? null : activeModule ?? this.activeModule,
      activeLevel: clearLevel || clearModule
          ? null
          : activeLevel ?? this.activeLevel,
      activityPosition: clearLevel || clearModule
          ? 0
          : activityPosition ?? this.activityPosition,
      stars: stars ?? this.stars,
    );
  }
}

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
final appControllerProvider = NotifierProvider<AppController, AppState>(
  AppController.new,
);

class AppController extends Notifier<AppState> {
  static const _storage = FlutterSecureStorage();
  static const _uuid = Uuid();

  ApiClient get _api => ref.read(apiClientProvider);

  @override
  AppState build() => const AppState();

  Future<void> restoreSession() async {
    final token = await _storage.read(key: 'access_token');
    if (token == null) {
      state = state.copyWith(phase: SessionPhase.signedOut, clearError: true);
      return;
    }
    _api.useToken(token);
    try {
      await _loadWorkspace();
    } catch (_) {
      await _storage.deleteAll();
      _api.useToken(null);
      state = const AppState(phase: SessionPhase.signedOut);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(busy: true, clearError: true);
    try {
      final session = await _api.login(email, password);
      final accessToken = session['accessToken'] as String;
      final refreshToken = session['refreshToken'] as String;
      await _storage.write(key: 'access_token', value: accessToken);
      await _storage.write(key: 'refresh_token', value: refreshToken);
      _api.useToken(accessToken);
      await _loadWorkspace();
    } catch (error) {
      state = state.copyWith(
        phase: SessionPhase.signedOut,
        busy: false,
        error: friendlyApiError(error),
      );
    }
  }

  Future<void> _loadWorkspace() async {
    final profiles = await _api.profiles();
    if (profiles.isEmpty) {
      throw const ApiException('La cuenta no tiene perfiles infantiles.');
    }
    final savedId = await _storage.read(key: 'profile_id');
    final selected =
        profiles.where((profile) => profile.id == savedId).firstOrNull ??
        profiles.first;
    await _storage.write(key: 'profile_id', value: selected.id);
    final modules = await _api.modules(selected.id);
    state = AppState(
      phase: SessionPhase.ready,
      profiles: profiles,
      selectedProfile: selected,
      modules: modules,
      stars: modules.fold<int>(0, (total, module) => total + module.stars),
    );
  }

  Future<void> selectProfile(ChildProfile profile) async {
    state = state.copyWith(
      selectedProfile: profile,
      busy: true,
      clearError: true,
    );
    await _storage.write(key: 'profile_id', value: profile.id);
    try {
      final modules = await _api.modules(profile.id);
      state = state.copyWith(
        selectedProfile: profile,
        modules: modules,
        stars: modules.fold<int>(0, (total, module) => total + module.stars),
        busy: false,
      );
    } catch (error) {
      state = state.copyWith(busy: false, error: friendlyApiError(error));
    }
  }

  Future<void> openModule(LearningModule module) async {
    final profile = state.selectedProfile;
    if (profile == null) return;
    state = state.copyWith(
      busy: true,
      activeModule: module,
      clearLevel: true,
      clearActivity: true,
      clearError: true,
    );
    try {
      final levels = await _api.levels(module.id, profile.id);
      state = state.copyWith(busy: false, levels: levels, activeModule: module);
    } catch (error) {
      state = state.copyWith(
        busy: false,
        error: friendlyApiError(error),
        clearModule: true,
        clearActivity: true,
      );
    }
  }

  Future<void> openLevel(LevelModel level) async {
    final profile = state.selectedProfile;
    if (profile == null || !level.unlocked || level.activities.isEmpty) return;
    state = state.copyWith(
      busy: true,
      activeLevel: level,
      activityPosition: 0,
      clearError: true,
    );
    try {
      final activity = await _api.activity(
        level.activities.first.id,
        profile.id,
      );
      state = state.copyWith(
        busy: false,
        activity: activity,
        activeLevel: level,
        activityPosition: 0,
      );
    } catch (error) {
      state = state.copyWith(
        busy: false,
        error: friendlyApiError(error),
        clearLevel: true,
        clearActivity: true,
      );
    }
  }

  Future<AttemptResult?> answer(JsonMap answer) async {
    final activity = state.activity;
    final profile = state.selectedProfile;
    if (activity == null || profile == null) return null;
    state = state.copyWith(busy: true, clearError: true);
    try {
      final result = await _api.submitAttempt(
        activityId: activity.id,
        profileId: profile.id,
        clientAttemptId: _uuid.v4(),
        answer: answer,
      );
      state = state.copyWith(busy: false, stars: state.stars + result.stars);
      return result;
    } catch (error) {
      state = state.copyWith(busy: false, error: friendlyApiError(error));
      return null;
    }
  }

  Future<void> finishActivity() async {
    final profile = state.selectedProfile;
    final level = state.activeLevel;
    if (profile == null || level == null) return;
    final nextPosition = state.activityPosition + 1;
    if (nextPosition < level.activities.length) {
      state = state.copyWith(busy: true);
      try {
        final activity = await _api.activity(
          level.activities[nextPosition].id,
          profile.id,
        );
        state = state.copyWith(
          busy: false,
          activity: activity,
          activityPosition: nextPosition,
        );
      } catch (error) {
        state = state.copyWith(busy: false, error: friendlyApiError(error));
      }
      return;
    }
    final modules = await _api.modules(profile.id);
    final levels = state.activeModule == null
        ? state.levels
        : await _api.levels(state.activeModule!.id, profile.id);
    state = state.copyWith(
      modules: modules,
      levels: levels,
      stars: modules.fold<int>(0, (total, module) => total + module.stars),
      clearActivity: true,
      clearLevel: true,
    );
  }

  void exitActivity() =>
      state = state.copyWith(clearActivity: true, clearLevel: true);

  void closeModule() =>
      state = state.copyWith(clearActivity: true, clearModule: true);

  Future<void> logout() async {
    await _storage.deleteAll();
    _api.useToken(null);
    state = const AppState(phase: SessionPhase.signedOut);
  }

  void clearError() => state = state.copyWith(clearError: true);
}
