import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_service.dart';
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
        final profile = await UserService.getUserProfile(user.uid);
        if (mounted) {
          setState(() {
            _userProfile = profile;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user profile: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signOut() async {
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
    }
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
                                  user?.displayName ?? 'User',
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
                      onTap: () {
                        // TODO: Implement edit profile
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Edit Profile coming soon!')),
                        );
                      },
                    ),
                    
                    _buildProfileOption(
                      icon: Icons.bookmark_outline,
                      title: 'Saved Colleges',
                      subtitle: 'View your saved colleges',
                      onTap: () {
                        // Navigate to saved colleges (tab 1)
                        // This will be handled by the main navigation
                      },
                    ),
                    
                    _buildProfileOption(
                      icon: Icons.school_outlined,
                      title: 'My Classes',
                      subtitle: 'View enrolled courses',
                      onTap: () {
                        // Navigate to enrolled classes (tab 4)
                        // This will be handled by the main navigation
                      },
                    ),
                    
                    _buildProfileOption(
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      subtitle: 'App preferences and settings',
                      onTap: () {
                        // TODO: Implement settings
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Settings coming soon!')),
                        );
                      },
                    ),
                    
                    _buildProfileOption(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      subtitle: 'Get help and contact support',
                      onTap: () {
                        // TODO: Implement help
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Help & Support coming soon!')),
                        );
                      },
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

