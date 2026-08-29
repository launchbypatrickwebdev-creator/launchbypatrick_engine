// lib/widgets/email_popup_catcher.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/tech_app_theme.dart';

class EmailPopupCatcher extends StatefulWidget {
  final String pageType; // 'home' or 'sentinel'
  final bool isAutoTriggered; // true if opened automatically on first visit

  const EmailPopupCatcher({
    super.key,
    required this.pageType,
    this.isAutoTriggered = false,
  });

  @override
  State<EmailPopupCatcher> createState() => _EmailPopupCatcherState();
}

class _EmailPopupCatcherState extends State<EmailPopupCatcher> {
  final TextEditingController _emailController = TextEditingController();
  bool _isSubscribed = false;
  String _statusMessage = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubscribe() async {
    final String email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => _statusMessage = 'Enter your email');
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      setState(() => _statusMessage = 'Invalid email format');
      return;
    }

    setState(() => _isLoading = true);

    // TODO: Replace with your actual API call
    // await Future.delayed(const Duration(milliseconds: 800));

    // Example backend call:
    // try {
    //   await _submitEmailToBackend(email);
    // } catch (e) {
    //   setState(() => _statusMessage = 'Error: ${e.toString()}');
    //   setState(() => _isLoading = false);
    //   return;
    // }

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _isSubscribed = true;
      _statusMessage = 'Thank you for subscribing!';
      _isLoading = false;
    });

    // Close popup after success
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _closePopup() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSentinel = widget.pageType == 'sentinel';

    final Color accentColor = isSentinel
        ? TechAppTheme.iotAccent  // Emerald Green
        : const Color(0xFF00E5FF); // Cyan

    final String title = isSentinel
        ? 'SENTINEL HARDWARE UPDATES'
        : 'LAUNCHBYPATRICK INSIGHTS';

    final String description = isSentinel
        ? 'Get notified about controllers integration updates, firmware releases, and IoT logistics protocols.'
        : 'Stay updated on cross-platform architecture, web scaling strategies, and product design innovations.';

    final String buttonText = isSentinel
        ? 'ACTIVATE ALERTS'
        : 'SUBSCRIBE NOW';

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Center(
        child: Container(
          width: 420,
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            color: const Color(0xFF0F111A),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Main content
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Accent label
                              Text(
                                isSentinel ? '🛰️ SECURE OPERATIONS' : '🚀 STAY CONNECTED',
                                style: GoogleFonts.robotoMono(
                                  color: accentColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Title
                              Text(
                                title,
                                style: GoogleFonts.robotoMono(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Description
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Email input
                    TextField(
                      controller: _emailController,
                      enabled: !_isSubscribed && !_isLoading,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        hintText: 'your@email.com',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.white30,
                          fontSize: 13,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: accentColor.withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.zero,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: accentColor.withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.zero,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: accentColor.withValues(alpha: 0.8),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.zero,
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: accentColor.withValues(alpha: 0.1),
                          ),
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onSubmitted: (_) => _handleSubscribe(),
                    ),

                    const SizedBox(height: 16),

                    // Status message
                    if (_statusMessage.isNotEmpty)
                      Text(
                        _statusMessage,
                        style: GoogleFonts.robotoMono(
                          color: _isSubscribed ? accentColor : Colors.redAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Subscribe button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubscribed || _isLoading ? null : _handleSubscribe,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: const Color(0xFF0A0B10),
                          disabledBackgroundColor: accentColor.withValues(alpha: 0.4),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              const Color(0xFF0A0B10),
                            ),
                          ),
                        )
                            : Text(
                          _isSubscribed ? '✓ SUBSCRIBED' : buttonText,
                          style: GoogleFonts.robotoMono(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Privacy text
                    Center(
                      child: Text(
                        'We respect your privacy. Unsubscribe anytime.',
                        style: GoogleFonts.robotoMono(
                          color: Colors.white30,
                          fontSize: 9,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Close button (X icon)
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  onPressed: _closePopup,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white60,
                    size: 24,
                  ),
                  splashRadius: 24,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}