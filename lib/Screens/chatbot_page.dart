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
      text:
          'Hi, I am your FPMS assistant. Ask me about machine failures, maintenance checks, or troubleshooting steps.',
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final background = isDarkMode ? const Color(0xFF0F1115) : Colors.white;
    final inputBg = isDarkMode ? const Color(0xFF1D222B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Color(0xFFC00000)),
                ),
              ),
            Container(
              color: background,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                      color: isDarkMode ? Colors.white24 : Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_circle,
                          color: Color(0xFFC00000)),
                      onPressed: () {},
                    ),
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        enabled: !_isSending,
                        minLines: 1,
                        maxLines: 4,
                        style: GoogleFonts.poppins(color: textColor),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: const InputDecoration(
                          hintText: '',
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _isSending ? null : _sendMessage,
                      icon: const Icon(Icons.send, color: Color(0xFFC00000)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.keyboard_return,
                color: isDarkMode ? Colors.white : Colors.black),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
          Image.asset(
            'assets/images/logo.png',
            height: 45,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.engineering,
              color: Colors.orange,
              size: 40,
            ),
          ),
          IconButton(
            icon: Icon(Icons.sort,
                color: isDarkMode ? Colors.white : Colors.black),
            onPressed: () {},
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final bubbleColor = message.isUser
        ? const Color(0xFF9CA3AF) // Grey for user
        : (message.isError
            ? const Color(0xFFB00020)
            : const Color(0xFF232D3F)); // Dark navy for bot

    final textColor = message.isUser ? Colors.black87 : Colors.white;

    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomLeft: Radius.circular(message.isUser ? 20 : 0),
      bottomRight: Radius.circular(message.isUser ? 0 : 20),
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser)
            Padding(
              padding: const EdgeInsets.only(right: 8.0, top: 4),
              child: CircleAvatar(
                radius: 16,
                backgroundColor:
                    isDarkMode ? Colors.grey[800] : Colors.grey[200],
                child: const Icon(Icons.smart_toy,
                    size: 20, color: Color(0xFF232D3F)),
              ),
            ),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 280),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: borderRadius,
              ),
              child: Text(
                message.text,
                style: GoogleFonts.poppins(
                    color: textColor, height: 1.35, fontSize: 14),
              ),
            ),
          ),
        ],
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
