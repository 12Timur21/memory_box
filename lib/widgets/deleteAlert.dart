import 'package:flutter/material.dart';

class DeleteAlert extends StatelessWidget {
  const DeleteAlert({
    required this.title,
    required this.content,
    Key? key,
  }) : super(key: key);

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: AlertDialog(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 30,
          horizontal: 10,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(30),
          ),
        ),
        titlePadding: const EdgeInsets.only(
          top: 55,
        ),
        actionsPadding: const EdgeInsets.only(
          bottom: 15,
        ),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontFamily: 'TTNorms',
            fontWeight: FontWeight.w500,
          ),
        ),
        content: Text(
          content,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'TTNorms',
            fontWeight: FontWeight.w400,
            color: Color.fromRGBO(58, 58, 85, 0.7),
          ),
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 40,
                  ),
                  backgroundColor: const Color.fromRGBO(226, 119, 119, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Удалить',
                  style: TextStyle(
                    fontFamily: 'TTNorms',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 40,
                  ),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      color: Color.fromRGBO(140, 132, 226, 1),
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Нет',
                  style: TextStyle(
                    fontFamily: 'TTNorms',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color.fromRGBO(140, 132, 226, 1),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
