import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'create_account_page_state.dart';
import 'home_page_state.dart';

class CreateAccountPage extends StatefulWidget {
  static const routeName = '/create-account';

  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  var nameController = TextEditingController();
  var fundsController = TextEditingController();
  String _selectedFunds = '';

  @override
  void dispose() {
    nameController.dispose();
    fundsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.createAccount)),
      body: SingleChildScrollView(
        child: Container(
          color: colors.surface,
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      label: Text('Full name'),
                      hintText: 'Satoshi Nakamoto',
                    ),
                    keyboardType: TextInputType.name,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(height: 12.0),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text('Suggested funds'),
                ),
                const SizedBox(height: 4.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Wrap(
                    spacing: 8.0,
                    children: kFunds
                        .map(
                          (e) => ChoiceChip(
                            label: Text(threeDigitStringSeparator(e)),
                            selected: e == _selectedFunds,
                            onSelected: (_) => _onSelected(e),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 12.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: TextFormField(
                    controller: fundsController,
                    decoration: const InputDecoration(
                      label: Text('Funds'),
                      hintText: '1000.0',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _onFundsChanged(),
                  ),
                ),
                const SizedBox(height: 12.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onFundsChanged() {
    if (_selectedFunds != '') setState(() => _selectedFunds = '');
  }

  void _onSelected(String str) {
    setState(() => _selectedFunds = str);
  }
}
