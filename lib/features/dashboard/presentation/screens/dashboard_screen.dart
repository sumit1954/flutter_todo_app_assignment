import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:todo_assignment/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:todo_assignment/features/todo/domain/entities/task.dart';
import 'package:todo_assignment/features/todo/presentation/bloc/todo_bloc.dart';
import 'package:todo_assignment/features/todo/presentation/widgets/task_summary_list.dart';
import 'package:todo_assignment/features/todo/presentation/widgets/todo_quick_stats.dart';
import 'package:todo_assignment/features/todo/presentation/widgets/todo_side_info_panel.dart';
import 'package:todo_assignment/injection_container.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/context_extension.dart';
import '../../../../core/constants/app_strings.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query, BuildContext context) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<TodoBloc>().add(SearchTodos(query));
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocProvider(
      create: (context) => sl<TodoBloc>()..add(LoadTodos()),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final user = (authState is Authenticated) ? authState.user : null;

          return Scaffold(
            backgroundColor: colors.background,
            appBar: AppBar(
              title: _SearchBar(
                controller: _searchController,
                onChanged: (query) => _onSearchChanged(query, context),
              ),
              actions: [
                IconButton(
                  onPressed: () =>
                      context.read<AuthBloc>().add(LogoutRequested()),
                  icon: const Icon(Icons.logout),
                  tooltip: AppStrings.logout,
                ),
              ],
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor: colors.textMain,
            ),
            body: BlocConsumer<TodoBloc, TodoState>(
              listenWhen: (previous, current) => current is TodoMessage,
              listener: (context, state) {
                if (state is TodoMessage) {
                  final color = state.type == TodoMessageType.error
                      ? colors.error
                      : state.type == TodoMessageType.warning
                      ? colors.warning
                      : colors.primary;

                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: color,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
              buildWhen: (previous, current) => current is! TodoMessage,
              builder: (context, state) {
                return ResponsiveLayout(
                  builder: (context, screenType) {
                    return _DashboardContent(
                      user: user,
                      isMobile: screenType.isMobile,
                      scrollController: _scrollController,
                      onTaskTap: (task) => _showTaskDialog(context, task: task),
                    );
                  },
                );
              },
            ),
            floatingActionButton: Builder(
              builder: (context) => FloatingActionButton(
                onPressed: () => _showTaskDialog(context),
                backgroundColor: colors.primary,
                foregroundColor: colors.surface,
                child: const Icon(Icons.add),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showTaskDialog(BuildContext context, {Task? task}) {
    final controller = TextEditingController(text: task?.title);
    final isEditing = task != null;

    showDialog(
      context: context,
      builder: (dialogContext) {
        void onAction() {
          final value = controller.text.trim();
          if (value.isNotEmpty) {
            if (isEditing) {
              context.read<TodoBloc>().add(
                UpdateTodo(task.copyWith(title: value)),
              );
            } else {
              context.read<TodoBloc>().add(AddTodo(value));
            }
            Navigator.pop(dialogContext);
          }
        }

        return AlertDialog(
          title: Text(
            isEditing ? AppStrings.editTaskTitle : AppStrings.addTaskTitle,
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: AppStrings.taskTitleHint,
            ),
            onSubmitted: (_) => onAction(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(AppStrings.cancel),
            ),
            ElevatedButton(
              onPressed: onAction,
              child: Text(isEditing ? AppStrings.update : AppStrings.add),
            ),
          ],
        );
      },
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final dynamic user;
  final bool isMobile;
  final ScrollController scrollController;
  final Function(Task)? onTaskTap;

  const _DashboardContent({
    required this.user,
    required this.isMobile,
    required this.scrollController,
    this.onTaskTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: EdgeInsets.all(isMobile ? AppDimensions.p16 : AppDimensions.p40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppStrings.welcomeUserPrefix}${user?.name ?? AppStrings.welcomeUserDefault}!',
                  style: isMobile
                      ? context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.textMain,
                        )
                      : context.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.textMain,
                        ),
                ),
                const SizedBox(height: AppDimensions.p8),
                Text(
                  AppStrings.dashboardSubtitle,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),

                const SizedBox(height: AppDimensions.p32),
                if (isMobile) ...[
                  const TodoQuickStats(),
                  const SizedBox(height: AppDimensions.p24),
                ],
                Expanded(
                  child: TaskSummaryList(
                    scrollController: scrollController,
                    onTaskTap: onTaskTap,
                  ),
                ),
              ],
            ),
          ),

          if (!isMobile) ...[
            const SizedBox(width: AppDimensions.p32),
            const Expanded(
              child: SingleChildScrollView(child: TodoSideInfoPanel()),
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final FocusNode _focusNode = FocusNode();
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.controller.text.isNotEmpty;
    _focusNode.addListener(_updateExpandedState);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_updateExpandedState);
    _focusNode.dispose();
    super.dispose();
  }

  void _updateExpandedState() {
    final bool shouldExpand =
        _focusNode.hasFocus || widget.controller.text.isNotEmpty;
    if (_isExpanded != shouldExpand) {
      setState(() {
        _isExpanded = shouldExpand;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final displayWidth = MediaQuery.of(context).size.width;
    final expandedWidth = displayWidth - 118;
    final searchBar = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: _isExpanded ? expandedWidth : AppDimensions.p48,
      height: AppDimensions.p40,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              focusNode: _focusNode,
              controller: widget.controller,
              onTapOutside: (event) => _focusNode.unfocus(),
              onChanged: (value) {
                widget.onChanged(value);
                setState(() {});
              },
              style: context.textTheme.bodyMedium,
              decoration: InputDecoration(
                suffixIcon: (_isExpanded && widget.controller.text.isNotEmpty)
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: colors.textSecondary,
                          size: AppDimensions.p16,
                        ),
                        onPressed: () {
                          widget.controller.clear();
                          widget.onChanged('');
                          _focusNode.requestFocus();
                          setState(() {});
                        },
                      )
                    : SizedBox.shrink(),
                prefixIcon: IconButton(
                  icon: Icon(
                    Icons.search,
                    color: colors.textSecondary,
                    size: AppDimensions.p20,
                  ),
                  onPressed: () {
                    if (!_isExpanded) {
                      _focusNode.requestFocus();
                    } else if (widget.controller.text.isEmpty) {
                      _focusNode.unfocus();
                    }
                  },
                ),
                hintText: AppStrings.searchHint,
                hintStyle: context.textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary.withValues(alpha: 0.5),
                ),
                fillColor: colors.surface,
                // filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.r20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    return Row(
      spacing: AppDimensions.p16,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // if (!_isExpanded)
        Flexible(
          child: Text(
            AppStrings.appName,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        searchBar,
      ],
    );
  }
}
