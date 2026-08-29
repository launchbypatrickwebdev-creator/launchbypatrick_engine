// lib/widgets/chat_input_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/ai_buddy_config.dart';
import '../services/voice_service.dart';

/// Input widget for chat messages (text + voice)
class ChatInputWidget extends StatefulWidget {
  final AIBuddyConfig config;
  final VoiceService voiceService;
  final TextEditingController textController;
  final Function(String) onSendMessage;
  final Function(String) onSendVoiceMessage;
  // 🛰️ FIXED: voice button hidden on desktop, shown only on mobile
  final bool showVoice;

  const ChatInputWidget({
    super.key,
    required this.config,
    required this.voiceService,
    required this.textController,
    required this.onSendMessage,
    required this.onSendVoiceMessage,
    this.showVoice = true, // default true so mobile keeps it automatically
  });

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  bool _isListening = false;

  /// Handle voice input button press
  Future<void> _handleVoiceInput() async {
    if (_isListening) {
      // Stop listening
      final recognizedText = await widget.voiceService.stopListening();
      setState(() => _isListening = false);

      if (recognizedText.isNotEmpty) {
        widget.onSendVoiceMessage(recognizedText);
        widget.textController.clear();
      }
    } else {
      // Start listening
      final result = await widget.voiceService.startListening();
      if (result != null) {
        setState(() => _isListening = true);
      } else {
        // Permission denied or voice not available
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Microphone access required'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  /// Handle send button press
  void _handleSendMessage() {
    final text = widget.textController.text;
    if (text.isNotEmpty) {
      widget.onSendMessage(text);
      widget.textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0F111A),
        border: Border(
          top: BorderSide(color: widget.config.accentColor.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: [
          // Voice Input Button — mobile only (showVoice: false hides it on desktop)
          if (widget.showVoice) ...[
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _handleVoiceInput,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _isListening
                          ? widget.config.accentColor
                          : widget.config.accentColor.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      _isListening ? Icons.stop : Icons.mic,
                      color: _isListening
                          ? widget.config.accentColor
                          : widget.config.accentColor.withValues(alpha: 0.7),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Text Input Field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: widget.config.accentColor.withValues(alpha: 0.3),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: widget.textController,
                style: GoogleFonts.robotoMono(
                  color: Colors.white,
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: GoogleFonts.robotoMono(
                    color: Colors.white38,
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                maxLines: null,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Send Button - FIXED (Made Properly Clickable)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleSendMessage,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.config.accentColor.withValues(alpha: 0.2),
                  border: Border.all(
                    color: widget.config.accentColor,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    Icons.send_rounded,
                    color: widget.config.accentColor,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}