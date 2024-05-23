import 'package:flutter/material.dart';
import 'package:myau_message/commons/theme.dart';
import 'package:myau_message/pages/ChatPage.dart';

import '../commons/globals.dart';
import '../domains/requests/conversationRequest.dart';
import '../templates/avatarSettings.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    fetchUserConversations().then((_) {
      setState(() {
        _isLoading = false;
      });
    }).catchError((error) {
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.theme.secondaryHeaderColor,
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 16, top: 2),
              child: AvatarButton(),
            ),
          ],
          title: Text('Meow!'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.theme.secondaryHeaderColor,
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 16, top: 2),
              child: AvatarButton(),
            ),
          ],
          title: Text('Meow!'),
        ),
        body: Center(
          child: Text(_errorMessage!, style: TextStyle(fontSize: 18, color: Colors.red)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.theme.secondaryHeaderColor,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 16, top: 2),
            child: AvatarButton(),
          ),
        ],
        title: Text('Meow!'),
      ),
      body: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (context, index) => Container(
          height: 1,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black, Colors.black],
                stops: [0, 0.4, 1]
            ),
          ),
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatScreen(
                  id: '${items[index].id}',
                  chatTitle: items[index].title,
                  chatAvatarUrl: items[index].imageUrl,
                  ),
                ),
              );
            },
            child: buildConversationItem(index),
          );
        },
      ),
    );
  }

  Widget buildConversationItem(int index) {
    return Container(
      color: AppTheme.theme.scaffoldBackgroundColor,
      padding: EdgeInsets.all(10),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            backgroundImage: NetworkImage(items[index].imageUrl),
            radius: 30,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  items[index].title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  items[index].description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
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

                  // pageBuilder: (context, animation, secondaryAnimation) => ChatScreen(
                  //   id: '${items[index].id}',
                  //   chatTitle: items[index].title,
                  //   chatAvatarUrl: items[index].imageUrl,
                  // ),