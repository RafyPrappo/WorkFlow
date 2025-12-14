import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';
import '../services/pomodoro_service.dart';
import '../models/task.dart';
import '../models/pomodoro_session.dart';
import 'task_list_screen.dart';
import 'weekly_planner_screen.dart';
import 'pomodoro_screen.dart';
import 'add_edit_task_screen.dart'; // ADD THIS IMPORT

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Get current week dates (Saturday to Friday)
  List<DateTime> get _weekDates {
    final today = DateTime.now();
    // Find the most recent Saturday
    final daysSinceSaturday = (today.weekday + 1) % 7;
    final saturday = today.subtract(Duration(days: daysSinceSaturday));

    // Generate 7 days from Saturday to Friday
    return List.generate(7, (index) => saturday.add(Duration(days: index)));
  }

  // Get abbreviated day name (SAT, SUN, MON, etc.)
  String _getDayAbbreviation(DateTime date) {
    return DateFormat('EEE').format(date).toUpperCase();
  }

  // Get formatted date (OCT 20)
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

  // Get current day name (Monday, Oct 22)
  String _getTodayHeader() {
    final now = DateTime.now();
    return DateFormat('EEEE, MMM dd').format(now);
  }

  @override
  Widget build(BuildContext context) {
    final taskService = Provider.of<TaskService>(context);
    final pomodoroService = Provider.of<PomodoroService>(context);
    final todayTasks = taskService.getTasksForDay(DateTime.now());

    // Get today's incomplete tasks for display
    final todayIncompleteTasks = todayTasks.where((task) => !task.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('WorkFlow Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      drawer: _buildSidebar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // WEEK HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.grey[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Week of ${_getFormattedDate(_weekDates.first)}-${DateFormat('dd').format(_weekDates.last)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // DATE NUMBERS ROW
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _weekDates.map((date) {
                      return Text(
                        date.day.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: _isToday(date) ? Colors.blue : Colors.black,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 4),

                  // DAY ABBREVIATIONS ROW
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _weekDates.map((date) {
                      return Text(
                        _getDayAbbreviation(date),
                        style: TextStyle(
                          fontSize: 14,
                          color: _isToday(date) ? Colors.blue : Colors.grey[600],
                          fontWeight: _isToday(date) ? FontWeight.bold : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1),

            // TODAY'S HEADER
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.today, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    'Today: ${_getTodayHeader()}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // TASKS LIST SECTION
            if (todayIncompleteTasks.isEmpty)
              _buildEmptyTaskState()
            else
              ...todayIncompleteTasks.map((task) => _buildTaskItem(context, task, pomodoroService, taskService)).toList(),

            // ADD TASK BUTTON - UPDATED
            Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddEditTaskScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('ADD TASK'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Colors.blue),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      // BOTTOM NAVIGATION BAR
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const WeeklyPlannerScreen(),
              ),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TaskListScreen(),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PomodoroScreen(),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Weekly',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Pomodoro',
          ),
        ],
      ),
    );
  }

  // Build the sidebar/drawer
  Widget _buildSidebar(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'WorkFlow',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Productivity Dashboard',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Back Button (Closes drawer and goes back)
          ListTile(
            leading: const Icon(Icons.arrow_back, color: Colors.blue),
            title: const Text(
              'Back',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.pop(context); // Close drawer
            },
          ),

          const Divider(),

          // Settings Section
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
            child: Text(
              'Settings',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),

          // Settings Items
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.grey),
            title: const Text('App Settings'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings screen coming soon!'),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.grey),
            title: const Text('Notifications'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notification settings coming soon!'),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.palette, color: Colors.grey),
            title: const Text('Theme'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Theme customization coming soon!'),
                ),
              );
            },
          ),

          const Divider(),

          // Analytics Section
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
            child: Text(
              'Weekly Analytics',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),

          // Analytics Items with "To be added" indicators
          ListTile(
            leading: const Icon(Icons.bar_chart, color: Colors.grey),
            title: const Text('Productivity Stats'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'To be added',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Productivity analytics coming soon!'),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.timer, color: Colors.grey),
            title: const Text('Focus Time'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'To be added',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Focus time analytics coming soon!'),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.task_alt, color: Colors.grey),
            title: const Text('Task Completion'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'To be added',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Task completion analytics coming soon!'),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.trending_up, color: Colors.grey),
            title: const Text('Weekly Trends'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'To be added',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Weekly trends analytics coming soon!'),
                ),
              );
            },
          ),

          const Divider(),

          // Additional "To be added" items
          ListTile(
            leading: const Icon(Icons.group, color: Colors.grey),
            title: const Text('Team Collaboration'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'To be added',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Team features coming soon!'),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.cloud, color: Colors.grey),
            title: const Text('Cloud Sync'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'To be added',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cloud sync coming soon!'),
                ),
              );
            },
          ),

          const Divider(),

          // Footer
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WorkFlow v1.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Productivity App',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build empty state when no tasks
  Widget _buildEmptyTaskState() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              Icons.task_alt,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No tasks scheduled for today',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add tasks to see them here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build individual task item - UPDATED with taskService parameter
  Widget _buildTaskItem(BuildContext context, Task task, PomodoroService pomodoroService, TaskService taskService) {
    // Get pomodoro sessions for this task (for demo, we'll show 3 sessions with 1 done)
    final totalPomodoros = 3;
    final completedPomodoros = 1;

    // Format time (09:00 AM format)
    final timeString = DateFormat('hh:mm a').format(task.dueDate);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time and Status Row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  timeString,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (task.isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'COMPLETED',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '$totalPomodoros Pomodoro',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '($completedPomodoros/$totalPomodoros done)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Task Title
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Text(
              task.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Task Details Row
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              children: [
                // Type/Category
                Row(
                  children: [
                    Icon(
                      task.categoryIcon,
                      size: 16,
                      color: task.priorityColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Type: ${task.categoryText}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 16),

                // Due time
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Due: ${DateFormat('h:mm a').format(task.dueDate)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Buttons
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Start pomodoro for this task
                      pomodoroService.setTask(task.id);
                      pomodoroService.setPhase(PomodoroPhase.focus);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PomodoroScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('Start Focus'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: task.priorityColor),
                      foregroundColor: task.priorityColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      taskService.toggleTaskCompletion(task.id);
                    },
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Complete'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.green),
                      foregroundColor: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // UPDATED: Show task options when long-pressing - includes Edit option
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditTaskScreen(task: task),
                    ),
                  );
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
}