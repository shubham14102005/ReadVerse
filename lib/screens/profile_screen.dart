import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../providers/auth_provider.dart';
import '../providers/book_provider.dart';
import '../widgets/profile_stats_card.dart';
import '../widgets/achievement_card.dart';

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
      body: Consumer2<AuthProvider, BookProvider>(
        builder: (context, authProvider, bookProvider, child) {
          if (authProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(context, authProvider),
                const SizedBox(height: 24),

                // Profile Stats
                ProfileStatsCard(books: bookProvider.books),
                const SizedBox(height: 24),

                // Achievements
                _buildAchievementsSection(context, bookProvider.books),
                const SizedBox(height: 24),

                // Reading Goals
                _buildReadingGoalsSection(context),
                const SizedBox(height: 24),

                // Settings Options
                _buildSettingsOptions(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, AuthProvider authProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
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
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getUserName(authProvider.user),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  _getUserEmail(authProvider.user),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
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
                      Text(
                        'Member since ${_formatJoinDate(authProvider.user?.metadata.creationTime)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
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
  }

  Widget _buildAchievementsSection(BuildContext context, List books) {
    final completedBooks = books.where((book) => book.progress >= 1.0).length;
    final totalPages =
        books.fold<int>(0, (sum, book) => sum + (book.totalPages as int));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Achievements',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AchievementCard(
                title: 'First Book',
                description: 'Read your first book',
                icon: Icons.star,
                isUnlocked: books.isNotEmpty,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AchievementCard(
                title: 'Bookworm',
                description: 'Complete 5 books',
                icon: Icons.auto_stories,
                isUnlocked: completedBooks >= 5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AchievementCard(
                title: 'Page Turner',
                description: 'Read 1000 pages',
                icon: Icons.menu_book,
                isUnlocked: totalPages >= 1000,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: AchievementCard(
                title: 'Speed Reader',
                description: 'Read 10 books in a month',
                icon: Icons.speed,
                isUnlocked: false, // This would need more complex logic
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReadingGoalsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reading Goals',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.flag,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Books this year: 0 / 12',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: 0.0, // This would be calculated based on actual progress
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Set your reading goals to track your progress and stay motivated!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsOptions(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            context,
            icon: Icons.person,
            title: 'Edit Profile',
            subtitle: 'Update your personal information',
            onTap: () => _editProfile(context),
          ),
          _buildDivider(),
          _buildSettingsTile(
            context,
            icon: Icons.privacy_tip,
            title: 'Privacy',
            subtitle: 'Control your privacy settings',
            onTap: () => _showPrivacySettings(context),
          ),
          _buildDivider(),
          _buildSettingsTile(
            context,
            icon: Icons.help,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: () => _showHelpAndSupport(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: Colors.grey[200],
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
    final TextEditingController nameController = TextEditingController(
      text: authProvider.user?.displayName ?? '',
    );
    final TextEditingController emailController = TextEditingController(
      text: authProvider.user?.email ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                debugPrint(
                    'Updating profile with name: ${nameController.text}');
                final success =
                    await authProvider.updateProfile(nameController.text);
                debugPrint('Profile update success: $success');
                if (context.mounted) {
                  if (success) {
                    debugPrint(
                        'Current user display name: ${authProvider.user?.displayName}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Profile updated successfully!')),
                    );
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(authProvider.errorMessage ??
                              'Failed to update profile')),
                    );
                  }
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showPrivacySettings(BuildContext context) {
    bool dataCollection = true;
    bool analytics = true;
    bool crashReports = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Privacy Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Data Collection'),
                subtitle: const Text('Allow app to collect usage data'),
                value: dataCollection,
                onChanged: (value) => setState(() => dataCollection = value),
              ),
              SwitchListTile(
                title: const Text('Analytics'),
                subtitle: const Text('Help improve the app with analytics'),
                value: analytics,
                onChanged: (value) => setState(() => analytics = value),
              ),
              SwitchListTile(
                title: const Text('Crash Reports'),
                subtitle: const Text('Send crash reports to help fix bugs'),
                value: crashReports,
                onChanged: (value) => setState(() => crashReports = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Privacy settings saved!')),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpAndSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Frequently Asked Questions:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Q: How do I add books?'),
            Text('A: Use the + button on the home screen to import books.'),
            SizedBox(height: 8),
            Text('Q: How do I track my reading progress?'),
            Text('A: Open any book and use the progress slider at the bottom.'),
            SizedBox(height: 8),
            Text('Q: Can I change the theme?'),
            Text('A: Yes, go to Settings > Appearance > Theme Color.'),
            SizedBox(height: 8),
            Text('Q: How do I set reading goals?'),
            Text('A: Go to Settings > Reading > Reading Goals.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Contact support: support@readverse.com')),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Contact Support'),
          ),
        ],
      ),
    );
  }
}
