// lib/globals.dart

import 'dart:typed_data';

class Item {
  final int? id;
  final String imageUrl;
  final String title;
  final String description;

  Item({this.id, required this.imageUrl, required this.title, required this.description});

  // Метод для создания экземпляра Item из Map (словаря)
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      imageUrl: json['conversation_img'],
      title: json['name'],
      description: '',
    );
  }
}

List<Item> items = [
  // Item(
  //   id: 0,
  //   imageUrl: 'https://gas-kvas.com/uploads/posts/2023-02/1675484237_gas-kvas-com-p-kartinki-dlya-fonovogo-risunka-raboch-stol-15.jpg',
  //   title: 'Title 1',
  //   description: 'Description 1',
  // ),
  // Item(
  //   id: 1,
  //   imageUrl: 'https://gas-kvas.com/uploads/posts/2023-02/1675484237_gas-kvas-com-p-kartinki-dlya-fonovogo-risunka-raboch-stol-15.jpg',
  //   title: 'Title 2',
  //   description: 'Description 2',
  // ),
  // Item(
  //   id: 2,
  //   imageUrl: 'https://gas-kvas.com/uploads/posts/2023-02/1675484237_gas-kvas-com-p-kartinki-dlya-fonovogo-risunka-raboch-stol-15.jpg',
  //   title: 'Title 3',
  //   description: 'Description 3',
  // ),
  // Item(
  //   id: 3,
  //   imageUrl: 'https://gas-kvas.com/uploads/posts/2023-02/1675484237_gas-kvas-com-p-kartinki-dlya-fonovogo-risunka-raboch-stol-15.jpg',
  //   title: 'Title 4',
  //   description: 'Description 4',
  // ),
  // Item(
  //   imageUrl: 'https://gas-kvas.com/uploads/posts/2023-02/1675484237_gas-kvas-com-p-kartinki-dlya-fonovogo-risunka-raboch-stol-15.jpg',
  //   title: 'Title 5',
  //   description: 'Description 5',
  // ),
  // Item(
  //   imageUrl: 'https://gas-kvas.com/uploads/posts/2023-02/1675484237_gas-kvas-com-p-kartinki-dlya-fonovogo-risunka-raboch-stol-15.jpg',
  //   title: 'Title 6',
  //   description: 'Description 6',
  // ),
  // Item(
  //   imageUrl: 'https://gas-kvas.com/uploads/posts/2023-02/1675484237_gas-kvas-com-p-kartinki-dlya-fonovogo-risunka-raboch-stol-15.jpg',
  //   title: 'Title 7',
  //   description: 'Description 7',
  // ),
  // Item(
  //   imageUrl: 'https://gas-kvas.com/uploads/posts/2023-02/1675484237_gas-kvas-com-p-kartinki-dlya-fonovogo-risunka-raboch-stol-15.jpg',
  //   title: 'Title 8',
  //   description: 'Description 8',
  // ),
  // Item(
  //   imageUrl: 'https://gas-kvas.com/uploads/posts/2023-02/1675484237_gas-kvas-com-p-kartinki-dlya-fonovogo-risunka-raboch-stol-15.jpg',
  //   title: 'Title 9',
  //   description: 'Description 9',
  // ),
  // Item(
  //   imageUrl: 'https://gas-kvas.com/uploads/posts/2023-02/1675484237_gas-kvas-com-p-kartinki-dlya-fonovogo-risunka-raboch-stol-15.jpg',
  //   title: 'Title 10',
  //   description: 'Description 10',
  // ),
];

// globals.dart

class ContactInfo {
  final String name;
  final String phoneNumber;

  ContactInfo(this.name, this.phoneNumber);
}

List<ContactInfo> contacts = [
  ContactInfo('John Doe', '+79772745857'),
  // ContactInfo('Jane Smith', '+79260511245'),
  ContactInfo('Alice Johnson', '+1122334455'),
];


void main() {
  print(Uint8List(16));
}

