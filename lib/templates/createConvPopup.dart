import 'package:flutter/material.dart';
import '../domains/requests/createConversation.dart';


void showCreateConversationSheet(BuildContext context, void Function() updateConversations) {
  final _formKey = GlobalKey<FormState>();
  String? name;
  String? imageUrl;
  String? theme = 'Программирование';  // Тема по умолчанию

  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext bc) {
        return Container(
          padding: EdgeInsets.only(top:20, left: 20, right: 20, bottom: 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Название беседы'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите название беседы';
                    }
                    return null;
                  },
                  onSaved: (value) => name = value,
                ),
                DropdownButtonFormField<String>(
                  value: theme,
                  onChanged: (newValue) {
                    theme = newValue;
                  },
                  items: <String>[
                    'Программирование', 'Кино', 'Книги', 'Музыка',
                    'Игры', 'Юмор', 'Экономика', 'История'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'Выберите тему'),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'URL изображения беседы'),
                  onSaved: (value) => imageUrl = value,
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      Navigator.pop(context);  // Закрыть bottom sheet
                      await createConversation(name!, theme!, imageUrl!);
                      updateConversations();
                    }
                  },
                  child: Text('Создать беседу'),
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom,)
              ],
            ),
          ),
        );
      }
  );
}
