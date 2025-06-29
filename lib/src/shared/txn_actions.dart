import 'package:flutter/material.dart';

class TxnActions extends StatelessWidget {
  const TxnActions({
    super.key,
    required this.onDeposit,
    required this.onWithdraw,
  });

  final VoidCallback onDeposit;
  final VoidCallback onWithdraw;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _LabeledButton(
            onPressed: onDeposit,
            icon: Icons.arrow_upward,
            label: 'Deposit',
          ),
          _LabeledButton(
            onPressed: onWithdraw,
            icon: Icons.arrow_downward,
            label: 'Withdraw',
          ),
        ],
      ),
    );
  }
}

class _LabeledButton extends StatelessWidget {
  const _LabeledButton({
    required this.onPressed,
    required this.label,
    required this.icon,
  });

  final VoidCallback onPressed;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          style: TextButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: colors.primaryContainer,
            foregroundColor: colors.onPrimaryContainer,
          ),
          onPressed: onPressed,
          child: Icon(icon),
        ),
        const SizedBox(height: 4.0),
        Text(label, style: textTheme.titleSmall),
      ],
    );
  }
}
