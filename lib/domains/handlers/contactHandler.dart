import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../../commons/globals.dart';
import 'package:flutter/services.dart';

class AccountManager {
  static const MethodChannel _channel = MethodChannel('com.example.app/account');

  static Future<void> addAccount(String accountName, String accountType) async {
    await _channel.invokeMethod('addAccount', {
      'accountName': accountName,
      'accountType': accountType,
    });
  }
}


Future<void> requestPermissions() async {
  if (await Permission.contacts.request().isGranted) {
    // Разрешение предоставлено
  } else {
    // Разрешение не предоставлено
  }
}

Future<void> addMessengerToContact(String phoneNumber, String messengerName) async {
  // Запрашиваем разрешение на доступ к контактам
  await requestPermissions();

  // Получаем контакт по ID
  Contact? contact = (await FlutterContacts.getContacts(withPhoto: true, withProperties: true, withAccounts: true))
      .firstWhere((contact) => contact.phones.any((phone) => phone.normalizedNumber == phoneNumber));

  List<String> mimetype = [
    'application/x-pkcs7-certreqresp',
    'application/x-pkcs7-certificates'
    'application/vnd.android.package-archive'
  ];

  // Добавляем мессенджер в контакт
  contact.accounts.add(Account(
    '0',
    'MIREA.myaumessage.ru.myau_message',
    'Meow! Messenger',
    mimetype
  ));

  await FlutterContacts.updateContact(contact);
}

Future<void> addMessengerToMatchingContacts() async {
  // Запрашиваем разрешение на доступ к контактам
  await requestPermissions();

  // Получаем все контакты пользователя
  List<Contact> deviceContacts = await FlutterContacts.getContacts(withProperties: true);
  for (Contact deviceContact in deviceContacts) {
    for (ContactInfo contactInfo in contacts) {
      // Проверяем, есть ли совпадение по номеру телефона
      if (deviceContact.phones.any((phone) => phone.normalizedNumber == contactInfo.phoneNumber)) {
        print('${deviceContact.name}, ${deviceContact.accounts}');
        await addMessengerToContact(contactInfo.phoneNumber, 'Meow! Messenger');
      }
    }
  }
}