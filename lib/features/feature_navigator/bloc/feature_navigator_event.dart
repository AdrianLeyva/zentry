import 'package:equatable/equatable.dart';

abstract class FeatureNavigatorEvent extends Equatable {
  const FeatureNavigatorEvent();

  @override
  List<Object?> get props => [];
}

class LoadFeatures extends FeatureNavigatorEvent {}
