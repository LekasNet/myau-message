import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:myau_message/commons/theme.dart';

import '../../commons/colors.dart';

class TextFieldDecorator extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback func;

  TextFieldDecorator({super.key, required this.controller, required this.func});


  @override
  TextFieldDecoratorState createState() => TextFieldDecoratorState();
}

class TextFieldDecoratorState extends State<TextFieldDecorator> {
  late FocusNode _focusNode;
  bool isKeyboardOpen = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      isKeyboardOpen = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      alignment: Alignment.bottomCenter,
      height: isKeyboardOpen ? 64 : 124,
      decoration: BoxDecoration(
        color: AppTheme.theme.bottomNavigationBarTheme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30)
        ),
      ),
      child: Stack(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 0),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              height: isKeyboardOpen ? 64 : 124,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    height: 60,
                    alignment: Alignment.center,
                    child: const Row(
                      children: [
                        Icon(Icons.emoji_emotions)
                      ],
                    ),
                  ),
                ]
              ),
            ),
          ),
          AnimatedPadding(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            padding: EdgeInsets.only(top: isKeyboardOpen ? 0 : 60),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: AppTheme.theme.colorScheme.secondary,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isKeyboardOpen ? 0 : 30),
                    topRight: Radius.circular(isKeyboardOpen ? 0 : 30)
                ),
              ),
              child: TextField(
                focusNode: _focusNode,
                controller: widget.controller,
                decoration: InputDecoration(
                  hintText: 'Введите сообщение...',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: widget.func,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// TextField(
// controller: widget.controller,
// decoration: InputDecoration(
// hintText: 'Введите сообщение...',
// border: OutlineInputBorder(
// borderRadius: BorderRadius.circular(8.0),
// ),
// ),
// );

//   Column(
//   children: [
//     AnimatedContainer(
//       clipBehavior: Clip.antiAlias,
//       duration: Duration(milliseconds: 500),
//       curve: Curves.easeInOut,
//       decoration: BoxDecoration(
//         color: AppTheme.theme.bottomNavigationBarTheme.backgroundColor,
//         borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(isKeyboardOpen ? 0 : 30),
//             topRight: Radius.circular(isKeyboardOpen ? 0 : 30)
//         ),
//       ),
//       child: ClipRRect(
//         child: AnimatedContainer(
//           duration: Duration(milliseconds: 500),
//           curve: Curves.easeInOut,
//           height: isKeyboardOpen ? 64 : 124 ,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               if (!isKeyboardOpen) Container(
//                 padding: EdgeInsets.symmetric(horizontal: 10),
//                 height: 60,
//                 alignment: Alignment.center,
//                 child: const Row(
//                   children: [
//                     Icon(Icons.plus_one)
//                   ],
//                 ),
//               ),
//               AnimatedContainer(
//                 duration: Duration(milliseconds: 500),
//                 curve: Curves.easeInOut,
//                 decoration: BoxDecoration(
//                   color: AppTheme.theme.colorScheme.secondary,
//                   borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(isKeyboardOpen ? 0 : 30),
//                       topRight: Radius.circular(isKeyboardOpen ? 0 : 30)
//                   ),
//                 ),
//                 child: TextField(
//                   focusNode: _focusNode,
//                   controller: widget.controller,
//                   decoration: InputDecoration(
//                     hintText: 'Введите сообщение...',
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(30.0),
//                       borderSide: BorderSide(color: Colors.transparent),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(30.0),
//                       borderSide: BorderSide(color: Colors.transparent),
//                     ),
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     ),
//   ],
// );