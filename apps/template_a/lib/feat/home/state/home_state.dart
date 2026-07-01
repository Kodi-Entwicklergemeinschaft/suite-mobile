import 'package:template_a/core/constant/state_constant.dart';
import 'package:template_a/feat/home/data/models/home_config.dart';

class HomeState {
  final List<ContentSliderConfig> components;
  final StateConstant configState;

  const HomeState({
    this.components = const [],
    this.configState = StateConstant.loading,
  });

  bool get isConfigLoading => configState == StateConstant.loading;

  HomeState copyWith({
    List<ContentSliderConfig>? components,
    StateConstant? configState,
  }) {
    return HomeState(
      components: components ?? this.components,
      configState: configState ?? this.configState,
    );
  }
}
