import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Services/gemini_chat_service.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final GeminiChatService _chatService = GeminiChatService();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_UiChatMessage> _messages = [
    const _UiChatMessage(
      isUser: false,
      text: 'Hi, I am your FPMS assistant. Ask me about machine failures, maintenance checks, or troubleshooting steps.',
    ),
  ];

  bool _isSending = false;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final prompt = _inputController.text.trim();
    if (prompt.isEmpty || _isSending) return;

    setState(() {
      _messages.add(_UiChatMessage(isUser: true, text: prompt));
      _isSending = true;
    });
    _inputController.clear();
    _scrollToBottom();

    try {
      final history = _messages
          .where((m) => m.text.trim().isNotEmpty)
          .take(_messages.length - 1)
          .map((m) => GeminiChatTurn(isUser: m.isUser, text: m.text))
          .toList();

      final reply = await _chatService.generateReply(
        userPrompt: prompt,
        history: history,
      );

      if (!mounted) return;
      setState(() {
        _messages.add(_UiChatMessage(isUser: false, text: reply));
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _UiChatMessage(
            isUser: false,
            text: 'Error: ${e.toString().replaceFirst('Exception: ', '')}',
            isError: true,
          ),
        );
      });
    } finally {
      if (!mounted) return;
      setState(() => _isSending = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final background = const Color(0xFF0F1115);
    final inputBg = const Color(0xFF1D222B);

    return Container(
      color: background,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _ChatBubble(message: message);
              },
            ),
          ),
          if (_isSending)
            const Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          Container(
            color: background,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    enabled: !_isSending,
                    minLines: 1,
                    maxLines: 4,
                    style: GoogleFonts.poppins(color: Colors.white),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Ask FPMS assistant...',
                      hintStyle: GoogleFonts.poppins(color: Colors.white60),
                      filled: true,
                      fillColor: inputBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isSending ? null : _sendMessage,
                  icon: const Icon(Icons.send_rounded, color: Colors.orange),
                  style: IconButton.styleFrom(
                    backgroundColor: inputBg,
                    minimumSize: const Size(46, 46),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2E1F5E), Color(0xFF4A3080)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white24,
            child: Icon(Icons.smart_toy_outlined, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'FPMS Chatbot',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final _UiChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final align = message.isUser ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = message.isUser
        ? const Color(0xFFFF9800)
        : (message.isError ? const Color(0xFFB00020) : const Color(0xFF222A35));

    return Align(
      alignment: align,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          message.text,
          style: GoogleFonts.poppins(color: Colors.white, height: 1.35),
        ),
      ),
    );
  }
}

class _UiChatMessage {
  final bool isUser;
  final String text;
  final bool isError;

  const _UiChatMessage({
    required this.isUser,
    required this.text,
    this.isError = false,
  });
}
