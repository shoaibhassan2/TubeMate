// Path: lib/features/home/presentation/widgets/home_page_content.dart

import 'package:flutter/material.dart';
import 'package:tubemate/features/home/presentation/widgets/header_widget.dart';
import 'package:tubemate/features/home/presentation/widgets/link_input_section.dart';

class HomePageContent extends StatelessWidget {
  // <--- NEW: Accept controller and focusNode
  final TextEditingController linkInputController;
  final FocusNode linkInputFocusNode;

  const HomePageContent({
    super.key,
    required this.linkInputController,
    required this.linkInputFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: HeaderWidget(),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            // <--- NEW: Pass controller and focusNode to LinkInputSection
            child: LinkInputSection(
              textController: linkInputController,
              focusNode: linkInputFocusNode,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}