import 'package:flutter/material.dart';

class SlideBottomRoute extends PageRouteBuilder {
  final Widget page;
  SlideBottomRoute({
    required this.page,
    Duration duration = const Duration(milliseconds: 300),
    Duration reverseDuration = const Duration(milliseconds: 300),
  }) : super(
          transitionDuration: duration,
          reverseTransitionDuration: reverseDuration,
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
}

/// That's the one!
class ScaleRoute extends PageRouteBuilder {
  final Widget page;
  ScaleRoute({required this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              ScaleTransition(
            scale: Tween<double>(
              begin: 0.5,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.linearToEaseOut,
              ),
            ),
            child: child,
          ),
        );
}

class SizeRoute extends PageRouteBuilder {
  final Widget page;
  SizeRoute({required this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              Align(
            child: SizeTransition(
              axis: Axis.horizontal,
              sizeFactor: animation,
              child: child,
            ),
          ),
        );
}

class SlideRouteWithCurve extends PageRouteBuilder {
  final Widget page;
  SlideRouteWithCurve({
    required this.page,
    Duration duration = const Duration(milliseconds: 300),
    Duration reverseDuration = const Duration(milliseconds: 300),
  }) : super(
          //transitionDuration: duration,
          //reverseTransitionDuration: reverseDuration,
          pageBuilder: (
            context,
            animation,
            secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.slowMiddle;
            const reverseCurve = Curves.fastOutSlowIn;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            final curvedAnimation = CurvedAnimation(
                parent: animation, curve: curve, reverseCurve: reverseCurve);

            return SlideTransition(
                position: tween.animate(curvedAnimation), child: child);
          },
        );
}
