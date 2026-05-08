/// Returns the home viewmodel content for the default home module.
String homeViewmodelTemplate() => r'''
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_viewmodel.freezed.dart';
part 'home_viewmodel.g.dart';

@freezed
sealed class HomeState with _$HomeState {
  const factory HomeState.initial() = _Initial;
  const factory HomeState.loading() = _Loading;
  const factory HomeState.loaded({required dynamic data}) = _Loaded;
  const factory HomeState.error({required String message}) = _Error;
}

@riverpod
class HomeViewModel extends _$HomeViewModel {
  @override
  HomeState build() {
    return const HomeState.initial();
  }

  Future<void> loadData() async {
    state = const HomeState.loading();
    try {
      // TODO: Inject use case and fetch data
      await Future<void>.delayed(const Duration(seconds: 1));
      state = const HomeState.loaded(data: 'Welcome to Riverflow!');
    } on Exception catch (e) {
      state = HomeState.error(message: e.toString());
    }
  }
}
''';
