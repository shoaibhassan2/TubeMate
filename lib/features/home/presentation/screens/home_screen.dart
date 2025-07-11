import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tubemate/core/presentation/widgets/wave_background_widget.dart';
import 'package:tubemate/features/home/presentation/widgets/home_page_content.dart';
import 'package:tubemate/features/whatsapp_saver/presentation/screens/whatsapp_status_saver_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // State for controlling the selected tab

  // Callback function for tab selection
  void _onTap(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary; // Get primary color from theme

    // List of pages corresponding to bottom navigation bar items
    final List<Widget> pages = [
      const HomePageContent(), // Home tab content
      Center(child: Text('Downloads Page', style: theme.textTheme.headlineSmall)), // Placeholder for Downloads tab
      const WhatsappStatusSaverScreen(), // WhatsApp Status Saver Screen for the 'WhatsApp' tab
    ];

    return Scaffold(
      body: Stack(
        children: [
          const WaveBackgroundWidget(), // Reusable wave background
          pages[_selectedIndex], // Display selected page content
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Current active tab
        onTap: _onTap, // Callback for tab selection
        // Removed splashColor: Colors.transparent because it's not supported in your Flutter SDK version.
        // The default splash behavior will apply.
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.download), label: 'Downloads'),
          BottomNavigationBarItem(
            icon: const FaIcon(FontAwesomeIcons.whatsapp),
            activeIcon: FaIcon(FontAwesomeIcons.whatsapp, color: accentColor), // Use theme accent color
            label: 'WhatsApp',
          ),
        ],
      ),
    );
  }
}