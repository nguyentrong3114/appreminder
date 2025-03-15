import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  final bool loading;

  const Loading(this.loading, {super.key});

  @override
  Widget build(BuildContext context) {
    return loading 
        ? const CircularProgressIndicator() 
        : const Text("hi");
  }
}
