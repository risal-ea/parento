import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'activity_model.dart';

class ActivityAnalytics extends StatelessWidget {
  final List<ActivityModel> activities;

  const ActivityAnalytics({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    // Colors
    final Color primaryColor = const Color(0xFF6C63FF);
    final Color secondaryColor = const Color(0xFF2A2D3E);
    final Color cardBgColor = Colors.white;
    final Color textPrimaryColor = const Color(0xFF2A2D3E);
    final Color textSecondaryColor = const Color(0xFF7C7C7C);

    // Activity type statistics
    final activityStats = _calculateActivityStats();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, primaryColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Activity Summary",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    icon: Icons.list_alt,
                    title: "Total Activities",
                    value: "${activities.length}",
                    color: Colors.white,
                  ),
                  _buildSummaryItem(
                    icon: Icons.calendar_today,
                    title: "Days Tracked",
                    value: "${_uniqueDays().length}",
                    color: Colors.white,
                  ),
                  _buildSummaryItem(
                    icon: Icons.timelapse,
                    title: "Total Hours",
                    value: "${_totalDurationHours().toStringAsFixed(1)}h",
                    color: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Activity Distribution Pie Chart
        if (activityStats.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Activity Distribution",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  height: 200,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: CustomPaint(
                          size: const Size(double.infinity, 200),
                          painter: PieChartPainter(activityStats),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: activityStats.entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: _getColorForType(entry.key),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        entry.key,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: textPrimaryColor,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      "${(entry.value * 100).toStringAsFixed(1)}%",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: textPrimaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 20),

        // Activity Durations Bar Chart
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Average Duration by Activity Type",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textPrimaryColor,
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 200,
                child: BarChart(
                  _calculateAverageDurations(),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Daily Activity Pattern
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Activity Patterns by Time of Day",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textPrimaryColor,
                ),
              ),
              const SizedBox(height: 15),
              _buildTimeOfDayPatterns(),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Insights and Recommendations
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Insights & Recommendations",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textPrimaryColor,
                ),
              ),
              const SizedBox(height: 15),
              ..._generateInsights().map((insight) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: primaryColor,
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          insight,
                          style: TextStyle(
                            fontSize: 14,
                            color: textSecondaryColor,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  // Calculate activity type distribution
  Map<String, double> _calculateActivityStats() {
    if (activities.isEmpty) return {};

    Map<String, int> counts = {};
    for (var activity in activities) {
      counts[activity.type] = (counts[activity.type] ?? 0) + 1;
    }

    Map<String, double> percentages = {};
    for (var entry in counts.entries) {
      percentages[entry.key] = entry.value / activities.length;
    }

    return percentages;
  }

  // Calculate average durations by activity type
  Map<String, Duration> _calculateAverageDurations() {
    Map<String, List<Duration>> durationsByType = {};

    for (var activity in activities) {
      if (!durationsByType.containsKey(activity.type)) {
        durationsByType[activity.type] = [];
      }
      durationsByType[activity.type]!.add(activity.duration);
    }

    Map<String, Duration> averages = {};
    for (var entry in durationsByType.entries) {
      int totalMinutes = entry.value.fold<int>(
          0, (sum, duration) => sum + duration.inMinutes
      );
      double avgMinutes = totalMinutes / entry.value.length;
      averages[entry.key] = Duration(minutes: avgMinutes.round());
    }

    return averages;
  }

  // Get unique days in the dataset
  Set<String> _uniqueDays() {
    return activities.map((a) => a.date).toSet();
  }

  // Calculate total duration in hours
  double _totalDurationHours() {
    int totalMinutes = activities.fold<int>(
        0, (sum, activity) => sum + activity.duration.inMinutes
    );
    return totalMinutes / 60;
  }

  // Get color for activity type
  Color _getColorForType(String type) {
    ActivityModel dummy = ActivityModel(
      type: type,
      date: "",
      description: "",
      startTime: "",
      endTime: "",
    );
    return dummy.color;
  }

  // Build time of day patterns visualization
  Widget _buildTimeOfDayPatterns() {
    Map<String, Map<String, int>> timeOfDayDistribution = {
      'Morning (6AM-12PM)': {},
      'Afternoon (12PM-6PM)': {},
      'Evening (6PM-10PM)': {},
      'Night (10PM-6AM)': {},
    };

    for (var activity in activities) {
      try {
        final startHour = int.parse(activity.startTime.split(":")[0]);
        String timeOfDay;

        if (startHour >= 6 && startHour < 12) {
          timeOfDay = 'Morning (6AM-12PM)';
        } else if (startHour >= 12 && startHour < 18) {
          timeOfDay = 'Afternoon (12PM-6PM)';
        } else if (startHour >= 18 && startHour < 22) {
          timeOfDay = 'Evening (6PM-10PM)';
        } else {
          timeOfDay = 'Night (10PM-6AM)';
        }

        timeOfDayDistribution[timeOfDay]![activity.type] =
            (timeOfDayDistribution[timeOfDay]![activity.type] ?? 0) + 1;
      } catch (e) {
        // Skip if there's an error parsing the time
        continue;
      }
    }

    return Column(
      children: timeOfDayDistribution.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2A2D3E),
                ),
              ),
              const SizedBox(height: 8),
              if (entry.value.isEmpty)
                const Text(
                  "No activities recorded during this time period",
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF7C7C7C),
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: entry.value.entries.map((activityEntry) {
                    final activityType = activityEntry.key;
                    final count = activityEntry.value;

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _getColorForType(activityType).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getColorForType(activityType).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            ActivityModel(
                              type: activityType,
                              date: "",
                              description: "",
                              startTime: "",
                              endTime: "",
                            ).icon,
                            color: _getColorForType(activityType),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            activityType,
                            style: TextStyle(
                              fontSize: 13,
                              color: _getColorForType(activityType),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getColorForType(activityType),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "$count",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Generate insights based on the data
  List<String> _generateInsights() {
    List<String> insights = [];

    if (activities.isEmpty) {
      return ["Start logging activities to see personalized insights and recommendations."];
    }

    // Most common activity
    final activityStats = _calculateActivityStats();
    if (activityStats.isNotEmpty) {
      final mostCommonActivity = activityStats.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      insights.add("${mostCommonActivity} is the most frequent activity, making up ${(activityStats[mostCommonActivity]! * 100).toStringAsFixed(1)}% of all logged activities.");
    }

    // Average durations
    final avgDurations = _calculateAverageDurations();
    if (avgDurations.isNotEmpty) {
      final longestActivity = avgDurations.entries
          .reduce((a, b) => a.value > b.value ? a : b);

      insights.add("On average, ${longestActivity.key} sessions are the longest at ${longestActivity.value.inMinutes} minutes per session.");
    }

    // Activity patterns
    try {
      int morningCount = 0;
      int eveningCount = 0;

      for (var activity in activities) {
        final startHour = int.parse(activity.startTime.split(":")[0]);
        if (startHour >= 6 && startHour < 12) {
          morningCount++;
        } else if (startHour >= 18 && startHour < 22) {
          eveningCount++;
        }
      }

      if (morningCount > eveningCount && morningCount > activities.length * 0.3) {
        insights.add("Most activities occur in the morning. Morning routines help establish healthy daily rhythms for babies.");
      } else if (eveningCount > morningCount && eveningCount > activities.length * 0.3) {
        insights.add("Evening appears to be the most active time period. Consider maintaining consistent evening routines to help prepare for sleep.");
      }
    } catch (e) {
      // Skip this insight if there's an error
    }

    // Sleeping insights
    final sleepingActivities = activities.where((a) => a.type.toLowerCase() == 'sleeping').toList();
    if (sleepingActivities.length >= 3) {
      double avgSleepMinutes = sleepingActivities.fold<int>(
          0, (sum, activity) => sum + activity.duration.inMinutes
      ) / sleepingActivities.length;

      if (avgSleepMinutes < 120) {
        insights.add("Average sleep session is ${avgSleepMinutes.round()} minutes. For babies, longer consolidated sleep periods may be beneficial for development.");
      } else {
        insights.add("Average sleep session is ${avgSleepMinutes.round()} minutes, which indicates good consolidated sleep periods.");
      }
    }

    // Generic insights
    insights.add("Consistent daily routines help babies develop healthy patterns and feel secure.");

    return insights;
  }
}

// Pie Chart Custom Painter
class PieChartPainter extends CustomPainter {
  final Map<String, double> data;

  PieChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    double startAngle = 0;

    data.forEach((key, value) {
      final sweepAngle = 2 * math.pi * value;

      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = _getColorForPie(key);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    });

    // Draw center circle (optional, for donut chart effect)
    canvas.drawCircle(
      center,
      radius * 0.5,
      Paint()..color = Colors.white,
    );
  }

  Color _getColorForPie(String type) {
    ActivityModel dummy = ActivityModel(
      type: type,
      date: "",
      description: "",
      startTime: "",
      endTime: "",
    );
    return dummy.color;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Bar Chart Widget
class BarChart extends StatelessWidget {
  final Map<String, Duration> data;

  const BarChart(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Y-axis labels
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("60m", style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                  Text("45m", style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                  Text("30m", style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                  Text("15m", style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                  Text("0m", style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                ],
              ),
              const SizedBox(width: 8),
              // Bars
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: sortedEntries.take(5).map((entry) {
                    final minutes = entry.value.inMinutes;
                    final barHeight = math.min(minutes / 60, 1.0) * 150; // Max 60 minutes for full height

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "${minutes}m",
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 30,
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: _getColorForBar(entry.key),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _getColorForBar(entry.key).withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // X-axis labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: sortedEntries.take(5).map((entry) {
            return Expanded(
              child: Center(
                child: Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getColorForBar(String type) {
    ActivityModel dummy = ActivityModel(
      type: type,
      date: "",
      description: "",
      startTime: "",
      endTime: "",
    );
    return dummy.color;
  }
}