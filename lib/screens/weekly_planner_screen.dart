import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/task_service.dart';
import '../models/task.dart';

class WeeklyPlannerScreen extends StatefulWidget {
  const WeeklyPlannerScreen({super.key});

  @override
  State<WeeklyPlannerScreen> createState() => _WeeklyPlannerScreenState();
}

class _WeeklyPlannerScreenState extends State<WeeklyPlannerScreen> {
  DateTime _currentWeekStart = _getSaturday(DateTime.now());

  // Helper: Get the most recent Saturday
  static DateTime _getSaturday(DateTime date) {
    // Saturday = 6 in DateTime.weekday (Monday=1, Sunday=7)
    int daysSinceSaturday = (date.weekday + 1) % 7;
    return date.subtract(Duration(days: daysSinceSaturday));
  }

  // Get dates for the week (Sat-Fri)
  List<DateTime> get _weekDates {
    return List.generate(7, (index) =>
        _currentWeekStart.add(Duration(days: index))
    );
  }

  // Get day name (Sat, Sun, Mon, etc.)
  String _getDayName(DateTime date) {
    return DateFormat('EEE').format(date); // Returns "Sat", "Sun", etc.
  }

  // Get formatted date (MMM dd)
  String _getFormattedDate(DateTime date) {
    return DateFormat('MMM dd').format(date);
  }

  // Check if date is today
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final taskService = Provider.of<TaskService>(context);

    return Scaffold(
      appBar: AppBar(
        title: _buildWeekHeader(),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _currentWeekStart = _getSaturday(DateTime.now());
              });
            },
            tooltip: 'Go to current week',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Add task directly to selected day
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Add task to specific day coming soon!'),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Week navigation
          _buildWeekNavigation(),

          // Day headers (Sat, Sun, Mon...)
          _buildDayHeaders(),

          // Divider
          const Divider(height: 1, thickness: 1),

          // Task columns for each day
          Expanded(
            child: _buildWeekGrid(context, taskService),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add task
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add task screen coming soon!'),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Week header (showing date range)
  Widget _buildWeekHeader() {
    final weekEnd = _currentWeekStart.add(const Duration(days: 6));
    final formattedStart = DateFormat('MMM dd').format(_currentWeekStart);
    final formattedEnd = DateFormat('MMM dd, yyyy').format(weekEnd);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Weekly Planner',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Text(
          '$formattedStart - $formattedEnd',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  // Week navigation (previous/next week buttons)
  Widget _buildWeekNavigation() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
              });
            },
            icon: const Icon(Icons.chevron_left),
            label: const Text('Previous Week'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
              });
            },
            icon: const Icon(Icons.chevron_right),
            label: const Text('Next Week'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // Day headers (Sat, Sun, Mon, Tue, Wed, Thu, Fri)
  Widget _buildDayHeaders() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.grey[50],
      child: Row(
        children: _weekDates.map((date) {
          final isToday = _isToday(date);
          return Expanded(
            child: Column(
              children: [
                Text(
                  _getDayName(date),
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isToday ? Colors.blue : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isToday ? Colors.blue : Colors.transparent,
                  ),
                  child: Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isToday ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // Main week grid with task columns
  Widget _buildWeekGrid(BuildContext context, TaskService taskService) {
    return Container(
      color: Colors.grey[100],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _weekDates.map((date) {
          final tasksForDay = taskService.getTasksForDay(date);
          final isToday = _isToday(date);

          return Expanded(
            child: Container(
              margin: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: isToday ? Colors.blue : Colors.grey.shade50,
                  width: isToday ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  // Day task count header
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: isToday ? Colors.blue.withOpacity(0.1) : Colors.grey[50],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          tasksForDay.length.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isToday ? Colors.blue : Colors.grey[700],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'tasks',
                          style: TextStyle(
                            color: isToday ? Colors.blue : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tasks list for this day
                  Expanded(
                    child: tasksForDay.isEmpty
                        ? _buildEmptyDayState(date)
                        : _buildDayTasksList(tasksForDay, taskService, date),
                  ),

                  // Add task button for this day
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _addTaskToDay(date, context);
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Task'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 36),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Empty state for days with no tasks
  Widget _buildEmptyDayState(DateTime date) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note,
              size: 40,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'No tasks',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // List of tasks for a specific day
  Widget _buildDayTasksList(List<Task> tasks, TaskService taskService, DateTime date) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskCard(task, taskService, date);
      },
    );
  }

  // Individual task card in the weekly planner
  Widget _buildTaskCard(Task task, TaskService taskService, DateTime date) {
    return GestureDetector(
      onTap: () {
        // TODO: Edit task
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Edit: ${task.title}'),
          ),
        );
      },
      onLongPress: () {
        _showTaskOptions(context, task, taskService, date);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: task.isCompleted
              ? Colors.green.withOpacity(0.1)
              : task.priorityColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: task.isCompleted
                ? Colors.green.withOpacity(0.3)
                : task.priorityColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task title with checkbox
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: task.isCompleted ? Colors.grey : Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Checkbox(
                  value: task.isCompleted,
                  onChanged: (value) {
                    taskService.toggleTaskCompletion(task.id);
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),

            const SizedBox(height: 4),

            // Task details (priority, time, category)
            Row(
              children: [
                // Priority indicator
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: task.priorityColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  task.priorityText,
                  style: TextStyle(
                    fontSize: 11,
                    color: task.priorityColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const Spacer(),

                // Time
                Icon(
                  Icons.access_time,
                  size: 12,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('h:mm a').format(task.dueDate),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),

            // Category
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                task.description,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Show options when long-pressing a task
  void _showTaskOptions(BuildContext context, Task task, TaskService taskService, DateTime date) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Task'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Edit task
                },
              ),
              ListTile(
                leading: Icon(
                  task.isCompleted ? Icons.undo : Icons.check_circle,
                  color: task.isCompleted ? Colors.orange : Colors.green,
                ),
                title: Text(task.isCompleted ? 'Mark Incomplete' : 'Mark Complete'),
                onTap: () {
                  taskService.toggleTaskCompletion(task.id);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.blue),
                title: const Text('Move to Another Day'),
                onTap: () {
                  Navigator.pop(context);
                  _showMoveTaskDialog(context, task, taskService);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Task'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteDialog(context, task, taskService);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Dialog to move task to another day
  void _showMoveTaskDialog(BuildContext context, Task task, TaskService taskService) {
    final weekDates = _weekDates;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Move Task to Another Day'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select a new due date:'),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: weekDates.map((date) {
                  return ChoiceChip(
                    label: Text(DateFormat('EEE, MMM dd').format(date)),
                    selected: task.dueDate.day == date.day,
                    onSelected: (selected) {
                      if (selected) {
                        final updatedTask = task.copyWith(dueDate: date);
                        taskService.updateTask(task.id, updatedTask);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Moved "${task.title}" to ${DateFormat('EEE, MMM dd').format(date)}'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Delete task dialog
  void _showDeleteDialog(BuildContext context, Task task, TaskService taskService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              taskService.deleteTask(task.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted: ${task.title}'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Add task to specific day
  void _addTaskToDay(DateTime date, BuildContext context) {
    // TODO: Implement actual add task with date pre-selected
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Add task to ${DateFormat('EEE, MMM dd').format(date)}'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }
}