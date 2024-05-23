import 'package:flutter/material.dart';
import 'package:myau_message/commons/theme.dart';
import 'package:myau_message/pages/ChatPage.dart';

import '../commons/globals.dart';
import '../domains/requests/conversationRequest.dart';
import '../templates/avatarSettings.dart';
import '../templates/createConvPopup.dart';
import '../templates/deleteConversation.dart';

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

  void updateConversations(){
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
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
            child: buildConversationItem(context, index),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Вызовите функцию для создания новой беседы
          showCreateConversationSheet(context, updateConversations);  // Убедитесь, что эта функция реализована
        },
        child: Icon(Icons.edit),  // Иконка карандаша для создания беседы
        backgroundColor: Colors.blue,  // Цвет кнопки, можете выбрать любой
      ),
    );
  }

  Widget buildConversationItem(BuildContext context, int index) {
    return Dismissible(
      key: Key(items[index].id.toString()), // Уникальный ключ для Dismissible
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart, // Разрешить смахивание только справа налево
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Удаление беседы'),
            content: Text('Вы уверены, что хотите удалить эту беседу?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Отменить'),
              ),
              TextButton(
                onPressed: () {
                  deleteConversation(items[index].id.toString()).then((_) {
                    updateConversations();
                    Navigator.of(context).pop(true);
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Ошибка удаления: $error'))
                    );
                    Navigator.of(context).pop(false);
                  });
                },
                child: Text('Удалить'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        // Элемент уже удален
      },
      child: Container(
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
      ),
    );
  }
}

                  // pageBuilder: (context, animation, secondaryAnimation) => ChatScreen(
                  //   id: '${items[index].id}',
                  //   chatTitle: items[index].title,
                  //   chatAvatarUrl: items[index].imageUrl,
                  // ),