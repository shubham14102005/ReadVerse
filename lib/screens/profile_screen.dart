import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../providers/auth_provider.dart';
import '../providers/book_provider_fixed.dart';
import '../providers/user_profile_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/profile_stats_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(
              Icons.person,
              color: Colors.white,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              'Profile',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Icons.logout, color: Colors.white),
            ),
          ),
        ],
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF000000), // Pure black at top
                  themeProvider.currentGradient[0].withValues(alpha: 0.3), // Theme color with low opacity
                  const Color(0xFF0D1117), // Dark black-gray
                  themeProvider.currentGradient.length > 1
                      ? themeProvider.currentGradient[1].withValues(alpha: 0.2)
                      : themeProvider.currentGradient[0].withValues(alpha: 0.2),
                  const Color(0xFF000000), // Pure black at bottom
                ],
                stops: const [0.0, 0.3, 0.6, 0.8, 1.0],
              ),
            ),
            child: Consumer3<AuthProvider, BookProviderFixed, UserProfileProvider>(
              builder: (context, authProvider, bookProvider, userProfileProvider, child) {
                if (authProvider.isLoading || userProfileProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Profile Header
                      _buildProfileHeader(context, authProvider, userProfileProvider),
                      const SizedBox(height: 24),

                      // Profile Stats
                      ProfileStatsCard(books: bookProvider.books),
                      const SizedBox(height: 24),

                      // Reading Goals
                      _buildReadingGoalsSection(context, userProfileProvider),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _editProfile(context),
        backgroundColor: Theme.of(context).primaryColor,
        heroTag: "profile_edit_fab", // Unique hero tag to avoid conflicts
        child: const Icon(
          Icons.edit,
          color: Colors.white,
        ),
        tooltip: 'Edit Profile',
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, AuthProvider authProvider, UserProfileProvider userProfileProvider) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: themeProvider.currentGradient.length >= 2
                  ? [themeProvider.currentGradient[0], themeProvider.currentGradient[1]]
                  : [themeProvider.currentGradient[0], themeProvider.currentGradient[0].withValues(alpha: 0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: themeProvider.currentGradient[0].withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 45,
              backgroundColor: Colors.white,
              child: Text(
                _getUserInitial(authProvider.user),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        userProfileProvider.userProfile?.displayName ?? _getUserName(authProvider.user),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _editProfile(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  userProfileProvider.userProfile?.email ?? _getUserEmail(authProvider.user),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Member since ${_formatJoinDate(userProfileProvider.userProfile?.joinDate ?? authProvider.user?.metadata.creationTime)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
          ),
        );
      },
    );
  }


  Widget _buildReadingGoalsSection(BuildContext context, UserProfileProvider userProfileProvider) {
    return Consumer<BookProviderFixed>(
      builder: (context, bookProvider, child) {
        // Get real-time completed books count
        final completedCount = bookProvider.completedBooksCount;
        final goalCount = userProfileProvider.userProfile?.readingGoal ?? 12;
        final progressValue = goalCount > 0 ? (completedCount / goalCount).clamp(0.0, 1.0) : 0.0;
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.flag,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reading Goals ${DateTime.now().year}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).brightness == Brightness.dark 
                                      ? Colors.white 
                                      : Colors.grey[800],
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$completedCount of $goalCount books completed',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).brightness == Brightness.dark 
                                      ? Colors.grey[400] 
                                      : Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${(progressValue * 100).round()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progressValue,
                    minHeight: 8,
                    backgroundColor: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey[700] 
                        : Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      progressValue >= 1.0 ? Icons.celebration : Icons.trending_up,
                      color: progressValue >= 1.0 ? Colors.amber : Theme.of(context).primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        progressValue >= 1.0 
                            ? '🎉 Congratulations! You\'ve reached your reading goal!'
                            : completedCount > 0
                                ? 'Great progress! Keep reading to reach your goal.'
                                : 'Start reading to track your progress towards your goal!',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).brightness == Brightness.dark 
                                  ? Colors.grey[400] 
                                  : Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
          ),
        );
      },
    );
  }




  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
            ),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await Provider.of<AuthProvider>(context, listen: false).signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/auth');
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  String _formatJoinDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.month}/${date.year}';
  }

  String _getUserInitial(firebase_auth.User? user) {
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user.displayName!.substring(0, 1).toUpperCase();
    } else if (user?.email != null && user!.email!.isNotEmpty) {
      return user.email!.substring(0, 1).toUpperCase();
    }
    return 'U';
  }

  String _getUserName(firebase_auth.User? user) {
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user.displayName!;
    } else if (user?.email != null && user!.email!.isNotEmpty) {
      return user.email!.split('@')[0];
    }
    return 'User';
  }

  String _getUserEmail(firebase_auth.User? user) {
    if (user?.email != null && user!.email!.isNotEmpty) {
      return user.email!;
    }
    return 'user@example.com';
  }

  void _editProfile(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProfileProvider = Provider.of<UserProfileProvider>(context, listen: false);
    
    // Get current values from both providers
    final currentDisplayName = userProfileProvider.userProfile?.displayName ?? 
                              authProvider.user?.displayName ?? '';
    final currentEmail = userProfileProvider.userProfile?.email ?? 
                        authProvider.user?.email ?? '';
    
    final TextEditingController nameController = TextEditingController(
      text: currentDisplayName,
    );
    final TextEditingController emailController = TextEditingController(
      text: currentEmail,
    );
    final TextEditingController readingGoalController = TextEditingController(
      text: (userProfileProvider.userProfile?.readingGoal ?? 12).toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.edit, size: 24),
            SizedBox(width: 8),
            Text('Edit Profile'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                enabled: false, // Email cannot be changed easily
              ),
              const SizedBox(height: 16),
              TextField(
                controller: readingGoalController,
                decoration: const InputDecoration(
                  labelText: 'Reading Goal (books per year)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                try {
                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                  
                  // Update Firebase Auth profile
                  final authSuccess = await authProvider.updateProfile(nameController.text.trim());
                  
                  // Update UserProfile
                  await userProfileProvider.updateProfile(
                    displayName: nameController.text.trim(),
                    email: emailController.text.trim(),
                    readingGoal: int.tryParse(readingGoalController.text) ?? 12,
                  );
                  
                  if (context.mounted) {
                    // Hide loading indicator
                    Navigator.of(context).pop();
                    
                    if (authSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Profile updated successfully!'),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      Navigator.of(context).pop(); // Close edit dialog
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.error, color: Colors.white),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(authProvider.errorMessage ?? 'Failed to update profile'),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    // Hide loading indicator if still showing
                    Navigator.of(context).pop();
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.white),
                            const SizedBox(width: 8),
                            Expanded(child: Text('Error updating profile: $e')),
                          ],
                        ),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Display name cannot be empty'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }



}
