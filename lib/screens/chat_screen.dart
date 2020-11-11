import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  SocketIO socketIO;
  List<String> messages;
  double height, widht;
  TextEditingController textController;
  ScrollController scrollController;

  @override
  void initState() {
    messages = List<String>();
    textController = TextEditingController();
    scrollController = ScrollController();

    socketIO =
        SocketIOManager().createSocketIO('http://192.168.1.15:5000', '/');
    socketIO.init();
    socketIO.subscribe('receive_message', (jsonData) {
      Map<String, dynamic> data = json.decode(jsonData);
      this.setState(() => messages.add(data['message']));
      scrollController.animateTo(scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 600), curve: Curves.bounceIn);
    });
    socketIO.connect();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    widht = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: height * 0.1,
            ),
            buildMessageList(),
            buildInputArea()
          ],
        ),
      ),
    );
  }

  Widget buildSingleMessage(int index) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.only(bottom: 20, left: 20),
        decoration: BoxDecoration(
            color: Colors.deepPurple, borderRadius: BorderRadius.circular(20)),
        child: Text(
          messages[index],
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
    );
  }

  Widget buildMessageList() {
    return Container(
      height: height * 0.8,
      width: widht,
      child: ListView.builder(
        controller: scrollController,
        itemCount: messages.length,
        itemBuilder: (BuildContext context, int index) {
          return buildSingleMessage(index);
        },
      ),
    );
  }

  Widget buildChatInput() {
    return Container(
      width: widht * 0.7,
      padding: EdgeInsets.all(2),
      margin: EdgeInsets.only(left: 40),
      child: TextField(
        decoration: InputDecoration.collapsed(hintText: 'send a message'),
        controller: textController,
      ),
    );
  }

  Widget buildSendButton() {
    return FloatingActionButton(
      backgroundColor: Colors.deepPurple,
      onPressed: () {
        if (textController.text.isNotEmpty) {
          socketIO.sendMessage(
              'send_message', json.encode({'message': textController.text}));
          this.setState(() {
            messages.add(textController.text);
          });
          textController.text = '';
          scrollController.animateTo(scrollController.position.maxScrollExtent,
              duration: Duration(microseconds: 600), curve: Curves.bounceOut);
        }
      },
      child: Icon(
        Icons.send,
        size: 30,
      ),
    );
  }

  Widget buildInputArea() {
    return Container(
      height: height * 0.1,
      width: widht,
      child: Row(
        children: [buildChatInput(), buildSendButton()],
      ),
    );
  }
}
