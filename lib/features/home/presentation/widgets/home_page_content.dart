import 'package:flutter/material.dart';
import 'package:tubemate/features/home/presentation/widgets/header_widget.dart';
// import 'package:tubemate/features/home/presentation/widgets/search_bar_widget.dart'; // <--- REMOVE THIS IMPORT
import 'package:tubemate/features/home/presentation/widgets/link_input_section.dart'; // <--- NEW IMPORT

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
            child: HeaderWidget(),
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            // Use the new LinkInputSection that contains both the search bar and the button
            child: LinkInputSection(), // <--- USE NEW WIDGET
          ),
          Spacer(),
        ],
      ),
    );
  }
}