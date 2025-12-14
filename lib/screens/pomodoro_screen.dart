import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/pomodoro_service.dart';
import '../services/task_service.dart';
import '../models/task.dart';
import '../models/pomodoro_session.dart';

class PomodoroScreen extends StatelessWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pomodoroService = Provider.of<PomodoroService>(context);
    final taskService = Provider.of<TaskService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Timer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Session history coming soon!'),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Timer display
            _buildTimerDisplay(context, pomodoroService),

            const SizedBox(height: 40),

            // Phase selector
            _buildPhaseSelector(pomodoroService),

            const SizedBox(height: 30),

            // Task selector
            _buildTaskSelector(context, taskService, pomodoroService),

            const SizedBox(height: 40),

            // Controls
            _buildControls(pomodoroService),

            const SizedBox(height: 30),

            // Stats
            _buildStats(pomodoroService),
          ],
        ),
      ),
    );
  }

  // Timer circle with progress
  Widget _buildTimerDisplay(BuildContext context, PomodoroService pomodoroService) {
    // Helper function to get phase color
    Color getPhaseColor(PomodoroPhase phase) {
      switch (phase) {
        case PomodoroPhase.focus:
          return Colors.red;
        case PomodoroPhase.shortBreak:
          return Colors.green;
        case PomodoroPhase.longBreak:
          return Colors.blue;
      }
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // Progress circle
        SizedBox(
          width: 250,
          height: 250,
          child: CircularProgressIndicator(
            value: pomodoroService.progress,
            strokeWidth: 12,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              getPhaseColor(pomodoroService.currentPhase),
            ),
          ),
        ),

        // Time text
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              pomodoroService.formattedTime,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getPhaseName(pomodoroService.currentPhase),
              style: TextStyle(
                fontSize: 18,
                color: getPhaseColor(pomodoroService.currentPhase),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Get phase name
  String _getPhaseName(PomodoroPhase phase) {
    switch (phase) {
      case PomodoroPhase.focus:
        return 'Focus Time';
      case PomodoroPhase.shortBreak:
        return 'Short Break';
      case PomodoroPhase.longBreak:
        return 'Long Break';
    }
  }

  // Get phase color
  Color _getPhaseColor(PomodoroPhase phase) {
    switch (phase) {
      case PomodoroPhase.focus:
        return Colors.red;
      case PomodoroPhase.shortBreak:
        return Colors.green;
      case PomodoroPhase.longBreak:
        return Colors.blue;
    }
  }

  // Phase selector buttons
  Widget _buildPhaseSelector(PomodoroService pomodoroService) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPhaseButton(
          pomodoroService,
          PomodoroPhase.focus,
          '25:00',
        ),
        const SizedBox(width: 16),
        _buildPhaseButton(
          pomodoroService,
          PomodoroPhase.shortBreak,
          '05:00',
        ),
        const SizedBox(width: 16),
        _buildPhaseButton(
          pomodoroService,
          PomodoroPhase.longBreak,
          '15:00',
        ),
      ],
    );
  }

  Widget _buildPhaseButton(
      PomodoroService pomodoroService,
      PomodoroPhase phase,
      String time,
      ) {
    final isSelected = pomodoroService.currentPhase == phase;
    final color = _getPhaseColor(phase);
    final phaseName = _getPhaseName(phase).split(' ').first;

    return GestureDetector(
      onTap: pomodoroService.isRunning
          ? null
          : () => pomodoroService.setPhase(phase),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(
              phaseName,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Task selector dropdown
  Widget _buildTaskSelector(
      BuildContext context,
      TaskService taskService,
      PomodoroService pomodoroService,
      ) {
    final incompleteTasks = taskService.incompleteTasks;
    final currentTask = pomodoroService.currentTaskId != null
        ? taskService.getTaskById(pomodoroService.currentTaskId!)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Working on:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              if (currentTask != null) ...[
                Icon(
                  currentTask.categoryIcon,
                  color: currentTask.priorityColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentTask.title,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        currentTask.priorityText,
                        style: TextStyle(
                          fontSize: 12,
                          color: currentTask.priorityColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const Icon(Icons.task, color: Colors.grey),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Select a task to track time',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
              PopupMenuButton<String>(
                onSelected: (taskId) {
                  pomodoroService.setTask(taskId);
                },
                itemBuilder: (context) {
                  return [
                    const PopupMenuItem<String>(
                      value: null,
                      child: Text('No task selected'),
                    ),
                    ...incompleteTasks.map((task) {
                      return PopupMenuItem<String>(
                        value: task.id,
                        child: Row(
                          children: [
                            Icon(
                              task.categoryIcon,
                              color: task.priorityColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                task.title.length > 20
                                    ? '${task.title.substring(0, 20)}...'
                                    : task.title,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ];
                },
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.arrow_drop_down),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Control buttons
  Widget _buildControls(PomodoroService pomodoroService) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Reset button
        ElevatedButton(
          onPressed: pomodoroService.isRunning
              ? null
              : () => pomodoroService.resetTimer(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade200,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.refresh),
              SizedBox(width: 8),
              Text('Reset'),
            ],
          ),
        ),

        const SizedBox(width: 20),

        // Start/Pause button
        ElevatedButton(
          onPressed: () {
            if (pomodoroService.isRunning) {
              pomodoroService.pauseTimer();
            } else {
              pomodoroService.startTimer();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _getPhaseColor(pomodoroService.currentPhase),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            children: [
              Icon(pomodoroService.isRunning ? Icons.pause : Icons.play_arrow),
              const SizedBox(width: 8),
              Text(pomodoroService.isRunning ? 'Pause' : 'Start'),
            ],
          ),
        ),
      ],
    );
  }

  // Stats display
  Widget _buildStats(PomodoroService pomodoroService) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Completed',
            pomodoroService.completedSessions.toString(),
            Icons.check_circle,
            Colors.green,
          ),
          _buildStatItem(
            'Current Phase',
            _getPhaseName(pomodoroService.currentPhase),
            Icons.timer,
            _getPhaseColor(pomodoroService.currentPhase),
          ),
          _buildStatItem(
            'Status',
            pomodoroService.isRunning ? 'Running' : 'Paused',
            pomodoroService.isRunning ? Icons.play_arrow : Icons.pause,
            pomodoroService.isRunning ? Colors.green : Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}