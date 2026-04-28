import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/context_extension.dart';
import '../bloc/todo_bloc.dart';
import '../../../../core/constants/app_strings.dart';

class TodoSideInfoPanel extends StatelessWidget {
  const TodoSideInfoPanel({super.key});

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
          padding: const EdgeInsets.all(AppDimensions.p24),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.r24),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.quickStats,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.textMain,
                ),
              ),
              const SizedBox(height: AppDimensions.p20),
              _StatRow(label: AppStrings.totalTasks, value: '$total'),
              Divider(height: AppDimensions.p32, color: colors.border),
              _StatRow(
                label: AppStrings.completed,
                value: '$done',
                valueColor: colors.success,
              ),
              Divider(height: AppDimensions.p32, color: colors.border),
              _StatRow(
                label: AppStrings.pending,
                value: '$left',
                valueColor: colors.error,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _StatRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(
            color: colors.textSecondary,
          ),
        ),
        Text(
          value,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor ?? colors.primary,
          ),
        ),
      ],
    );
  }
}
