import 'package:flutter/material.dart';
import 'package:tubemate/features/home/presentation/widgets/header_widget.dart';
import 'package:tubemate/features/home/presentation/widgets/search_bar_widget.dart';

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Padding(
            padding: EdgeInsets.all(20.0),
            child: HeaderWidget(), // Header for the home screen
          ),
          Spacer(), // Pushes search bar to the center vertically
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: SearchBarWidget(), // Search bar for the home screen
          ),
          Spacer(), // Pushes search bar to the center vertically
        ],
      ),
    );
  }
}