import 'package:flutter/material.dart';

import '../widgets/cv/cv_viewer.dart';
import '../widgets/layout/content_width.dart';

/// `/cv`: the CV viewer as a full page, for sharing a direct link.
/// Links inside the site open the same viewer as a window instead.
class CvPage extends StatelessWidget {
  const CvPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageTitle(title: 'CV', child: CvViewer());
  }
}
