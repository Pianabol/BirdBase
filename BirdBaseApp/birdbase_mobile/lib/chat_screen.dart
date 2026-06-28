import 'package:flutter/material.dart';
import 'api_service.dart';
import 'theme/brand_colors.dart';
import 'storage_service.dart';

class ChatScreen extends StatefulWidget {
  final String? initialMessage;

  const ChatScreen({super.key, this.initialMessage});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  
  final List<Map<String, dynamic>> _messages = []; 
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.text = widget.initialMessage!;
        _sendMessage();
      });
    }
  }

  @override
  void didUpdateWidget(covariant ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialMessage != null && 
        widget.initialMessage != oldWidget.initialMessage && 
        widget.initialMessage!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.text = widget.initialMessage!;
        _sendMessage();
      });
    }
  }

  void _sendMessage() async {
    String text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"sender": "user", "text": text});
      _controller.clear();
      _isLoading = true;
    });

    String promptToSend = text;
    if (_messages.length > 1) {
      promptToSend = "Below is a summary of our previous conversation. Please remember the context and answer only my latest question:\n\n";
      int startIndex = _messages.length > 5 ? _messages.length - 5 : 0;
      for (int i = startIndex; i < _messages.length - 1; i++) {
        String role = _messages[i]["sender"] == "user" ? "User" : "Avian Expert";
        promptToSend += "$role: ${_messages[i]["text"]}\n";
      }
      promptToSend += "\nCurrent Question: $text";
    }

    String reply = await ApiService.sendMessage(promptToSend);

    if (mounted) {
      setState(() {
        _messages.add({"sender": "bot", "text": reply, "isSaved": false});
        _isLoading = false;
      });
    }
  }

  void _saveMessage(int index, String answer) {
    String question = "Unknown Question";
    if (index > 0 && _messages[index - 1]["sender"] == "user") {
      question = _messages[index - 1]["text"] ?? "";
    }

    StorageService.saveChat(question, answer);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Answer saved to your profile!"),
        backgroundColor: BrandColors.forestGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.bgCream,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: BrandColors.bgCream,
              padding: const EdgeInsets.only(top: 10, bottom: 15),
              child: const Text(
                "Avian Science Assistant",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: BrandColors.forestGreen,
                ),
              ),
            ),
            
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg["sender"] == "user";
                  final isSaved = msg["isSaved"] == true;

                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 8, bottom: 4),
                          padding: const EdgeInsets.all(14),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75, 
                          ),
                          decoration: BoxDecoration(
                            color: isUser ? BrandColors.forestGreen : BrandColors.sageGreen.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(0),
                              bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(20),
                            ),
                          ),
                          child: Text(
                            msg["text"] ?? "",
                            style: TextStyle(
                              color: isUser ? Colors.white : BrandColors.textDark,
                              fontSize: 16,
                            ),
                          ),
                        ),

                        if (!isUser)
                          InkWell(
                            onTap: isSaved ? null : () {
                              _saveMessage(index, msg["text"] ?? "");
                              
                              setState(() {
                                _messages[index]["isSaved"] = true;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, bottom: 12),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isSaved ? Icons.bookmark_added : Icons.bookmark_add_outlined, 
                                    size: 18, 
                                    color: isSaved ? Colors.grey : BrandColors.forestGreen.withValues(alpha: 0.7)
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isSaved ? "Saved" : "Save",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isSaved ? Colors.grey : BrandColors.forestGreen.withValues(alpha: 0.7),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                      ],
                    ),
                  );
                },
              ),
            ),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(color: BrandColors.sageGreen),
              ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Ask something...",
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: BrandColors.bgCream,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: BrandColors.forestGreen,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}