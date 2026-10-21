import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../config/site_config.dart';
import '../../theme/app_palette.dart';
import '../../theme/tokens.dart';
import '../common/links.dart';

/// Opens the CV in a window over the current page (full screen on phones).
Future<void> showCvViewer(BuildContext context) {
  final compact = ScreenSize.of(context).isCompact;
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.75),
    builder: (context) {
      const viewer = CvViewer(closable: true);
      if (compact) return const Dialog.fullscreen(child: viewer);
      return const Dialog(
        insetPadding: EdgeInsets.all(Insets.xl),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(width: 980, height: double.infinity, child: viewer),
      );
    },
  );
}

/// The CV rendered with PDFium ([PdfViewer]): pages are drawn by the app, so it
/// looks the same in every browser, including phones that can't show PDFs inline.
class CvViewer extends StatefulWidget {
  const CvViewer({super.key, this.closable = false});

  /// Shows a close button (when used in a dialog).
  final bool closable;

  @override
  State<CvViewer> createState() => _CvViewerState();
}

class _CvViewerState extends State<CvViewer> {
  final _controller = PdfViewerController();
  int? _page;
  int? _pageCount;
  bool _failed = false;

  /// Widest a page is shown at first, so text stays a comfortable size on big screens.
  static const _maxPageWidth = 940.0;

  /// The raw PDF, for opening in the browser's own viewer or saving.
  static const _fileUrl = 'assets/${SiteConfig.cvAsset}';

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(
          page: _page,
          pageCount: _pageCount,
          closable: widget.closable,
          onZoomIn: _pageCount == null ? null : () => _controller.zoomUp(),
          onZoomOut: _pageCount == null ? null : () => _controller.zoomDown(),
          onDownload: () => openLink(context, _fileUrl),
        ),
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(child: _viewer(p)),
              // PDFium takes a moment to start the first time; show progress meanwhile.
              if (_pageCount == null && !_failed) const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _viewer(AppPalette p) {
    return PdfViewer.asset(
      SiteConfig.cvAsset,
      controller: _controller,
      params: PdfViewerParams(
        backgroundColor: p.isDark ? const Color(0xFF0A0A0C) : p.surfaceRaised,
        margin: Insets.lg,
        maxScale: 4,
        enableTextSelection: true,
        // Links in the PDF (website, GitHub, email, Fab listings) open like any other link;
        // links to another page of the CV scroll there. The CV already underlines them,
        // so no extra highlight; the pointer cursor shows they're clickable.
        linkHandlerParams: PdfLinkHandlerParams(
          linkColor: Colors.transparent,
          onLinkTap: (link) {
            final url = link.url;
            if (url != null) {
              openLink(context, url.toString());
            } else if (link.dest != null) {
              _controller.goToDest(link.dest);
            }
          },
        ),
        pageDropShadow: const BoxShadow(color: Colors.black54, blurRadius: 24, offset: Offset(0, 8)),
        calculateInitialZoom: (document, controller, fitZoom, coverZoom) {
          final pageWidth = document.pages.first.width;
          return coverZoom * pageWidth > _maxPageWidth ? _maxPageWidth / pageWidth : coverZoom;
        },
        onViewerReady:
            (document, controller) => setState(() {
              _pageCount = document.pages.length;
              _page = controller.pageNumber ?? 1;
            }),
        onPageChanged: (page) => setState(() => _page = page),
        loadingBannerBuilder:
            (context, downloaded, total) => Center(
              child: CircularProgressIndicator(value: total == null || total == 0 ? null : downloaded / total),
            ),
        errorBannerBuilder: (context, error, stackTrace, documentRef) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_failed) setState(() => _failed = true);
          });
          return _LoadError(onOpen: () => openLink(context, _fileUrl));
        },
        viewerOverlayBuilder:
            (context, size, handleLinkTap) => [
              PdfViewerScrollThumb(
                controller: _controller,
                orientation: ScrollbarOrientation.right,
                thumbSize: const Size(44, 26),
                thumbBuilder:
                    (context, thumbSize, pageNumber, controller) => Container(
                      decoration: BoxDecoration(
                        color: p.surfaceRaised,
                        borderRadius: Radii.smAll,
                        border: Border.all(color: p.border),
                      ),
                      alignment: Alignment.center,
                      child: Text('${pageNumber ?? ''}', style: Theme.of(context).textTheme.labelMedium),
                    ),
              ),
            ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.page,
    required this.pageCount,
    required this.closable,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onDownload,
  });

  final int? page;
  final int? pageCount;
  final bool closable;
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final compact = ScreenSize.of(context).isCompact;
    return Container(
      height: 64,
      padding: const EdgeInsets.only(left: Insets.md + 4, right: Insets.sm),
      decoration: BoxDecoration(color: p.surface, border: Border(bottom: BorderSide(color: p.border))),
      child: Row(
        children: [
          Icon(Icons.description_outlined, color: p.accent),
          const SizedBox(width: Insets.md - 4),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Curriculum Vitae', style: text.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(
                  pageCount == null
                      ? SiteConfig.ownerName
                      : compact
                      ? 'Page $page of $pageCount'
                      : '${SiteConfig.ownerName} · Page $page of $pageCount',
                  style: text.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(tooltip: 'Zoom out', onPressed: onZoomOut, icon: const Icon(Icons.zoom_out)),
          IconButton(tooltip: 'Zoom in', onPressed: onZoomIn, icon: const Icon(Icons.zoom_in)),
          const SizedBox(width: Insets.xs),
          if (compact)
            IconButton(tooltip: 'Download PDF', onPressed: onDownload, icon: const Icon(Icons.download_outlined))
          else
            OutlinedButton.icon(
              onPressed: onDownload,
              icon: const Icon(Icons.download_outlined, size: 18),
              label: const Text('Download'),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
            ),
          if (closable) ...[
            const SizedBox(width: Insets.xs),
            IconButton(tooltip: 'Close', onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
          ],
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.picture_as_pdf_outlined, size: 40, color: p.textMuted),
          const SizedBox(height: Insets.md),
          Text("The CV couldn't be displayed here.", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: Insets.sm),
          FilledButton(onPressed: onOpen, child: const Text('Open the PDF')),
        ],
      ),
    );
  }
}
