import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry/components/feature_card.dart';
import 'package:zentry/components/zentry_animation.dart';
import 'package:zentry/features/feature_navigator/bloc/feature_navigator_bloc.dart';
import 'package:zentry/features/feature_navigator/bloc/feature_navigator_event.dart';
import 'package:zentry/features/feature_navigator/bloc/feature_navigator_state.dart';

class FeatureNavigatorScreen extends StatelessWidget {
  const FeatureNavigatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FeatureNavigatorBloc()..add(LoadFeatures()),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              const Center(child: ZentryAnimation(size: 150)),
              const SizedBox(height: 24),
              Expanded(
                child: BlocBuilder<FeatureNavigatorBloc, FeatureNavigatorState>(
                  builder: (context, state) {
                    if (state is FeatureNavigatorLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is FeatureNavigatorLoaded) {
                      final features = state.features;
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: features.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final feature = features[index];
                          return FeatureCard(
                            title: feature.title,
                            description: feature.description,
                            icon: feature.icon,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => feature.screenBuilder(),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
