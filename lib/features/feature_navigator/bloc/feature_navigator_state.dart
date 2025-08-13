import 'package:equatable/equatable.dart';
import 'package:zentry/features/feature_navigator/models/feature_item_ui.dart';

abstract class FeatureNavigatorState extends Equatable {
  const FeatureNavigatorState();

  @override
  List<Object?> get props => [];
}

class FeatureNavigatorLoading extends FeatureNavigatorState {}

class FeatureNavigatorLoaded extends FeatureNavigatorState {
  final List<FeatureItemUi> features;

  const FeatureNavigatorLoaded(this.features);

  @override
  List<Object?> get props => [features];
}
