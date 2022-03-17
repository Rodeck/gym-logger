import 'package:flutter/material.dart';

class FormInput extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  bool? isPassword = false;

  FormInput(this.label, this.hint, this.controller, {this.isPassword});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
          hintText: hint,
        ),
        obscureText: isPassword ?? false,
        controller: controller,
        // The validator receives the text that the user has entered.
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
      ),
    );
  }
}
