import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    
    try {
      final user = AuthService.currentUser;
      if (user != null) {
        // Add timeout to prevent infinite loading
        final profile = await UserService.getUserProfile(user.uid)
            .timeout(const Duration(seconds: 10));
        
        if (mounted) {
          setState(() {
            _userProfile = profile;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      print('Error loading user profile: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
      // Show error toast
      Fluttertoast.showToast(
        msg: "Profile loaded with limited info",
        backgroundColor: AppTheme.byzantium,
      );
    }
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await AuthService.signOut();
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/simple-auth-screen',
            (route) => false,
          );
        }
      } catch (e) {
        print('Error signing out: $e');
        Fluttertoast.showToast(
          msg: "Error signing out. Please try again.",
          backgroundColor: Colors.red,
        );
      }
    }
  }

  void _showEditProfileDialog() {
    final user = AuthService.currentUser;
    final usernameController = TextEditingController(
      text: _userProfile?['username'] ?? user?.displayName ?? '',
    );
    final emailController = TextEditingController(text: user?.email ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit, color: AppTheme.tyrianPurple),
            SizedBox(width: 2.w),
            const Text('Edit Profile'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person, color: AppTheme.tyrianPurple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: emailController,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Email (Read-only)',
                prefixIcon: Icon(Icons.email, color: AppTheme.byzantium),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newUsername = usernameController.text.trim();
              if (newUsername.isNotEmpty && user != null) {
                await UserService.updateUserProfile(user.uid, {
                  'username': newUsername,
                });
                await _loadUserProfile();
                Navigator.pop(context);
                Fluttertoast.showToast(
                  msg: 'Profile updated successfully!',
                  backgroundColor: AppTheme.tyrianPurple,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.tyrianPurple,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.settings, color: AppTheme.tyrianPurple),
            SizedBox(width: 2.w),
            const Text('Settings'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.notifications_outlined, color: AppTheme.tyrianPurple),
                title: const Text('Notifications'),
                subtitle: const Text('Manage notification preferences'),
                trailing: Switch(
                  value: true,
                  activeColor: AppTheme.tyrianPurple,
                  onChanged: (value) {
                    Fluttertoast.showToast(
                      msg: 'Notifications ${value ? "enabled" : "disabled"}',
                      backgroundColor: AppTheme.byzantium,
                    );
                  },
                ),
              ),
              ListTile(
                leading: Icon(Icons.email_outlined, color: AppTheme.tyrianPurple),
                title: const Text('Email Updates'),
                subtitle: const Text('Receive email notifications'),
                trailing: Switch(
                  value: false,
                  activeColor: AppTheme.tyrianPurple,
                  onChanged: (value) {
                    Fluttertoast.showToast(
                      msg: 'Email updates ${value ? "enabled" : "disabled"}',
                      backgroundColor: AppTheme.byzantium,
                    );
                  },
                ),
              ),
              ListTile(
                leading: Icon(Icons.lock_outline, color: AppTheme.tyrianPurple),
                title: const Text('Change Password'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  Fluttertoast.showToast(
                    msg: 'Use "Forgot Password" on login screen to reset',
                    backgroundColor: AppTheme.tyrianPurple,
                    toastLength: Toast.LENGTH_LONG,
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help_outline, color: AppTheme.tyrianPurple),
            SizedBox(width: 2.w),
            const Text('Help & Support'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.email, color: AppTheme.tyrianPurple),
                title: const Text('Email Support'),
                subtitle: const Text('support@hitagyana.com'),
                onTap: () async {
                  final Uri emailUri = Uri(
                    scheme: 'mailto',
                    path: 'support@hitagyana.com',
                    query: 'subject=App Support Request',
                  );
                  if (await canLaunchUrl(emailUri)) {
                    await launchUrl(emailUri);
                  } else {
                    Fluttertoast.showToast(
                      msg: 'Could not open email app',
                      backgroundColor: Colors.red,
                    );
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.phone, color: AppTheme.tyrianPurple),
                title: const Text('Call Us'),
                subtitle: const Text('+91 1800-XXX-XXXX'),
                onTap: () async {
                  final Uri phoneUri = Uri(scheme: 'tel', path: '+911800XXXXXXX');
                  if (await canLaunchUrl(phoneUri)) {
                    await launchUrl(phoneUri);
                  } else {
                    Fluttertoast.showToast(
                      msg: 'Could not open phone dialer',
                      backgroundColor: Colors.red,
                    );
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.chat_bubble_outline, color: AppTheme.tyrianPurple),
                title: const Text('WhatsApp Support'),
                subtitle: const Text('Chat with us'),
                onTap: () async {
                  final Uri whatsappUri = Uri.parse('https://wa.me/911800XXXXXXX');
                  if (await canLaunchUrl(whatsappUri)) {
                    await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
                  } else {
                    Fluttertoast.showToast(
                      msg: 'Could not open WhatsApp',
                      backgroundColor: Colors.red,
                    );
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.info_outline, color: AppTheme.tyrianPurple),
                title: const Text('App Version'),
                subtitle: const Text('v1.0.0'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    
    return Scaffold(
      backgroundColor: AppTheme.almond,
      appBar: AppBar(
        backgroundColor: AppTheme.pureWhite,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          "Profile",
          style: TextStyle(
            color: AppTheme.tyrianPurple,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  children: [
                    // Profile Header
                    Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: AppTheme.primaryGradientDecoration,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 8.w,
                            backgroundColor: AppTheme.pureWhite,
                            child: Icon(
                              Icons.person,
                              size: 10.w,
                              color: AppTheme.tyrianPurple,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _userProfile?['username']?.toString() ?? 
                                  user?.displayName ?? 
                                  user?.email?.split('@').first ?? 
                                  'User',
                                  style: TextStyle(
                                    color: AppTheme.pureWhite,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  user?.email ?? 'No email',
                                  style: TextStyle(
                                    color: AppTheme.pureWhite.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 4.h),
                    
                    // Profile Options
                    _buildProfileOption(
                      icon: Icons.person_outline,
                      title: 'Edit Profile',
                      subtitle: 'Update your personal information',
                      onTap: _showEditProfileDialog,
                    ),
                    
                    _buildProfileOption(
                      icon: Icons.bookmark_outline,
                      title: 'Saved Colleges',
                      subtitle: 'View your saved colleges',
                      onTap: () {
                        Fluttertoast.showToast(
                          msg: "Tap 'Saved' in the bottom navigation bar",
                          backgroundColor: AppTheme.tyrianPurple,
                          toastLength: Toast.LENGTH_LONG,
                        );
                      },
                    ),
                    
                    _buildProfileOption(
                      icon: Icons.school_outlined,
                      title: 'My Classes',
                      subtitle: 'View enrolled courses',
                      onTap: () {
                        Fluttertoast.showToast(
                          msg: "Tap 'My Classes' in the bottom navigation bar",
                          backgroundColor: AppTheme.tyrianPurple,
                          toastLength: Toast.LENGTH_LONG,
                        );
                      },
                    ),
                    
                    _buildProfileOption(
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      subtitle: 'App preferences and settings',
                      onTap: _showSettingsDialog,
                    ),
                    
                    _buildProfileOption(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      subtitle: 'Get help and contact support',
                      onTap: _showHelpDialog,
                    ),
                    
                    SizedBox(height: 4.h),
                    
                    // Sign Out Button
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      child: ElevatedButton(
                        onPressed: _signOut,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: AppTheme.pureWhite,
                          padding: EdgeInsets.symmetric(vertical: 3.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, size: 20),
                            SizedBox(width: 2.w),
                            Text(
                              'Sign Out',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Material(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.tyrianPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: AppTheme.tyrianPurple,
                    size: 24,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.tyrianPurple,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.byzantium.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.byzantium.withOpacity(0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

