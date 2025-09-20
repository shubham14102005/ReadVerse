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
                'Font Style',
                'Choose your preferred font',
                Icons.font_download,
                themeProvider.fontStyle,
                () => _showFontStyleDialog(themeProvider),
              );
            },
          ),

          const Divider(),

          // Reading Features Section
          _buildSectionHeader('Reading Features'),
          _buildListTile(
            'Reading Mode',
            'Optimize for comfortable reading',
            Icons.auto_stories,
            'Enhanced experience',
            () => _showReadingModeDialog(),
          ),
          _buildListTile(
            'Text Highlighting',
            'Enable text selection and highlights',
            Icons.highlight_alt,
            'Interactive reading',
            () => _showHighlightingDialog(),
          ),
          _buildListTile(
            'Reading Statistics',
            'Track your reading progress',
            Icons.analytics,
            'Detailed insights',
            () => _showReadingStatsDialog(),
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.05),
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.05),
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
                          color: isDestructive 
                              ? Colors.red 
                              : (Theme.of(context).brightness == Brightness.dark 
                                  ? Colors.white 
                                  : Colors.grey[800]),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.grey[400] 
                              : Colors.grey[600],
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
        title: const Row(
          children: [
            Icon(Icons.palette, size: 24),
            SizedBox(width: 8),
            Text('Beautiful Themes'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: themeProvider.themes.keys.map((themeName) {
                return _buildBeautifulThemeOption(themeName, themeProvider);
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildBeautifulThemeOption(String themeName, ThemeProvider themeProvider) {
    final theme = themeProvider.themes[themeName]!;
    final gradient = theme['gradient'] as List<Color>;
    final isSelected = themeProvider.selectedTheme == themeName;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: isSelected 
            ? Border.all(color: Theme.of(context).primaryColor, width: 2)
            : null,
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: gradient[0].withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _getThemeIcon(themeName),
        ),
        title: Text(
          themeName,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Theme.of(context).primaryColor : null,
          ),
        ),
        subtitle: Text(
          theme['description'] ?? 'Beautiful theme',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: isSelected 
            ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
            : Icon(Icons.circle_outlined, color: Colors.grey[400]),
        onTap: () {
          themeProvider.setTheme(themeName);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  String _getThemeColorName(Color color) {
    // Get theme name from theme provider based on selected theme
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return themeProvider.selectedTheme;
  }

  Widget _getThemeIcon(String themeName) {
    IconData iconData;
    switch (themeName) {
      case 'Ocean Breeze':
        iconData = Icons.waves;
        break;
      case 'Forest Dream':
        iconData = Icons.forest;
        break;
      case 'Sunset Glow':
        iconData = Icons.wb_sunny;
        break;
      case 'Midnight Sky':
        iconData = Icons.nightlight;
        break;
      case 'Rose Gold':
        iconData = Icons.favorite;
        break;
      case 'Aurora':
        iconData = Icons.auto_awesome;
        break;
      default:
        iconData = Icons.palette;
    }
    return Icon(iconData, color: Colors.white, size: 24);
  }

  void _showFontStyleDialog(ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.font_download, size: 24),
            SizedBox(width: 8),
            Text('Font Style'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: themeProvider.fontStyles.keys.map((fontStyle) {
                return _buildFontStyleOption(fontStyle, themeProvider);
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildFontStyleOption(String fontStyleName, ThemeProvider themeProvider) {
    final fontStyle = themeProvider.fontStyles[fontStyleName]!;
    final isSelected = themeProvider.fontStyle == fontStyleName;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: isSelected 
            ? Border.all(color: Theme.of(context).primaryColor, width: 2)
            : null,
      ),
      child: ListTile(
        title: Text(
          fontStyleName,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Theme.of(context).primaryColor : null,
            fontFamily: fontStyle['fontFamily'],
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          fontStyle['description'] ?? 'Beautiful font style',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontFamily: fontStyle['fontFamily'],
          ),
        ),
        trailing: isSelected 
            ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
            : Icon(Icons.circle_outlined, color: Colors.grey[400]),
        onTap: () {
          themeProvider.setFontStyle(fontStyleName);
          Navigator.of(context).pop();
        },
      ),
    );
  }


  void _showReadingModeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.auto_stories, size: 24),
            SizedBox(width: 8),
            Text('Reading Mode'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🌿 Nature backgrounds adapt to your selected theme'),
            SizedBox(height: 8),
            Text('🌙 Night mode reduces blue light for comfortable reading'),
            SizedBox(height: 8),
            Text('📖 Fullscreen mode for distraction-free reading'),
            SizedBox(height: 8),
            Text('🎨 Reading section theme changes independently'),
            SizedBox(height: 8),
            Text('✨ Enhanced typography with perfect spacing'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showHighlightingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.highlight_alt, size: 24),
            SizedBox(width: 8),
            Text('Text Highlighting'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('✨ Select any text to highlight important passages'),
            SizedBox(height: 8),
            Text('🎯 Tap the highlight button to enable highlight mode'),
            SizedBox(height: 8),
            Text('📝 Enhanced text selection with beautiful cursors'),
            SizedBox(height: 8),
            Text('💾 Highlights are saved for future reference'),
            SizedBox(height: 8),
            Text('🔍 Easy text search and navigation'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  void _showReadingStatsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.analytics, size: 24),
            SizedBox(width: 8),
            Text('Reading Statistics'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📊 Track your daily reading progress'),
            SizedBox(height: 8),
            Text('📈 See your reading goals and achievements'),
            SizedBox(height: 8),
            Text('⏱️ Monitor reading time and speed'),
            SizedBox(height: 8),
            Text('📚 Count books completed this year'),
            SizedBox(height: 8),
            Text('🎯 Set and achieve reading milestones'),
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
        title: const Row(
          children: [
            Icon(Icons.help_center, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text('ReadVerse Help'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📖 Getting Started',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 8),
              Text('• Tap the ❤️ button on the home screen to view your favorites'),
              Text('• Use the search page to find books by title or author'),
              Text('• Filter books by completion status (Complete/Incomplete)'),
              SizedBox(height: 16),
              
              Text('📚 Reading Books',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 8),
              Text('• Tap any book to start reading'),
              Text('• Your reading progress is automatically saved'),
              Text('• Mark books as favorites for quick access'),
              SizedBox(height: 16),
              
              Text('🎨 Customization',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 8),
              Text('• Change theme colors in Settings > Theme Color'),
              Text('• Adjust font styles for better reading experience'),
              Text('• ReadVerse uses dark theme by default for comfortable reading'),
              SizedBox(height: 16),
              
              Text('💡 Tips & Tricks',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 8),
              Text('• Complete books will show a green checkmark'),
              Text('• Use search filters to find specific types of content'),
              Text('• Reading statistics help track your progress'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it!'),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📧 Need more help? Contact: help@readverse.app'),
                  duration: Duration(seconds: 4),
                ),
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
