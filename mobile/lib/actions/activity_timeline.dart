import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'activity_model.dart';
import 'activity_detail.dart';

class ActivityTimeline extends StatelessWidget {
  final List activities;

  const ActivityTimeline({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    // Group activities by date
    final Map<String, List> groupedActivities = {};

    for (var activity in activities) {
      if (!groupedActivities.containsKey(activity.date)) {
        groupedActivities[activity.date] = [];
      }
      groupedActivities[activity.date]!.add(activity);
    }

    // Sort dates in descending order (newest first)
    final sortedDates = groupedActivities.keys.toList()
      ..sort((a, b) => DateTime.parse(b).compareTo(DateTime.parse(a)));

    // Colors
    final Color primaryColor = const Color(0xFF6C63FF);
    final Color textPrimaryColor = const Color(0xFF2A2D3E);
    final Color textSecondaryColor = const Color(0xFF7C7C7C);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final dateActivities = groupedActivities[date]!;

        // Sort activities by start time
        dateActivities.sort((a, b) => a.startTime.compareTo(b.startTime));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _formatDate(date),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: textSecondaryColor.withOpacity(0.3),
                      thickness: 1,
                      indent: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Timeline for this date
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dateActivities.length,
              itemBuilder: (context, activityIndex) {
                final activity = dateActivities[activityIndex];
                final isLast = activityIndex == dateActivities.length - 1;

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time column
                      SizedBox(
                        width: 60,
                        child: Text(
                          activity.startTime,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: textSecondaryColor,
                          ),
                        ),
                      ),

                      // Timeline indicator
                      Column(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: activity.color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: activity.color.withOpacity(0.3),
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Icon(
                              activity.icon,
                              size: 10,
                              color: Colors.white,
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: activity.color.withOpacity(0.3),
                              ),
                            ),
                        ],
                      ),

                      // Activity card
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(
                              left: 16, bottom: 16, right: 0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: activity.color.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ActivityDetailView(activity: activity),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          activity.type,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: textPrimaryColor,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color:
                                            activity.color.withOpacity(0.1),
                                            borderRadius:
                                            BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            activity.durationText,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: activity.color,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      activity.description,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: textSecondaryColor,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          "${activity.startTime} - ${activity.endTime}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: textSecondaryColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final yesterday = DateTime.now().subtract(const Duration(days: 1));

      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        return "Today";
      } else if (date.year == yesterday.year &&
          date.month == yesterday.month &&
          date.day == yesterday.day) {
        return "Yesterday";
      } else {
        return "${date.day}/${date.month}/${date.year}";
      }
    } catch (e) {
      return dateStr;
    }
  }
}