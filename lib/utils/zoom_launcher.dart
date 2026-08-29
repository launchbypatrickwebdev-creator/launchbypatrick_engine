// lib/utils/zoom_launcher.dart
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class ZoomLauncher {
  static Future<void> launchZoomLink(
      String bookingUrl, {
        VoidCallback? onSuccess,
        VoidCallback? onError,
      }) async {
    try {
      if (bookingUrl.isEmpty || bookingUrl.startsWith('YOUR_')) {
        if (onError != null) onError();
        return;
      }

      final Uri uri = Uri.parse(bookingUrl);

      // 🛰️ FIXED: use platformDefault so Flutter Web opens the link in a
      // new browser tab instead of trying to launch an external application
      // (which is sandboxed and always fails in a web context).
      // Also removed the zoomUrl.contains('zoom') check — this now works
      // for any valid booking URL including Calendly.
      await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
        webOnlyWindowName: '_blank',
      );
      if (onSuccess != null) onSuccess();
    } catch (e) {
      if (onError != null) onError();
    }
  }

  static Future<void> showZoomDialog(
      BuildContext context,
      String zoomUrl,
      String assistantName,
      ) async {
    await launchZoomLink(
      zoomUrl,
      onError: () {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open booking link. Please try again.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
    );
  }
}