import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Search extends StatelessWidget {
  const Search({
    required this.onChange,
    this.onFocusChange,
    required this.searchFieldContoller,
    this.onIconPress,
    Key? key,
  }) : super(key: key);

  final Function(String) onChange;
  final Function(bool)? onFocusChange;
  final VoidCallback? onIconPress;
  final TextEditingController? searchFieldContoller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(41),
        ),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 5,
                ),
                child: Focus(
                  onFocusChange: onFocusChange,
                  child: TextField(
                    onChanged: onChange,
                    controller: searchFieldContoller,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Поиск',
                      hintStyle: TextStyle(
                        color: Color.fromRGBO(58, 58, 85, 0.5),
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'TTNorms',
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: onIconPress,
              icon: SvgPicture.asset(
                'assets/icons/Search.svg',
                width: 50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
