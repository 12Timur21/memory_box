import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CircleTextField extends StatefulWidget {
  const CircleTextField({
    required this.controller,
    this.inputFormatters,
    this.editable = true,
    this.validator,
    this.maxLength,
    Key? key,
  }) : super(key: key);

  final TextEditingController controller;
  final List<TextInputFormatter>? inputFormatters;
  final bool editable;
  final String? Function(String?)? validator;

  final int? maxLength;

  @override
  State<CircleTextField> createState() => _CircleTextFieldState();
}

class _CircleTextFieldState extends State<CircleTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Stack(
        children: [
          Container(
            height: 64,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(41),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.17),
                  blurRadius: 11,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          ),
          TextFormField(
            controller: widget.controller,
            enabled: widget.editable,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.phone,
            inputFormatters: widget.inputFormatters,
            maxLength: widget.maxLength,
            validator: widget.validator,
            style: const TextStyle(
              fontFamily: 'TTNorms',
              fontWeight: FontWeight.w400,
              fontSize: 20,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 55,
                vertical: 23,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(41.0),
                borderSide: const BorderSide(
                  color: Colors.transparent,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(41.0),
                borderSide: const BorderSide(
                  color: Colors.transparent,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(41),
                borderSide: const BorderSide(
                  color: Colors.red,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(41),
                borderSide: const BorderSide(
                  color: Colors.red,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(41),
                borderSide: const BorderSide(
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
