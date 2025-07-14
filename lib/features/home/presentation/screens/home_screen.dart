// Path: lib/features/home/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tubemate/common/widgets/wave_background_widget.dart'; // <--- UPDATED IMPORT
import 'package:tubemate/features/home/presentation/widgets/home_page_content.dart';
import 'package:tubemate/features/whatsapp_saver/presentation/screens/whatsapp_status_saver_screen.dart';
import 'package:tubemate/features/downloader/presentation/screens/downloads_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final TextEditingController _linkInputController = TextEditingController();
  final FocusNode _linkInputFocusNode = FocusNode();

  @override
  void dispose() {
    _linkInputController.dispose();
    _linkInputFocusNode.dispose();
    super.dispose();
  }

  // <--- NEW: Public method to navigate to a specific tab ---
  void navigateToTab(int index) {
    if (index >= 0 && index < 3) { // Ensure index is valid for 3 tabs
      setState(() {
        _selectedIndex = index;
      });
    }
  }
  // --------------------------------------------------------

  void _onTap(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary;

    final List<Widget> pages = [
      HomePageContent(
        linkInputController: _linkInputController,
        linkInputFocusNode: _linkInputFocusNode,
        // <--- NEW: Pass navigateToTab function down ---
        navigateToDownloadsTab: () => navigateToTab(1), // Index 1 is Downloads
        // ---------------------------------------------
      ),
      const DownloadsScreen(),
      const WhatsappStatusSaverScreen(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          const WaveBackgroundWidget(),
          pages[_selectedIndex],
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTap,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.download), label: 'Downloads'),
          BottomNavigationBarItem(
            icon: const FaIcon(FontAwesomeIcons.whatsapp),
            activeIcon: FaIcon(FontAwesomeIcons.whatsapp, color: accentColor),
            label: 'WhatsApp',
          ),
        ],
      ),
    );
  }
}



