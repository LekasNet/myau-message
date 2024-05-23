import 'package:flutter/material.dart';
import '../domains/requests/addUserToConvRequest.dart';
import '../domains/requests/getUserRequest.dart';
import '../domains/requests/removeUserRequest.dart';

void showUserList(BuildContext context, String conversationId) {
  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(  // Добавить скругление для верхних углов
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (BuildContext context) {
        return ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 500,  // Ограничение максимальной высоты
          ),
          child: Column(
            children: [
              Container(
                height: 6,
                width: 40,
                margin: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Пользователи беседы', style: Theme.of(context).textTheme.headline6),
              ),
              Expanded(
                child: FutureBuilder<List<User>>(
                  future: fetchConversationUsers(conversationId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Ошибка: ${snapshot.error}"));
                    } else if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          User user = snapshot.data![index];
                          return ListTile(
                            title: Text(user.username),
                            trailing: IconButton(
                              icon: Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () => confirmRemoveUser(context, conversationId, user.id),
                            ),
                          );
                        },
                      );
                    } else {
                      return Center(child: Text("Нет данных"));
                    }
                  },
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => addUserPrompt(context, conversationId),
                icon: Icon(Icons.add),
                label: Text('Добавить пользователя'),
              ),
            ],
          ),
        );
      }
  );
}



void confirmRemoveUser(BuildContext context, String conversationId, int userId) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Удаление пользователя"),
        content: Text("Вы уверены, что хотите удалить пользователя?"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Закрыть диалоговое окно
            },
            child: Text("Отменить"),
          ),
          TextButton(
            onPressed: () {
              removeUserFromConversation(conversationId, userId.toString()).then((_) {
                Navigator.pop(context); // Закрыть диалоговое окно
                showUserList(context, conversationId); // Обновить список
              }).catchError((error) {
                print("Ошибка удаления: $error");
              });
            },
            child: Text("Подтвердить"),
          ),
        ],
      );
    },
  );
}


void addUserPrompt(BuildContext context, String conversationId) {
  TextEditingController controller = TextEditingController();
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Добавить пользователя"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: "Введите nickname пользователя"),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Отменить"),
          ),
          TextButton(
            onPressed: () {
              String username = controller.text;
              addUserToConversation(conversationId, username).then((_) {
                Navigator.pop(context); // Закрыть диалоговое окно
                showUserList(context, conversationId); // Обновить список
              }).catchError((error) {
                print("Ошибка добавления: $error");
              });
            },
            child: Text("Добавить"),
          ),
        ],
      );
    },
  );
}


