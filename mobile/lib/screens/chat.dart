import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Chat extends StatefulWidget {
  final String babyId;

  const Chat({Key? key, required this.babyId}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  List<Map<String, dynamic>> messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController(); // Added ScrollController
  bool isLoading = true;
  String baseUrl = "";
  String loginId = "";

  @override
  void initState() {
    super.initState();
    _initializeAndFetchMessages();
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Clean up ScrollController
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _initializeAndFetchMessages() async {
    final sh = await SharedPreferences.getInstance();
    setState(() {
      baseUrl = (sh.getString("url") ?? "").endsWith('/') ? sh.getString("url")! : '${sh.getString("url")!}/';
      loginId = sh.getString("login_id") ?? "";
    });
    await fetchMessages();
    _scrollToBottom(); // Scroll to bottom after initial fetch
  }

  Future<void> fetchMessages() async {
    try {
      String url = '${baseUrl}get_chat_messages';

      var response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "baby_id": widget.babyId,
          "login_id": loginId,
        },
      );

      print("Fetching messages from: $url");
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      var jsonData = json.decode(response.body);
      if (response.statusCode == 200 && jsonData['status'] == 'success') {
        setState(() {
          messages = List<Map<String, dynamic>>.from(jsonData['data']);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print("Failed to fetch messages: ${jsonData['message']}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to load messages: ${jsonData['message'] ?? 'Unknown error'}"),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => fetchMessages(),
            ),
          ),
        );
      }
    } catch (e) {
      print("Error fetching messages: $e");
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error loading messages"),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => fetchMessages(),
          ),
        ),
      );
    }
  }

  Future<void> sendMessage(String message) async {
    try {
      String url = '${baseUrl}send_chat_message';

      var response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "baby_id": widget.babyId,
          "login_id": loginId,
          "message": message,
        },
      );

      print("Sending message to: $url");
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      var jsonData = json.decode(response.body);
      if (response.statusCode == 200 && jsonData['status'] == 'success') {
        _messageController.clear();
        await fetchMessages(); // Refresh messages after sending
        _scrollToBottom(); // Scroll to bottom after sending
      } else {
        print("Failed to send message: ${jsonData['message']}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to send message: ${jsonData['message'] ?? 'Unknown error'}")),
        );
      }
    } catch (e) {
      print("Error sending message: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending message")),
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0, // Since reverse: true, 0.0 is the bottom
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with Daycare"),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : messages.isEmpty
                ? Center(child: Text("No messages yet"))
                : ListView.builder(
              controller: _scrollController, // Attach ScrollController
              reverse: true, // Latest messages at the bottom
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                bool isSentByParent = message['sender_type'] == 'parent';
                return Align(
                  alignment: isSentByParent ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSentByParent ? Colors.blue.shade100 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['message'] ?? "",
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 5),
                        Text(
                          message['timestamp'] ?? "",
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: () {
                    if (_messageController.text.trim().isNotEmpty) {
                      sendMessage(_messageController.text.trim());
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}