import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class Message {
  final String role;
  final String content;
  final bool isImage;
  final String? source;
  final DateTime timestamp;

  Message({
    required this.role,
    required this.content,
    this.isImage = false,
    this.source,
    required this.timestamp,
  });
}

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initPermissions();
  }

  Future<void> _initPermissions() async {
    await [Permission.camera, Permission.photos].request();
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final userMessage = Message(
      role: 'user',
      content: _controller.text,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _controller.clear();
      _isLoading = true;
    });

    try {
      // Simulate API call
      final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
      final headers = {
        'Authorization': 'Bearer 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',
        'Content-Type': 'application/json',
      };
      final body = jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": [
          {"role": "user", "content": _controller.text}
        ]
      });

      final response = await http.post(uri, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final reply = data['choices'][0]['message']['content'];
        setState(() {
          _messages.add(Message(
            role: 'assistant',
            content: reply,
            timestamp: DateTime.now(),
          ));
        });
      } else {
        setState(() {
          _messages.add(Message(
            role: 'assistant',
            content: 'Failed to get response.',
            timestamp: DateTime.now(),
          ));
        });
      }
    } catch (e) {
      _showError('Failed to get response: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (!await _requestPermissions()) {
      _showError('Permission denied');
      return;
    }

    final image = await _picker.pickImage(source: source, imageQuality: 80);
    if (image != null) {
      setState(() {
        _messages.add(Message(
          role: 'user',
          content: image.path,
          isImage: true,
          source: source == ImageSource.camera ? 'camera' : 'gallery',
          timestamp: DateTime.now(),
        ));
        _messages.add(Message(
          role: 'assistant',
          content: 'Image received.',
          timestamp: DateTime.now(),
        ));
      });
    }
  }

  Future<bool> _requestPermissions() async {
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), action: SnackBarAction(label: 'Retry', onPressed: _sendMessage)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        actions: [
          IconButton(icon: const Icon(Icons.delete), onPressed: () => setState(() => _messages.clear())),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(child: Text('Start chatting!'))
                : ListView.builder(
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isLoading && index == _messages.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                final message = _messages[index];
                return MessageBubble(message: message);
              },
            ),
          ),
          ChatInputField(
            controller: _controller,
            onSend: _sendMessage,
            onPickImage: _pickImage,
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;
  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.blueAccent : Colors.grey[300],
          borderRadius: BorderRadius.circular(15).copyWith(
            bottomLeft: Radius.circular(isUser ? 15 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.isImage)
              GestureDetector(
                onTap: () => _showFullImage(context, message.content),
                child: Image.file(
                  File(message.content),
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Text('Error loading image'),
                ),
              )
            else
              Text(
                message.content,
                style: TextStyle(color: isUser ? Colors.white : Colors.black),
              ),
            if (message.source != null)
              Text(
                'Source: ${message.source}',
                style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
              ),
            Text(
              '${message.timestamp.hour}:${message.timestamp.minute}',
              style: const TextStyle(fontSize: 10, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullImage(BuildContext context, String path) {
    showDialog(
      context: context,
      builder: (_) => Dialog(child: Image.file(File(path))),
    );
  }
}

class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final Function(ImageSource) onPickImage;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.grey[300]!, blurRadius: 5)],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: () => _showAttachmentOptions(context),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          IconButton(icon: const Icon(Icons.send), onPressed: onSend),
        ],
      ),
    );
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Gallery'),
            onTap: () {
              Navigator.pop(context);
              onPickImage(ImageSource.gallery);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Camera'),
            onTap: () {
              Navigator.pop(context);
              onPickImage(ImageSource.camera);
            },
          ),
        ],
      ),
    );
  }
}