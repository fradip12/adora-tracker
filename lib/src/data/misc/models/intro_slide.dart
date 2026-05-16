import 'package:flutter/widgets.dart';

import '../../../../i18n/strings.g.dart';

class IntroSlide {
  const IntroSlide({required this.title, required this.description});

  final String title;
  final String description;
}

List<IntroSlide> introSlides(BuildContext context) => [
  IntroSlide(
    title: context.t.intro.slide1Title,
    description: context.t.intro.slide1Desc,
  ),
  IntroSlide(
    title: context.t.intro.slide2Title,
    description: context.t.intro.slide2Desc,
  ),
  IntroSlide(
    title: context.t.intro.slide3Title,
    description: context.t.intro.slide3Desc,
  ),
];
