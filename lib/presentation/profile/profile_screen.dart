import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/app_export.dart';
import '../../data/services/firebase_auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuthService.instance.currentUser;
    if (user != null) {
      setState(() {
        _emailController.text = user.email ?? '';
        _usernameController.text = user.displayName ?? '';
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuthService.instance.updateProfile(
        username: _usernameController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully'),
            backgroundColor: AppTheme.getSuccessColor(true),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuthService.instance.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sign out: ${e.toString()}'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(6.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildProfileHeader(),
            SizedBox(height: 4.h),
            _buildProfileForm(),
            SizedBox(height: 4.h),
            _buildPreferences(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final user = FirebaseAuthService.instance.currentUser;
    return Column(
      children: [
        Hero(
          tag: 'profile_image',
          child: Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.lightTheme.colorScheme.primaryContainer,
              image: user?.photoURL != null
                  ? DecorationImage(
                      image: NetworkImage(user!.photoURL!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: user?.photoURL == null
                ? Icon(
                    Icons.person,
                    size: 15.w,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  )
                : null,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          user?.displayName ?? 'User',
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          user?.email ?? '',
          style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a username';
              }
              return null;
            },
          ),
          SizedBox(height: 2.h),
          TextFormField(
            controller: _emailController,
            enabled: false,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          SizedBox(height: 3.h),
          SizedBox(
            height: 6.h,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _updateProfile,
              child: _isLoading
                  ? SizedBox(
                      height: 3.h,
                      width: 3.h,
                      child: CircularProgressIndicator(
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Update Profile'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Preferences',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 2.h),
        _buildPreferenceCard(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          subtitle: 'Manage your notification preferences',
          onTap: () {
            // TODO: Implement notifications settings
          },
        ),
        _buildPreferenceCard(
          icon: Icons.lock_outline,
          title: 'Privacy',
          subtitle: 'Manage your privacy settings',
          onTap: () {
            // TODO: Implement privacy settings
          },
        ),
        _buildPreferenceCard(
          icon: Icons.help_outline,
          title: 'Help & Support',
          subtitle: 'Get help or contact support',
          onTap: () {
            // TODO: Implement help & support
          },
        ),
        _buildPreferenceCard(
          icon: Icons.info_outline,
          title: 'About',
          subtitle: 'Learn more about the app',
          onTap: () {
            // TODO: Implement about screen
          },
        ),
      ],
    );
  }

  Widget _buildPreferenceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppTheme.lightTheme.colorScheme.primary,
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Icon(
          Icons.chevron_right,
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        ),
        onTap: onTap,
      ),
    );
  }
} 