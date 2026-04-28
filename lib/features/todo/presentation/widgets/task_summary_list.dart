import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo_assignment/features/todo/domain/entities/task.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/context_extension.dart';
import '../bloc/todo_bloc.dart';
import 'task_item.dart';
import '../../../../core/constants/app_strings.dart';

class TaskSummaryList extends StatelessWidget {
  final ScrollController scrollController;
  final Function(Task)? onTaskTap;

  const TaskSummaryList({
    super.key,
    required this.scrollController,
    this.onTaskTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocBuilder<TodoBloc, TodoState>(
      builder: (context, state) {
        if (state is TodoLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is TodoLoaded) {
          if (state.tasks.isEmpty) {
            return Center(
              child: Text(
                AppStrings.noTasksFound,
                style: GoogleFonts.inter(color: colors.textSecondary),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final query = state.searchQuery;
              if (query.isNotEmpty) {
                context.read<TodoBloc>().add(SearchTodos(query));
              } else {
                context.read<TodoBloc>().add(LoadTodos());
              }
            },
            child: ListView.separated(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.tasks.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppDimensions.p16),
              itemBuilder: (context, index) {
                final task = state.tasks[index];
                final isProcessing = state.processingIds.contains(task.localId);
                return TaskItem(
                  task: task,
                  isProcessing: isProcessing,
                  onTap: () => onTaskTap?.call(task),
                );
              },
            ),
          );
        }

        return const SizedBox();
      },
    );
  }
}
