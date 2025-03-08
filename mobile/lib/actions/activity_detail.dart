import 'package:flutter/material.dart';
import 'activity_model.dart';

class ActivityDetailView extends StatelessWidget {
  final ActivityModel activity;

  const ActivityDetailView({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    // Colors
    final Color primaryColor = const Color(0xFF6C63FF);
    final Color bgColor = const Color(0xFFF7F9FC);
    final Color cardBgColor = Colors.white;
    final Color textPrimaryColor = const Color(0xFF2A2D3E);
    final Color textSecondaryColor = const Color(0xFF7C7C7C);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "${activity.type} Details",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2A2D3E)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero header with icon and type
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
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: activity.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      activity.icon,
                      color: activity.color,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.type,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: activity.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            activity.durationText,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: activity.color,
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

            // Date and Time Info Card
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
                    "Date & Time",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          icon: Icons.calendar_today,
                          title: "Date",
                          value: activity.date,
                          color: Colors.blue,
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          icon: Icons.access_time,
                          title: "Start Time",
                          value: activity.startTime,
                          color: Colors.green,
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          icon: Icons.timer_off,
                          title: "End Time",
                          value: activity.endTime,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Description Card
            Container(
              width: double.infinity,
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
                    "Description",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    activity.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: textSecondaryColor,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Recommendations based on activity type
            Container(
              width: double.infinity,
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
                    "Tips & Insights",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ..._getTipsForActivity(activity.type).map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: primaryColor,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            tip,
                            style: TextStyle(
                              fontSize: 14,
                              color: textSecondaryColor,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
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
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF7C7C7C),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2A2D3E),
          ),
        ),
      ],
    );
  }

  List<String> _getTipsForActivity(String type) {
    switch (type.toLowerCase()) {
      case 'sleeping':
        return [
          "Consistent sleep schedules help babies develop healthy sleep patterns.",
          "The recommended sleep duration for infants is 12-16 hours per day.",
          "A dark, quiet environment promotes better sleep quality.",
          "Consider using white noise machines to help maintain sleep.",
        ];
      case 'playing':
        return [
          "Playtime helps develop motor skills and cognitive abilities.",
          "Interactive toys that make sounds or have different textures are great for sensory development.",
          "Tummy time is essential for strengthening neck and shoulder muscles.",
          "Limit screen time for babies under 18 months.",
        ];
      case 'studying':
        return [
          "Reading to babies, even from a young age, promotes language development.",
          "Simple puzzles and shape sorters help develop problem-solving skills.",
          "Singing songs and rhymes helps with language acquisition.",
          "Short, focused learning sessions are more effective than long ones.",
        ];
      case 'feeding':
        return [
          "Babies typically feed every 2-3 hours in the first few months.",
          "Watch for hunger cues like lip smacking, rooting, or putting hands to mouth.",
          "Burp baby mid-feed and after feeding to reduce gas and discomfort.",
          "Track feeding times to establish patterns and ensure adequate nutrition.",
        ];
      default:
        return [
          "Regular routines help babies feel secure and develop healthily.",
          "Track patterns to better understand your baby's unique needs.",
          "Consult with your pediatrician if you notice significant changes in behavior.",
          "Each baby develops at their own pace - focus on progress, not comparisons.",
        ];
    }
  }
}