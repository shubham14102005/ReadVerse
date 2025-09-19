import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_profile_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(
              Icons.settings,
              color: Colors.white,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              'Settings',
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
      ),
      body: ListView(
        children: [
          // Appearance Section
          _buildSectionHeader('Appearance'),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return _buildSwitchTile(
                'Dark Mode',
                'Switch to dark theme',
                Icons.dark_mode,
                themeProvider.isDarkMode,
                (value) => themeProvider.setDarkMode(value),
              );
            },
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return _buildListTile(
                'Theme Color',
                'Choose your preferred theme',
                Icons.palette,
                _getThemeColorName(themeProvider.primaryColor),
                () => _showThemeDialog(themeProvider),
              );
            },
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return _buildListTile(
                'Font Size',
                'Adjust text size for reading',
                Icons.text_fields,
                themeProvider.fontSize,
                () => _showFontSizeDialog(themeProvider),
              );
            },
          ),

          const Divider(),

          // Reading Section
          _buildSectionHeader('Reading'),
          Consumer<UserProfileProvider>(
            builder: (context, profileProvider, child) {
              final goal = profileProvider.userProfile?.readingGoal ?? 12;
              return _buildListTile(
                'Reading Goals',
                'Set your reading targets',
                Icons.flag,
                '$goal books this year',
                () => _showReadingGoalsDialog(profileProvider),
              );
            },
          ),

          const Divider(),

          // Account Section
          _buildSectionHeader('Account'),
          _buildListTile(
            'Privacy',
            'Control your privacy settings',
            Icons.privacy_tip,
            'Privacy options',
            () => _showPrivacyDialog(),
          ),
          _buildListTile(
            'Data & Storage',
            'Manage your data usage',
            Icons.storage,
            'Storage settings',
            () => _showStorageDialog(),
          ),

          const Divider(),

          // Support Section
          _buildSectionHeader('Support'),
          _buildListTile(
            'Help Center',
            'Get help and support',
            Icons.help_center,
            'Help & FAQ',
            () => _showHelp(),
          ),
          _buildListTile(
            'About',
            'App version and information',
            Icons.info,
            'Version 1.0.0',
            () => _showAboutDialog(),
          ),
          _buildListTile(
            'Logout',
            'Sign out of your account',
            Icons.logout,
            'Sign out',
            () => _showLogoutDialog(),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                  fontSize: 16,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1), // Used withOpacity for clarity
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
        ),
        value: value,
        onChanged: onChanged,

        // -- FIX IS HERE --
        // Use thumbColor to set the thumb's color based on its state
        thumbColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            // Color when the switch is ON
            return Theme.of(context).primaryColor;
          }
          // Color when the switch is OFF (or use null for default)
          return Colors.white;
        }),
      ),
    );
  }

  Widget _buildListTile(
    String title,
    String subtitle,
    IconData icon,
    String trailing,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? Colors.red.withValues(alpha: 0.1)
                        : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: isDestructive
                        ? Colors.red
                        : Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: isDestructive ? Colors.red : Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      trailing,
                      style: TextStyle(
                        color: isDestructive ? Colors.red : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: isDestructive ? Colors.red : Colors.grey[400],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showThemeDialog(ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption('Blue', Colors.blue, themeProvider),
            _buildThemeOption('Green', Colors.green, themeProvider),
            _buildThemeOption('Purple', Colors.purple, themeProvider),
            _buildThemeOption('Orange', Colors.orange, themeProvider),
            _buildThemeOption('Red', Colors.red, themeProvider),
            _buildThemeOption('Teal', Colors.teal, themeProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
      String name, Color color, ThemeProvider themeProvider) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: color),
      title: Text(name),
      trailing:
          themeProvider.primaryColor == color ? const Icon(Icons.check) : null,
      onTap: () {
        themeProvider.setPrimaryColor(color);
        Navigator.of(context).pop();
      },
    );
  }

  String _getThemeColorName(Color color) {
    if (color == Colors.blue) return 'Blue';
    if (color == Colors.green) return 'Green';
    if (color == Colors.purple) return 'Purple';
    if (color == Colors.orange) return 'Orange';
    if (color == Colors.red) return 'Red';
    if (color == Colors.teal) return 'Teal';
    return 'Custom';
  }

  void _showFontSizeDialog(ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Font Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFontSizeOption('Small', themeProvider),
            _buildFontSizeOption('Medium', themeProvider),
            _buildFontSizeOption('Large', themeProvider),
            _buildFontSizeOption('Extra Large', themeProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeOption(String size, ThemeProvider themeProvider) {
    return ListTile(
      title: Text(size),
      trailing: themeProvider.fontSize == size ? const Icon(Icons.check) : null,
      onTap: () {
        themeProvider.setFontSize(size);
        Navigator.of(context).pop();
      },
    );
  }

  void _showReadingGoalsDialog(UserProfileProvider profileProvider) {
    final TextEditingController goalController = TextEditingController(
      text: (profileProvider.userProfile?.readingGoal ?? 12).toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Reading Goals'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('How many books do you want to read this year?'),
            const SizedBox(height: 16),
            TextField(
              controller: goalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Number of books',
                border: OutlineInputBorder(),
              ),
            ),
          ],
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
              if (goalController.text.isNotEmpty) {
                final goal = int.tryParse(goalController.text) ?? 12;
                await profileProvider.updateProfile(readingGoal: goal);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Goal set: $goal books this year')),
                  );
                  Navigator.of(context).pop();
                }
              }
            },
            child: const Text('Set Goal'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
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
                thumbColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                  if (states.contains(MaterialState.selected)) {
                    return Theme.of(context).primaryColor;
                  }
                  return Colors.white;
                }),
              ),
              SwitchListTile(
                title: const Text('Analytics'),
                subtitle: const Text('Help improve the app with analytics'),
                value: analytics,
                onChanged: (value) => setState(() => analytics = value),
                thumbColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                  if (states.contains(MaterialState.selected)) {
                    return Theme.of(context).primaryColor;
                  }
                  return Colors.white;
                }),
              ),
              SwitchListTile(
                title: const Text('Crash Reports'),
                subtitle: const Text('Send crash reports to help fix bugs'),
                value: crashReports,
                onChanged: (value) => setState(() => crashReports = value),
                thumbColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                  if (states.contains(MaterialState.selected)) {
                    return Theme.of(context).primaryColor;
                  }
                  return Colors.white;
                }),
              ),
            ],
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

  void _showStorageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data & Storage'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Storage Usage:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Books: 2.3 MB'),
            const Text('Cache: 1.1 MB'),
            const Text('Settings: 0.1 MB'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cache cleared successfully!')),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Clear Cache'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelp() {
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

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'ReadVerse',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.menu_book),
      children: [
        const Text(
            'A beautiful and modern eBook reader app built with Flutter.'),
      ],
    );
  }

  void _showLogoutDialog() {
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
}
