// lib/widgets/chat_modal_sheet.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
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

/// Full-screen modal for AI Buddy chat (Mobile)
class ChatModalSheet extends StatefulWidget {
  final AIBuddyConfig config;
  final String? conversationId;

  const ChatModalSheet({
    super.key,
    required this.config,
    this.conversationId,
  });

  @override
  State<ChatModalSheet> createState() => _ChatModalSheetState();
}

class _ChatModalSheetState extends State<ChatModalSheet> {
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
    // 🛰️ FIXED: load most recent conversation so chat persists on reopen
    final conversations = await _chatService.getAllConversations();
    if (conversations.isNotEmpty) {
      await _chatService.initialize(conversationId: conversations.first.id);
    } else {
      await _chatService.initialize(conversationId: widget.conversationId);
    }
    setState(() => _isInitialized = true);
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

  // 🛰️ FIXED: checks for [BOOKING_READY] sentinel — only present in the
  // AI's Phase 2 confirmation message, never in Phase 1.
  bool get _showZoomButton {
    final messages = _chatService.currentConversation.messages;
    if (messages.isEmpty) return false;

    return messages.any((msg) =>
    msg.sender == MessageSender.ai &&
        msg.content.contains('[BOOKING_READY]'),
    );
  }

  // 🛰️ BOOKING FLOW: fires context to Formspree then opens Calendly/Zoom
  Future<void> _handleZoomPress() async {
    final messages = _chatService.currentConversation.messages;
    final transcript = messages
        .map((m) => '${m.sender == MessageSender.user ? "User" : "AI"}: ${m.content}')
        .join('\n\n');

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
    } catch (_) {}

    if (mounted) {
      await ZoomLauncher.showZoomDialog(
        context,
        widget.config.zoomLink,
        widget.config.assistantName,
      );
    }
  }

  void _handleLearnMore() {
    // 🛰️ FIXED: navigate to /contact FAQ page instead of showing a snackbar
    Navigator.pop(context); // close the chat modal first
    context.go('/contact');
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Material(
        color: const Color(0xFF0A0B10),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(widget.config.accentColor),
          ),
        ),
      );
    }

    return Material(
      color: const Color(0xFF0A0B10),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: StreamBuilder<Conversation>(
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
                    // 🛰️ FIXED: removed reverse:true — causes scroll to jump
                    // to the first message instead of the latest reply.
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // SUGGESTION PILLS (NEW)
            if (_chatService.currentConversation.messages.isEmpty)
              QuickSuggestionPills(
                config: widget.config,
                onSuggestionSelected: _handleSuggestionSelected,
              ),
            // 🛰️ FIXED: inside StreamBuilder so it reacts to each new AI
            // message — button only surfaces once AI sends its confirmation
            // summary containing "book a call".
            StreamBuilder<Conversation>(
              stream: _chatService.conversationStream,
              builder: (context, snapshot) {
                if (!_isInitialized || !_showZoomButton) return const SizedBox.shrink();
                return _buildQuickActionButtons();
              },
            ),
            ChatInputWidget(
              config: widget.config,
              voiceService: _voiceService,
              textController: _textController,
              onSendMessage: _handleSendMessage,
              onSendVoiceMessage: _handleSendVoiceMessage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: widget.config.accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.config.assistantName,
                style: GoogleFonts.robotoMono(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // New Chat button
          GestureDetector(
            onTap: () async {
              await _chatService.startNewConversation();
              setState(() {});
            },
            child: Tooltip(
              message: 'New Chat',
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: widget.config.accentColor.withValues(alpha: 0.4),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: widget.config.accentColor.withValues(alpha: 0.8),
                  size: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                border: Border.all(
                  color: widget.config.accentColor.withValues(alpha: 0.5),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.close_rounded,
                color: widget.config.accentColor,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingMessage() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: widget.config.accentColor.withValues(alpha: 0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: MarkdownText(
          text: widget.config.greetingMessage,
          baseStyle: GoogleFonts.robotoMono(
            color: Colors.white70,
            fontSize: 13,
            height: 1.4,
          ),
          accentColor: widget.config.accentColor,
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Text(
            '🤖 ${widget.config.assistantName} is thinking',
            style: GoogleFonts.robotoMono(
              color: widget.config.accentColor.withValues(alpha: 0.6),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUserMessage = message.sender == MessageSender.user;
    // 🛰️ Strip the sentinel tag — users should never see [BOOKING_READY] in chat
    final displayContent = message.content.replaceAll('[BOOKING_READY]', '').trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
            padding: const EdgeInsets.all(12.0),
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
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.voiceInputIndicator != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Text(
                      message.voiceInputIndicator!,
                      style: GoogleFonts.robotoMono(
                        color: widget.config.accentColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                MarkdownText(
                  text: displayContent,
                  baseStyle: GoogleFonts.robotoMono(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.4,
                  ),
                  accentColor: widget.config.accentColor,
                ),
                if (message.isEdited)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      'edited',
                      style: GoogleFonts.robotoMono(
                        color: Colors.white24,
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Row(
              mainAxisAlignment: isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Text(
                  message.getFormattedTime(),
                  style: GoogleFonts.robotoMono(
                    color: Colors.white30,
                    fontSize: 11,
                  ),
                ),
                if (isUserMessage && message.isRead)
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Icon(
                      Icons.done_all_rounded,
                      size: 12,
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

  Widget _buildQuickActionButtons() {
    return Container(
      padding: const EdgeInsets.all(12.0),
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
            child: OutlinedButton(
              onPressed: _handleZoomPress,
              style: OutlinedButton.styleFrom(
                foregroundColor: widget.config.accentColor,
                side: BorderSide(color: widget.config.accentColor),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_month_rounded, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Book a Call',
                    style: GoogleFonts.robotoMono(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: _handleLearnMore,
              style: OutlinedButton.styleFrom(
                foregroundColor: widget.config.accentColor,
                side: BorderSide(color: widget.config.accentColor.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline_rounded, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Learn More',
                    style: GoogleFonts.robotoMono(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}