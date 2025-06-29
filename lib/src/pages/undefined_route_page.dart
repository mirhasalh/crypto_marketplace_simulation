import 'package:flutter/material.dart';

class UndefinedRoutePage extends StatelessWidget {
  const UndefinedRoutePage({super.key, required this.routeName});

  final String routeName;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Text.rich(
          TextSpan(
            text: 'Undefined route: ',
            children: [
              TextSpan(
                text: routeName,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
