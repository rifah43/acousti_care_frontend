// import 'package:acousti_care_frontend/views/profilePages/dots_indicator.dart';
// import 'package:acousti_care_frontend/views/profilePages/height_weight_gender_page.dart';
// import 'package:acousti_care_frontend/views/profilePages/name_age_page.dart';
// import 'package:acousti_care_frontend/views/profilePages/summary_page.dart';
// import 'package:flutter/material.dart';

// class ProfileForm extends StatelessWidget {
//   final int currentPage;
//   final PageController pageController;
//   final Function(int) onPageChanged;

//   const ProfileForm({
//     super.key,
//     required this.currentPage,
//     required this.pageController,
//     required this.onPageChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Expanded(
//           child: PageView(
//             controller: pageController,
//             onPageChanged: onPageChanged,
//             children: const [
//               NameAndAgePage(),
//               HeightWeightGenderPage(),
//               SummaryPage(),
//             ],
//           ),
//         ),
//         DotsIndicator(currentPage: currentPage),
//       ],
//     );
//   }
// }
