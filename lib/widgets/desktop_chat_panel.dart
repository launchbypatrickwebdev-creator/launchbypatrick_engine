// lib/widgets/desktop_chat_panel.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../models/ai_buddy_config.dart';
import '../models/chat_message.dart';
import '../models/conversation.dart';
import '../services/ai_chat_service.dart';
import '../services/voice_service.dart';
import '../utils/zoom_launcher.dart';
import 'chat_input_widget.dart';
import 'quick_suggestion_pills.dart';
import 'markdown_text.dart';

/// Desktop side panel for AI Buddy chat (Right side, REDUCED HEIGHT)
class DesktopChatPanel extends StatefulWidget {
  final AIBuddyConfig config;
  final VoidCallback onClose;

  const DesktopChatPanel({
    super.key,
    required this.config,
    required this.onClose,
  });

  @override
  State<DesktopChatPanel> createState() => _DesktopChatPanelState();
}

class _DesktopChatPanelState extends State<DesktopChatPanel> {
  late AIChatService _chatService;
  late VoiceService _voiceService;
  late ScrollController _scrollController;
  late TextEditingController _textController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _textController = TextEditingController();
    _voiceService = VoiceService();
    _chatService = AIChatService(config: widget.config);

    _initializeChat();
  }

  Future<void> _initializeChat() async {
    // 🛰️ FIXED: load the most recent conversation instead of always starting
    // fresh — so the user's chat persists across panel open/close sessions.
    final conversations = await _chatService.getAllConversations();
    if (conversations.isNotEmpty) {
      await _chatService.initialize(conversationId: conversations.first.id);
    } else {
      await _chatService.initialize();
    }
    setState(() => _isInitialized = true);
    // Scroll to bottom after loading existing messages
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _chatService.dispose();
    _voiceService.dispose();
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSuggestionSelected(String text) {
    _textController.text = text;
  }

  void _handleSendMessage(String text) async {
    await _chatService.sendMessage(text);
    _textController.clear();
    _scrollToBottom();
  }

  void _handleSendVoiceMessage(String voiceText) async {
    await _chatService.sendVoiceMessage(voiceText);
    _textController.clear();
    _scrollToBottom();
  }

  // 🛰️ BOOKING FLOW: fires context to Formspree then opens Calendly/Zoom
  Future<void> _handleZoomPress() async {
    // 1. Collect conversation context to notify Patrick
    final messages = _chatService.currentConversation.messages;
    final transcript = messages
        .map((m) => '${m.sender == MessageSender.user ? "User" : "AI"}: ${m.content}')
        .join('\n\n');

    // 2. Silently send the booking context to Formspree
    try {
      await http.post(
        Uri.parse('https://formspree.io/f/xpqjyydl'),
        headers: {'Accept': 'application/json'},
        body: {
          'Form_Type': 'AI Chat Booking Request',
          'Assistant': widget.config.assistantName,
          'Conversation_Transcript': transcript,
          'Timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (_) {
      // Silent fail — don't block the user from booking
    }

    // 3. Open Calendly/Zoom booking link
    if (mounted) {
      await ZoomLauncher.showZoomDialog(
        context,
        widget.config.zoomLink,
        widget.config.assistantName,
      );
    }
  }
  // 🛰️ FIXED: checks for the [BOOKING_READY] sentinel that the system prompt
  // instructs Mistral to include ONLY in its Phase 2 confirmation message —
  // after it has collected and echoed back name, email, topic, and time.
  // It never appears in Phase 1 (the "please provide details" message),
  // so the button is genuinely gated behind the user supplying their info.
  bool get _showZoomButton {
    final messages = _chatService.currentConversation.messages;
    if (messages.isEmpty) return false;

    return messages.any((msg) =>
    msg.sender == MessageSender.ai &&
        msg.content.contains('[BOOKING_READY]'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final panelHeight = screenHeight * 0.65; // 65% of screen height

    return Container(
      width: 380,
      height: panelHeight, // FIXED HEIGHT - no longer full screen
      decoration: BoxDecoration(
        color: const Color(0xFF0A0B10),
        border: Border(
          left: BorderSide(
            color: widget.config.accentColor.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isInitialized
                ? StreamBuilder<Conversation>(
              stream: _chatService.conversationStream,
              builder: (context, snapshot) {
                final conversation = snapshot.data ?? _chatService.currentConversation;
                final messages = conversation.getLast50Messages();
                // 🛰️ FIXED: scroll to bottom after each new message renders
                if (snapshot.hasData) {
                  WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                }

                return SingleChildScrollView(
                  controller: _scrollController,
                  // 🛰️ FIXED: removed reverse:true — it flips the list so
                  // maxScrollExtent is at the top, causing _scrollToBottom()
                  // to jump to the first message instead of the latest.
                  // Now messages render top-to-bottom normally and we call
                  // _scrollToBottom() after each frame to follow new messages.
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (messages.isEmpty) _buildGreetingMessage(),
                        ...messages.map((msg) => _buildMessageBubble(msg)),
                        StreamBuilder<bool>(
                          stream: _chatService.typingStream,
                          initialData: false,
                          builder: (context, snapshot) {
                            if (snapshot.data == true) {
                              return _buildTypingIndicator();
                            }
                            return SizedBox.shrink();
                          },
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              },
            )
                : Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(widget.config.accentColor),
              ),
            ),
          ),
          // SUGGESTION PILLS
          if (_isInitialized && _chatService.currentConversation.messages.isEmpty)
            Container(
              color: Colors.white.withValues(alpha: 0.02),
              child: QuickSuggestionPills(
                config: widget.config,
                onSuggestionSelected: _handleSuggestionSelected,
              ),
            ),
          // 🛰️ FIXED: inside StreamBuilder so it rebuilds on every new AI
          // message — _showZoomButton only returns true once the AI has
          // sent its confirmation summary containing "book a call".
          StreamBuilder<Conversation>(
            stream: _chatService.conversationStream,
            builder: (context, snapshot) {
              if (!_isInitialized || !_showZoomButton) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: widget.config.accentColor.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _handleZoomPress,
                        icon: const Icon(Icons.calendar_month_rounded, size: 14),
                        label: Text(
                          'Book a Call',
                          style: GoogleFonts.robotoMono(fontSize: 10),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: widget.config.accentColor,
                          side: BorderSide(color: widget.config.accentColor),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          ChatInputWidget(
            config: widget.config,
            voiceService: _voiceService,
            textController: _textController,
            onSendMessage: _handleSendMessage,
            onSendVoiceMessage: _handleSendVoiceMessage,
            showVoice: false, // 🛰️ voice is mobile-only
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        border: Border(
          bottom: BorderSide(
            color: widget.config.accentColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: widget.config.accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.config.assistantName,
                  style: GoogleFonts.robotoMono(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () async {
              // 🛰️ Start a fresh conversation and reset scroll
              await _chatService.startNewConversation();
              setState(() {});
              _scrollToBottom();
            },
            child: Tooltip(
              message: 'New Chat',
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: widget.config.accentColor.withValues(alpha: 0.4),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: widget.config.accentColor.withValues(alpha: 0.8),
                  size: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                border: Border.all(
                  color: widget.config.accentColor.withValues(alpha: 0.5),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Icon(
                Icons.close_rounded,
                color: widget.config.accentColor,
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingMessage() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: widget.config.accentColor.withValues(alpha: 0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: MarkdownText(
          text: widget.config.greetingMessage,
          baseStyle: GoogleFonts.robotoMono(
            color: Colors.white70,
            fontSize: 11,
            height: 1.4,
          ),
          accentColor: widget.config.accentColor,
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        '🤖 thinking...',
        style: GoogleFonts.robotoMono(
          color: widget.config.accentColor.withValues(alpha: 0.6),
          fontSize: 10,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUserMessage = message.sender == MessageSender.user;
    // 🛰️ Strip the sentinel tag — users should never see [BOOKING_READY] in chat
    final displayContent = message.content.replaceAll('[BOOKING_READY]', '').trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: 340),
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: isUserMessage
                  ? widget.config.accentColor.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.05),
              border: Border.all(
                color: isUserMessage
                    ? widget.config.accentColor.withValues(alpha: 0.4)
                    : Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: MarkdownText(
              text: displayContent,
              baseStyle: GoogleFonts.robotoMono(
                color: Colors.white,
                fontSize: 11,
                height: 1.4,
              ),
              accentColor: widget.config.accentColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Row(
              mainAxisAlignment: isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Text(
                  message.getFormattedTime(),
                  style: GoogleFonts.robotoMono(
                    color: Colors.white24,
                    fontSize: 9,
                  ),
                ),
                if (isUserMessage && message.isRead)
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Icon(
                      Icons.done_all_rounded,
                      size: 10,
                      color: widget.config.accentColor,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}