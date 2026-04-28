import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/context_extension.dart';
import '../bloc/todo_bloc.dart';
import '../../../../core/constants/app_strings.dart';

class TodoQuickStats extends StatelessWidget {
  const TodoQuickStats({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocBuilder<TodoBloc, TodoState>(
      builder: (context, state) {
        int total = 0;
        int done = 0;
        int left = 0;

        if (state is TodoLoaded) {
          total = state.totalTasks;
          done = state.completedTasks;
          left = state.pendingTasks;
        }

        return Container(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.p16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.r16),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.05),
                blurRadius: AppDimensions.p10,
                offset: const Offset(0, AppDimensions.p4),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(label: AppStrings.total, value: '$total'),
                VerticalDivider(
                  color: colors.border,
                  thickness: 1,
                  width: 1,
                ), // Thickness/width 1 is standard
                _StatItem(
                  label: AppStrings.done,
                  value: '$done',
                  color: colors.success,
                ),
                VerticalDivider(color: colors.border, thickness: 1, width: 1),
                _StatItem(
                  label: AppStrings.left,
                  value: '$left',
                  color: colors.error,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _StatItem({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color ?? colors.primary,
          ),
        ),
        Text(
          label,
          style: context.textTheme.labelMedium?.copyWith(
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
