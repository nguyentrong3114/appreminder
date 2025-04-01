import 'package:flutter/material.dart';

class CustomPageRoute extends PageRouteBuilder {
  final Widget child;

  CustomPageRoute({required this.child})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          childTransition,
        ) {
          // hiệu ứng trượt từ phải sang trái
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;
          final tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          // return SlideTransition(
          //   position: animation.drive(tween),
          //   child: childTransition,
          // );
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 5000),
      );
}
