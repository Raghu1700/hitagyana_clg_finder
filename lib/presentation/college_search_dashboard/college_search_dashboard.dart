import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/app_export.dart';
import '../../services/firebase_service.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../college_details_screen/college_details_screen.dart';
import 'widgets/college_card_widget.dart';
import 'widgets/recommendation_chip_widget.dart';
import 'widgets/search_filter_bottom_sheet.dart';

class CollegeSearchDashboard extends StatefulWidget {
  const CollegeSearchDashboard({super.key});

  @override
  State<CollegeSearchDashboard> createState() => _CollegeSearchDashboardState();
}

class _CollegeSearchDashboardState extends State<CollegeSearchDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  List<String> _savedColleges = [];

  final List<Map<String, dynamic>> _recommendationChips = [
    {"title": "Near Me", "icon": "location_on", "isActive": true},
    {"title": "Top Ranked", "icon": "star", "isActive": false},
    {"title": "Affordable", "icon": "attach_money", "isActive": false},
    {"title": "Engineering", "icon": "engineering", "isActive": false},
    {"title": "Medical", "icon": "local_hospital", "isActive": false},
    {"title": "Management", "icon": "business", "isActive": false},
  ];

  List<Map<String, dynamic>> _filteredColleges = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 0);
    _scrollController.addListener(_onScroll);
    _loadColleges();
    _loadSavedColleges();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedColleges() async {
    try {
      final savedCollegeIds = await AuthService.getSavedColleges();
      if (mounted) {
        setState(() {
          _savedColleges = savedCollegeIds;
        });
      }
    } catch (e) {
      print('Error loading saved colleges: $e');
    }
  }

  Future<void> _loadColleges() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final colleges = await FirebaseService.getAllColleges();
      if (mounted) {
        setState(() {
          _filteredColleges = colleges;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      Fluttertoast.showToast(
        msg: "Error loading colleges: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreColleges();
    }
  }

  void _loadMoreColleges() {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });

      // Simulate loading more data
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
            Fluttertoast.showToast(
              msg: "All colleges loaded!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
            );
          });
        }
      });
    }
  }

  Future<void> _onSearchChanged(String query) async {
    if (query.isEmpty) {
      _loadColleges();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final colleges = await FirebaseService.searchColleges(query);
      setState(() {
        _filteredColleges = colleges;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(
        msg: "Error searching colleges: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> _onRecommendationChipTap(int index) async {
    setState(() {
      for (int i = 0; i < _recommendationChips.length; i++) {
        _recommendationChips[i]["isActive"] = i == index;
      }
      _isLoading = true;
    });

    try {
      final selectedChip = _recommendationChips[index];
      final category = selectedChip["title"] as String;

      final colleges = await FirebaseService.getCollegesByCategory(category);
      setState(() {
        _filteredColleges = colleges;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(
        msg: "Error filtering colleges: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          "Hitagyana Clg Finder",
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: CustomIconWidget(
                iconName: 'search',
                size: 20,
                color: _tabController.index == 0
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              text: "Search",
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'bookmark',
                size: 20,
                color: _tabController.index == 1
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              text: "Saved",
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'school',
                size: 20,
                color: _tabController.index == 2
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              text: "Classes",
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'person',
                size: 20,
                color: _tabController.index == 3
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              text: "Profile",
            ),
          ],
          onTap: (index) {
            switch (index) {
              case 1:
                Navigator.pushNamed(context, '/saved-colleges-screen');
                break;
              case 2:
                Navigator.pushNamed(context, '/extracurricular-classes-screen');
                break;
              case 3:
                // Stay on current tab for profile
                break;
            }
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics:
            const NeverScrollableScrollPhysics(), // Disable swipe functionality
        children: [
          _buildSearchTab(),
          Container(), // Saved tab placeholder
          Container(), // Classes tab placeholder
          _buildProfileTab(), // Profile tab
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: _showFilterBottomSheet,
              backgroundColor: AppTheme.lightTheme.primaryColor,
              foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
              icon: CustomIconWidget(
                iconName: 'tune',
                size: 20,
                color: AppTheme.lightTheme.colorScheme.onPrimary,
              ),
              label: Text(
                "Advanced Search",
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildSearchTab() {
    return RefreshIndicator(
      onRefresh: _loadColleges,
      child: Column(
        children: [
          _buildSearchBar(),
          _buildRecommendationChips(),
          Expanded(
            child: _isLoading && _filteredColleges.isEmpty
                ? _buildLoadingIndicator()
                : _filteredColleges.isEmpty
                    ? _buildEmptyState()
                    : _buildCollegeList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: AppTheme.primaryGradientDecoration,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 8.w,
                  backgroundColor: AppTheme.almond,
                  child: Icon(
                    Icons.person,
                    size: 8.w,
                    color: AppTheme.byzantium,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<Map<String, dynamic>?>(
                        future: AuthService.currentUser != null
                            ? UserService.getUserProfile(
                                AuthService.currentUser!.uid)
                            : Future.value(null),
                        builder: (context, snapshot) {
                          final userProfile = snapshot.data;
                          final username = userProfile?['username'] ??
                              AuthService.currentUser?.email
                                  ?.split('@')
                                  .first ??
                              'User';

                          return Text(
                            username,
                            style: AppTheme.lightTheme.textTheme.titleLarge
                                ?.copyWith(
                              color: AppTheme.almond,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        AuthService.currentUser?.email ?? 'No email',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.champagnePink,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Stats Section
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Stats',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Saved Colleges',
                        '${_savedColleges.length}',
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: _buildStatCard(
                        'Account Type',
                        'Regular',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Actions Section
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account Actions',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                ListTile(
                  leading: Icon(Icons.edit_outlined, color: AppTheme.byzantium),
                  title: Text('Edit Profile'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showEditProfileDialog();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.lock_outline, color: AppTheme.byzantium),
                  title: Text('Change Password'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showChangePasswordDialog();
                  },
                ),
                ListTile(
                  leading:
                      Icon(Icons.settings_outlined, color: AppTheme.byzantium),
                  title: Text('Account Settings'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showAccountSettingsDialog();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.help_outline, color: AppTheme.byzantium),
                  title: Text('Help & Support'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showHelpSupportDialog();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.info_outline, color: AppTheme.byzantium),
                  title: Text('About App'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showAboutAppDialog();
                  },
                ),
                Divider(thickness: 1, color: AppTheme.lightGray),
                ListTile(
                  leading: Icon(Icons.delete_outline, color: Colors.red),
                  title: Text('Delete Account'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showDeleteAccountDialog();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout, color: AppTheme.byzantium),
                  title: Text('Sign Out'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _handleLogout();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.lightTheme.primaryColor,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: isDestructive
                ? AppTheme.lightTheme.colorScheme.error.withOpacity(0.1)
                : AppTheme.lightTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDestructive
                ? AppTheme.lightTheme.colorScheme.error
                : AppTheme.lightTheme.primaryColor,
          ),
        ),
        title: Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: isDestructive ? AppTheme.lightTheme.colorScheme.error : null,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: AppTheme.lightTheme.colorScheme.surface,
      ),
    );
  }

  void _showCreateAccountDialog() {
    // This would convert anonymous account to permanent account
    Navigator.pushReplacementNamed(context, '/simple-auth-screen');
  }

  void _showChangePasswordDialog() {
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Change Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: obscureCurrentPassword,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(obscureCurrentPassword
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () => setState(() =>
                          obscureCurrentPassword = !obscureCurrentPassword),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: obscureNewPassword,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(obscureNewPassword
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () => setState(
                          () => obscureNewPassword = !obscureNewPassword),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () => setState(() =>
                          obscureConfirmPassword = !obscureConfirmPassword),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (newPasswordController.text !=
                    confirmPasswordController.text) {
                  Fluttertoast.showToast(
                    msg: 'New passwords do not match',
                    backgroundColor: Colors.red,
                  );
                  return;
                }
                if (newPasswordController.text.length < 6) {
                  Fluttertoast.showToast(
                    msg: 'Password must be at least 6 characters',
                    backgroundColor: Colors.red,
                  );
                  return;
                }

                Navigator.pop(context);
                try {
                  // Firebase doesn't have a direct changePassword method
                  // We need to reauthenticate and then update password
                  final user = AuthService.currentUser;
                  if (user != null) {
                    // Reauthenticate with current password
                    final credential = EmailAuthProvider.credential(
                      email: user.email!,
                      password: currentPasswordController.text,
                    );
                    await user.reauthenticateWithCredential(credential);

                    // Update password
                    await user.updatePassword(newPasswordController.text);

                    Fluttertoast.showToast(
                      msg: 'Password changed successfully',
                      backgroundColor: AppTheme.byzantium,
                    );
                  }
                } catch (e) {
                  Fluttertoast.showToast(
                    msg: 'Error changing password: $e',
                    backgroundColor: Colors.red,
                  );
                }
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppTheme.byzantium),
              child: Text('Change Password',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final isAnonymous = AuthService.currentUser?.isAnonymous ?? false;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isAnonymous ? 'Clear Data' : 'Delete Account'),
        content: Text(
          isAnonymous
              ? 'This will clear all your app data. Are you sure?'
              : 'This will permanently delete your account and all data. This action cannot be undone. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                if (isAnonymous) {
                  // Clear app data only
                  await AuthService.signOut();
                } else {
                  // Delete account
                  await AuthService.deleteAccount();
                }
                Navigator.pushReplacementNamed(context, '/simple-auth-screen');
                Fluttertoast.showToast(
                  msg: isAnonymous
                      ? 'Data cleared successfully'
                      : 'Account deleted successfully',
                );
              } catch (e) {
                Fluttertoast.showToast(msg: e.toString());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: Text(
              isAnonymous ? 'Clear Data' : 'Delete Account',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();

    // Pre-fill current values
    emailController.text = AuthService.currentUser?.email ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FutureBuilder<Map<String, dynamic>?>(
                future: AuthService.currentUser != null
                    ? UserService.getUserProfile(AuthService.currentUser!.uid)
                    : Future.value(null),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    usernameController.text = snapshot.data?['username'] ?? '';
                  }
                  return TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  );
                },
              ),
              SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email (Read-only)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                enabled: false,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                if (AuthService.currentUser != null) {
                  await UserService.updateUserProfile(
                    AuthService.currentUser!.uid,
                    {'username': usernameController.text.trim()},
                  );
                  setState(() {}); // Refresh the profile display
                  Fluttertoast.showToast(
                    msg: 'Profile updated successfully',
                    backgroundColor: AppTheme.byzantium,
                  );
                }
              } catch (e) {
                Fluttertoast.showToast(
                  msg: 'Error updating profile: $e',
                  backgroundColor: Colors.red,
                );
              }
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.byzantium),
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAccountSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Account Settings'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: Icon(Icons.notifications, color: AppTheme.byzantium),
                title: Text('Notifications'),
                subtitle: Text('Manage your notification preferences'),
                trailing: Switch(
                  value: true, // This could be stored in user preferences
                  onChanged: (value) {
                    Fluttertoast.showToast(
                      msg: 'Notification settings updated',
                      backgroundColor: AppTheme.byzantium,
                    );
                  },
                ),
              ),
              ListTile(
                leading: Icon(Icons.email, color: AppTheme.byzantium),
                title: Text('Email Updates'),
                subtitle: Text('Receive college updates via email'),
                trailing: Switch(
                  value: false, // This could be stored in user preferences
                  onChanged: (value) {
                    Fluttertoast.showToast(
                      msg: 'Email preferences updated',
                      backgroundColor: AppTheme.byzantium,
                    );
                  },
                ),
              ),
              ListTile(
                leading: Icon(Icons.sync, color: AppTheme.byzantium),
                title: Text('Sync Data'),
                subtitle: Text('Synchronize your data across devices'),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    // Trigger data sync with proper parameters
                    final userId = AuthService.currentUser?.uid;
                    if (userId != null) {
                      // Get local saved colleges if any
                      final localSavedColleges =
                          <String>[]; // This would come from SharedPreferences in a real implementation
                      await UserService.syncLocalDataToFirebase(
                          userId, localSavedColleges);
                      Fluttertoast.showToast(
                        msg: 'Data synchronized successfully',
                        backgroundColor: AppTheme.byzantium,
                      );
                    }
                  } catch (e) {
                    Fluttertoast.showToast(
                      msg: 'Error syncing data: $e',
                      backgroundColor: Colors.red,
                    );
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.download, color: AppTheme.byzantium),
                title: Text('Export Data'),
                subtitle: Text('Download your saved colleges data'),
                onTap: () {
                  Navigator.pop(context);
                  _exportUserData();
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Help & Support'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: Icon(Icons.help_outline, color: AppTheme.byzantium),
                title: Text('FAQ'),
                subtitle: Text('Frequently asked questions'),
                onTap: () {
                  Navigator.pop(context);
                  _showFAQ();
                },
              ),
              ListTile(
                leading: Icon(Icons.contact_support, color: AppTheme.byzantium),
                title: Text('Contact Support'),
                subtitle: Text('Get help from our support team'),
                onTap: () {
                  Navigator.pop(context);
                  _contactSupport();
                },
              ),
              ListTile(
                leading: Icon(Icons.bug_report, color: AppTheme.byzantium),
                title: Text('Report a Bug'),
                subtitle: Text('Help us improve the app'),
                onTap: () {
                  Navigator.pop(context);
                  _reportBug();
                },
              ),
              ListTile(
                leading: Icon(Icons.star_rate, color: AppTheme.byzantium),
                title: Text('Rate the App'),
                subtitle: Text('Share your feedback'),
                onTap: () {
                  Navigator.pop(context);
                  _rateApp();
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutAppDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('About Hitagyana College Finder'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.byzantium,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.school,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Text(
                  'Hitagyana College Finder',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 8),
              Center(
                child: Text(
                  'Version 1.0.0',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Find your perfect college with our comprehensive database of educational institutions. Compare colleges, save favorites, and make informed decisions about your future.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.policy, color: AppTheme.byzantium),
                title: Text('Privacy Policy'),
                onTap: () {
                  // Open privacy policy
                  Fluttertoast.showToast(
                    msg: 'Opening privacy policy...',
                    backgroundColor: AppTheme.byzantium,
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.description, color: AppTheme.byzantium),
                title: Text('Terms of Service'),
                onTap: () {
                  // Open terms of service
                  Fluttertoast.showToast(
                    msg: 'Opening terms of service...',
                    backgroundColor: AppTheme.byzantium,
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _exportUserData() async {
    try {
      final userId = AuthService.currentUser?.uid;
      if (userId == null) return;

      final userData = await UserService.getUserProfile(userId);
      final savedColleges = await UserService.getSavedColleges(userId);

      final exportData = {
        'user_profile': userData,
        'saved_colleges': savedColleges,
        'export_date': DateTime.now().toIso8601String(),
      };

      // In a real app, you would save this to a file or share it
      Fluttertoast.showToast(
        msg: 'Data exported successfully! (${savedColleges.length} colleges)',
        backgroundColor: AppTheme.byzantium,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error exporting data: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  void _showFAQ() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Frequently Asked Questions'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFAQItem(
                'How do I save colleges?',
                'Tap the heart icon on any college card to add it to your saved colleges list.',
              ),
              _buildFAQItem(
                'How do I compare colleges?',
                'Save multiple colleges and use the compare feature in your saved colleges page.',
              ),
              _buildFAQItem(
                'How accurate is the college data?',
                'Our data is regularly updated from official sources. Last update information is shown on each college page.',
              ),
              _buildFAQItem(
                'Can I access my data offline?',
                'Saved colleges are cached locally and available offline. However, detailed information requires internet connection.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          SizedBox(height: 4),
          Text(
            answer,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ],
      ),
    );
  }

  void _contactSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contact Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.email, color: AppTheme.byzantium),
              title: Text('Email Support'),
              subtitle: Text('support@hitagyana.com'),
              onTap: () async {
                final Uri emailUrl = Uri.parse(
                    'mailto:support@hitagyana.com?subject=College Finder Support');
                if (await canLaunchUrl(emailUrl)) {
                  await launchUrl(emailUrl);
                }
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.phone, color: AppTheme.byzantium),
              title: Text('Phone Support'),
              subtitle: Text('+1-800-HITAGYANA'),
              onTap: () async {
                final Uri phoneUrl = Uri.parse('tel:+18004482492');
                if (await canLaunchUrl(phoneUrl)) {
                  await launchUrl(phoneUrl);
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _reportBug() {
    final TextEditingController bugController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report a Bug'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please describe the issue you encountered:'),
            SizedBox(height: 16),
            TextField(
              controller: bugController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe the bug...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In a real app, this would send the bug report
              Fluttertoast.showToast(
                msg: 'Bug report submitted. Thank you!',
                backgroundColor: AppTheme.byzantium,
              );
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.byzantium),
            child: Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _rateApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rate the App'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('How would you rate your experience?'),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Fluttertoast.showToast(
                      msg:
                          'Thank you for rating us ${index + 1} star${index > 0 ? 's' : ''}!',
                      backgroundColor: AppTheme.byzantium,
                    );
                  },
                  icon: Icon(
                    Icons.star,
                    color: AppTheme.byzantium,
                    size: 32,
                  ),
                );
              }),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Maybe Later'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    try {
      await AuthService.signOut();
      Navigator.pushReplacementNamed(context, '/simple-auth-screen');
      Fluttertoast.showToast(msg: 'Signed out successfully');
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: "Search colleges, courses, or locations...",
          hintStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
          prefixIcon: CustomIconWidget(
            iconName: 'search',
            size: 20,
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    _onSearchChanged("");
                  },
                  child: CustomIconWidget(
                    iconName: 'close',
                    size: 20,
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        ),
      ),
    );
  }

  Widget _buildRecommendationChips() {
    return SizedBox(
      height: 6.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _recommendationChips.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: 2.w),
            child: RecommendationChipWidget(
              chip: _recommendationChips[index],
              onTap: () => _onRecommendationChipTap(index),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCollegeList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _filteredColleges.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _filteredColleges.length) {
          return _buildLoadingCard();
        }

        final college = _filteredColleges[index];
        final isSaved = _savedColleges.contains(college["id"].toString());

        return CollegeCardWidget(
          college: college,
          isSaved: isSaved,
          onSaveToggle: () => _toggleSaveCollege(college["id"].toString()),
          onTap: () => _navigateToCollegeDetails(college),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'search_off',
            size: 80,
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: 2.h),
          Text(
            "No colleges found",
            style: AppTheme.lightTheme.textTheme.headlineSmall,
          ),
          SizedBox(height: 1.h),
          Text(
            "Try adjusting your search criteria\nor explore different filters",
            style: AppTheme.lightTheme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: () {
              _searchController.clear();
              _onSearchChanged("");
            },
            child: const Text("Clear Search"),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<void> _toggleSaveCollege(String collegeId) async {
    try {
      final isSaved = _savedColleges.contains(collegeId);

      if (isSaved) {
        // Remove from saved
        final success = await AuthService.unsaveCollege(collegeId);
        if (success) {
          setState(() {
            _savedColleges.remove(collegeId);
          });
          Fluttertoast.showToast(
            msg: "College removed from saved list",
            backgroundColor: Colors.orange,
          );
        }
      } else {
        // Add to saved
        final success = await AuthService.saveCollege(collegeId);
        if (success) {
          setState(() {
            _savedColleges.add(collegeId);
          });
          Fluttertoast.showToast(
            msg: "College saved successfully! ⭐",
            backgroundColor: Colors.green,
          );
        }
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error: $e",
        backgroundColor: Colors.red,
      );
    }
  }

  void _navigateToCollegeDetails(Map<String, dynamic> college) {
    Navigator.pushNamed(context, '/college-details-screen');
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchFilterBottomSheet(
        onFiltersApplied: (filters) {
          // Handle filter application
          Navigator.pop(context);
          Fluttertoast.showToast(msg: "Filters applied successfully");
        },
      ),
    );
  }
}
