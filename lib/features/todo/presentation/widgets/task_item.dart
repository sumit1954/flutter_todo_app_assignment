import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/context_extension.dart';
import '../../domain/entities/task.dart';
import '../bloc/todo_bloc.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final bool isProcessing;
  final VoidCallback? onTap;

  const TaskItem({
    super.key,
    required this.task,
    required this.isProcessing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Stack(
      children: [
        Opacity(
          opacity: isProcessing ? 0.6 : 1.0,
          child: IgnorePointer(
            ignoring: isProcessing,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppDimensions.r16),
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.p8),
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: AppDimensions.p48,
                      height: AppDimensions.p48,
                      child: isProcessing
                          ? const Center(
                              child: SizedBox(
                                width: AppDimensions.p24,
                                height: AppDimensions.p24,
                                child: CircularProgressIndicator(
                                  strokeWidth: AppDimensions.p2,
                                ),
                              ),
                            )
                          : Checkbox(
                              value: task.isCompleted,
                              onChanged: (_) {
                                context.read<TodoBloc>().add(
                                  UpdateTodo(
                                    task.copyWith(
                                      isCompleted: !task.isCompleted,
                                    ),
                                  ),
                                );
                              },
                              activeColor: colors.success,
                              shape: const CircleBorder(),
                            ),
                    ),
                    const SizedBox(width: AppDimensions.p8),
                    Expanded(
                      child: Text(
                        task.title,
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: task.isCompleted
                              ? colors.textSecondary
                              : colors.textMain,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    if (!isProcessing)
                      IconButton(
                        onPressed: () {
                          context.read<TodoBloc>().add(
                            DeleteTodo(id: task.id, localId: task.localId),
                          );
                        },
                        icon: Icon(
                          Icons.delete_outline,
                          color: colors.error.withValues(alpha: 0.6),
                          size: AppDimensions.p20,
                        ),
                      )
                    else
                      const SizedBox(width: AppDimensions.p48),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: AppDimensions.p8,
          right: AppDimensions.p8,
          child: Icon(
            task.isLocalEdit ? Icons.cloud_upload_outlined : Icons.cloud_done,
            size: AppDimensions.p14,
            color: task.isLocalEdit
                ? colors.error.withValues(alpha: 0.5)
                : colors.success.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
