import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/app_export.dart';

class ZoomMeetingSection extends StatelessWidget {
  final Map<String, dynamic> course;

  const ZoomMeetingSection({
    Key? key,
    required this.course,
  }) : super(key: key);

  void _joinZoomMeeting() async {
    try {
      final zoomLink = course['zoomMeetingLink']?.toString() ?? '';
      
      if (zoomLink.isEmpty) {
        Fluttertoast.showToast(
          msg: "Zoom meeting link not available",
          backgroundColor: Colors.orange,
        );
        return;
      }

      final Uri url = Uri.parse(zoomLink);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        Fluttertoast.showToast(
          msg: "Opening Zoom meeting...",
          backgroundColor: AppTheme.byzantium,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Could not open Zoom",
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error opening Zoom: $e",
        backgroundColor: Colors.red,
      );
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    Fluttertoast.showToast(
      msg: "$label copied to clipboard",
      backgroundColor: AppTheme.byzantium,
    );
  }

  String _getNextClassDate() {
    final recurringDays = course['recurringDays'] as List?;
    if (recurringDays == null || recurringDays.isEmpty) {
      return 'Check schedule';
    }

    final now = DateTime.now();
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    // Find the next class day
    for (int i = 0; i < 7; i++) {
      final checkDate = now.add(Duration(days: i));
      final checkWeekday = weekdays[checkDate.weekday - 1];
      
      if (recurringDays.contains(checkWeekday)) {
        if (i == 0) {
          return 'Today';
        } else if (i == 1) {
          return 'Tomorrow';
        } else {
          return checkWeekday;
        }
      }
    }
    
    return recurringDays[0].toString();
  }

  @override
  Widget build(BuildContext context) {
    final hasZoomInfo = course['zoomMeetingLink'] != null && 
                        course['zoomMeetingLink'].toString().isNotEmpty;

    if (!hasZoomInfo) {
      return SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Zoom Icon
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Color(0xFF2D8CFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.videocam,
                  color: Color(0xFF2D8CFF),
                  size: 24,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Zoom Meeting Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.tyrianPurple,
                      ),
                    ),
                    if (course['isRecurring'] == true)
                      Text(
                        'Recurring Class',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.byzantium,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Next Class Info
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule, color: Colors.green, size: 20),
                SizedBox(width: 2.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next Class: ${_getNextClassDate()}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      if (course['meetingTime'] != null)
                        Text(
                          '${course['meetingTime']} ${course['timezone'] ?? 'IST'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // Meeting ID
          if (course['zoomMeetingId'] != null)
            _buildInfoRow(
              icon: Icons.tag,
              label: 'Meeting ID',
              value: course['zoomMeetingId'].toString(),
              onCopy: () => _copyToClipboard(
                course['zoomMeetingId'].toString(),
                'Meeting ID',
              ),
            ),

          SizedBox(height: 1.5.h),

          // Password
          if (course['zoomPassword'] != null)
            _buildInfoRow(
              icon: Icons.lock,
              label: 'Password',
              value: course['zoomPassword'].toString(),
              onCopy: () => _copyToClipboard(
                course['zoomPassword'].toString(),
                'Password',
              ),
            ),

          SizedBox(height: 1.5.h),

          // Schedule
          if (course['recurringDays'] != null)
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Schedule',
              value: (course['recurringDays'] as List).join(', '),
              showCopy: false,
            ),

          SizedBox(height: 3.h),

          // Join Meeting Button
          Container(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton.icon(
              onPressed: _joinZoomMeeting,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2D8CFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              icon: Icon(Icons.video_call, color: Colors.white, size: 24),
              label: Text(
                'Join Zoom Meeting',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          SizedBox(height: 1.h),

          // Help Text
          Center(
            child: Text(
              'Make sure you have Zoom installed',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.byzantium.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onCopy,
    bool showCopy = true,
  }) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.byzantium.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.byzantium, size: 18),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.byzantium.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 0.3.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.tyrianPurple,
                  ),
                ),
              ],
            ),
          ),
          if (showCopy && onCopy != null)
            IconButton(
              onPressed: onCopy,
              icon: Icon(Icons.copy, size: 18),
              color: AppTheme.byzantium,
              tooltip: 'Copy',
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
