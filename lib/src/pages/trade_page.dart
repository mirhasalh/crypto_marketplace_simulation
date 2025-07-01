import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../color_palette.dart';
import '../extensions.dart';
import '../constants.dart';
import '../database/database.dart';
import '../database_service.dart';
import '../provider/providers.dart' show webSocketProvider;
import '../shared/custom_line_chart.dart';
import '../shared/num_pad.dart';
import 'home_page_state.dart';
import 'trade_page_state.dart';

const Map<TradeType, String> tradeDescriptions = {
  TradeType.buy: 'Buy crypto with your currency',
  TradeType.sell: 'Sell crypto to your currency',
};

const Map<TradeType, String> confirmationTitles = {
  TradeType.buy: 'Buy confirmation',
  TradeType.sell: 'Sell confirmation',
};

// Timer interval
const interval = Duration(seconds: 1);
// Animate to page duration and curve
const dur = Duration(milliseconds: 200);
const curve = Curves.ease;

class TradePage extends ConsumerStatefulWidget {
  static const routeName = '/trade';

  const TradePage({
    super.key,
    required this.symbol,
    required this.prices,
    required this.user,
  });

  final String symbol;
  final List<double> prices;
  final User user;

  @override
  ConsumerState<TradePage> createState() => _TradePageState();
}

class _TradePageState extends ConsumerState<TradePage> {
  late List<double> _prices;
  late DateTime _openTime;
  late DateTime _tradeTime;
  late User _user;
  late PageController _controller;

  // Use '1d' to match the interval of the previous page for a smooth
  // transition.
  final String _interval = '1d';

  bool _tradeModalOpen = false;
  bool _processing = false;
  String _atPrice = ''; // To contain both trade type buy/sell
  String _amount = '';
  int _pageIndex = 0; // Trading modal page index
  int _counter = 0; // A counter for an auto confirm countdown
  TradeType _tradeType = TradeType.buy;

  @override
  void initState() {
    super.initState();

    _openTime = DateTime.now();

    _prices = widget.prices;

    _user = widget.user;

    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stream = ref.watch(webSocketProvider);
    final short = kSymbols[widget.symbol]!['short']!.toUpperCase();

    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasData && mounted) {
          final decoded = json.decode(snapshot.data!);
          if (widget.symbol == decoded['data']['s']) {
            final p = double.parse('${decoded['data']['p']}');
            if (mounted) _onTick(p);
          }
        }

        return Scaffold(
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar.large(
                    title: _TradeTitle(
                      title: moneyFormatter('${_prices.last}'),
                      subtitle: kSymbols[widget.symbol]!['separated']!,
                    ),
                    actions: [
                      _DeltaText(prices: _prices),
                      const SizedBox(width: 12.0),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      color: Theme.of(context).colorScheme.surface,
                      padding: const EdgeInsets.all(24),
                      child: CustomLineChart(
                        prices: _prices,
                        isBearish: _prices.last < _prices.secondLast,
                      ),
                    ),
                  ),
                ],
              ),
              _PositionedTradeModal(
                top: _tradeModalOpen ? 0.0 : MediaQuery.of(context).size.height,
                controller: _controller,
                onPageChanged: (i) => setState(() => _pageIndex = i),
                children: [
                  _TradeAmount(
                    tradeType: _tradeType,
                    onTopBarLeadingAction: () => _onClose(),
                    topBarLeadingIcon: Icons.close,
                    title: getComparison(widget.symbol, _prices.last),
                    symbol: short,
                    subtitle: getTradeHint(short, _tradeType, _user.portfolio),
                    amount: _amount,
                    onKey: _onKey,
                    onProceed: _amount.isEmpty ? null : () => _onProceed(),
                  ),
                  _TradeConfirmation(
                    tradeType: _tradeType,
                    onTopBarLeadingAction: () => _onCancel(),
                    topBarLeadingIcon: Icons.arrow_back,
                    title: confirmationTitles[_tradeType]!,
                    symbol: short,
                    amount: _amount,
                    processing: _processing,
                    buyPrice: _atPrice,
                    balance: _user.balanceUSD,
                    counter: '$_counter',
                    onConfirm: _processing ? null : () => _onConfirm(),
                  ),
                ],
              ),
            ],
          ),
          floatingActionButton: _tradeModalOpen
              ? const SizedBox.shrink()
              : FloatingActionButton.extended(
                  onPressed: () => _onTrade(),
                  label: const Text('Trade'),
                ),
        );
      },
    );
  }

  void _onKey(String key) {
    setState(() {
      if (key == 'b') {
        if (_amount.isNotEmpty) {
          _amount = _amount.substring(0, _amount.length - 1);
        }
      } else if (RegExp(r'^[0-9.]$').hasMatch(key)) {
        if (key == '.' && _amount.contains('.')) {
          return;
        }

        _amount += key;

        double value = double.tryParse(_amount) ?? 0;
        if (value < 0.5) {
          _amount = '0.5';
        } else if (value > 100) {
          _amount = '100';
        }
      }
    });
  }

  void _onProceed() {
    if (_tradeType == TradeType.sell) {
      // Owned asset symbols
      var owned = <String>[];
      owned = _user.portfolio.split(',').map((e) => e.split(':')[0]).toList();
      if (!owned.contains(kSymbols[widget.symbol]!['short'])) {
        const emptyAsset = 'Asset isn\'t available';
        final msg = ScaffoldMessenger.of(context);
        msg.showSnackBar(const SnackBar(content: Text(emptyAsset)));
        return;
      }
    }

    _atPrice = '${_prices.last}';
    _controller.animateToPage(1, duration: dur, curve: curve);
    setState(() => _counter = 45);
    Timer.periodic(interval, (timer) {
      if (_processing && _pageIndex == 0) {
        timer.cancel();
      } else {
        if (_counter == 0) {
          timer.cancel();
          _onCancel();
        } else {
          if (mounted) setState(() => _counter -= 1);
        }
      }
    });
  }

  // NOTE: See a note at 'lib/src/database/databases.dart'
  Future<void> _onConfirm() async {
    final msg = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    final db = DatabaseService();

    if (_tradeType == TradeType.buy) {
      var toPay = double.parse(_amount) * double.parse(_atPrice);
      if (double.parse(_user.balanceUSD) >= toPay) {
        setState(() => _processing = true);

        var leftOver = double.parse(_user.balanceUSD) - toPay;

        String e = '';

        var s = kSymbols[widget.symbol]!['short'];

        if (_user.portfolio.isNotEmpty) {
          e = '${_user.portfolio},$s:$_amount:$_atPrice';
        } else {
          e = '$s:$_amount:$_atPrice';
        }

        await db.updateUser(
          User(
            id: _user.id,
            name: _user.name,
            balanceUSD: '${max(0.0, leftOver).toDouble()}',
            portfolio: e,
          ),
        );
        nav.pushNamedAndRemoveUntil('/', (_) => false);
      } else {
        _controller.animateToPage(0, duration: dur, curve: curve);
        msg.showSnackBar(const SnackBar(content: Text('Insufficent balance')));
      }
    } else {
      const emptyAsset = 'Asset isn\'t available';
      if (_user.portfolio.isEmpty) {
        _controller.animateToPage(0, duration: dur, curve: curve);
        msg.showSnackBar(const SnackBar(content: Text(emptyAsset)));
      } else {
        setState(() => _processing = true);
        // Splitted assets example: ['xrp:100.0:2.83', 'sol:3.42:142.74']
        var assets = _user.portfolio.split(',');
        for (var i = 0; i < assets.length; i++) {
          final split = assets[i].split(':');
          if (split[0] == kSymbols[widget.symbol]!['short']!) {
            if (double.parse(_amount) >= double.parse(split[1])) {
              assets.removeAt(i);
            } else {
              var newAmount = double.parse(split[1]) - double.parse(_amount);
              assets[i] = '${split[0]}:$newAmount:$_atPrice';
            }
            break;
          }
        }

        var sellValue = double.parse(_atPrice) * double.parse(_amount);
        var afterSell = double.parse(_user.balanceUSD) + sellValue;

        await db.updateUser(
          User(
            id: _user.id,
            name: _user.name,
            balanceUSD: '$afterSell',
            portfolio: assets.join(','),
          ),
        );

        nav.pushNamedAndRemoveUntil('/', (_) => false);
      }
    }
  }

  void _onClose() {
    setState(() {
      _amount = '';
      _tradeModalOpen = false;
    });
  }

  void _onCancel() {
    if (_processing) return;
    _controller.animateToPage(0, duration: dur, curve: curve);
  }

  void _onTrade() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          children: List.generate(TradeType.values.length, (i) {
            return ListTile(
              onTap: () => _onSelectTradeType(TradeType.values[i]),
              title: Text(TradeType.values[i].name.toUpperCase()),
              subtitle: Text(tradeDescriptions[TradeType.values[i]]!),
              leading: Icon(
                TradeType.values[i] == TradeType.buy
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
              ),
            );
          }),
        );
      },
    );
  }

  void _onSelectTradeType(TradeType tradeType) {
    setState(() {
      _tradeTime = DateTime.now();
      _tradeModalOpen = true;
      _tradeType = tradeType;
      Navigator.of(context).pop();
    });
  }

  void _onTick(double price) {
    final diff = DateTime.now().difference(_openTime).inSeconds;
    if (diff >= kIntervals[_interval]!['durations']!) {
      _prices.removeAt(0);
      _prices.add(price);
    } else {
      if (_tradeModalOpen) {
        if (DateTime.now().difference(_tradeTime).inSeconds >= 60) {
          _prices.last = price;
          _tradeTime = DateTime.now();
        }
      } else {
        if (price != _prices.last) _prices.last = price;
      }
    }
  }
}

class TradePageArgs {
  const TradePageArgs(this.symbol, this.prices, this.user);

  final String symbol;
  final List<double> prices;
  final User user;
}

class _TradeModalBar extends StatelessWidget {
  const _TradeModalBar({
    required this.onAction,
    required this.title,
    required this.actionIcon,
  });

  final VoidCallback onAction;
  final IconData actionIcon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(onPressed: onAction, icon: Icon(actionIcon)),
          Text(title),
          const SizedBox(width: 40.0),
        ],
      ),
    );
  }
}

class _Amount extends StatelessWidget {
  const _Amount({required this.amount, required this.symbol});

  final String amount;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Text.rich(
      TextSpan(
        text: amount.isEmpty ? '0' : amount,
        style: textTheme.displaySmall,
        children: [TextSpan(text: ' $symbol', style: textTheme.titleMedium)],
      ),
    );
  }
}

class _ConstrainedButton extends StatelessWidget {
  const _ConstrainedButton({required this.onPressed, required this.title});

  final VoidCallback? onPressed;
  final String title;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: double.infinity,
        maxWidth: 300.0,
        minHeight: 0.0,
        minWidth: 0.0,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 16.0),
        child: SizedBox(
          width: double.infinity,
          height: kLgBtnHeight,
          child: FilledButton(
            onPressed: onPressed,
            child: Text(
              title,
              style: textTheme.titleMedium!.copyWith(
                color: onPressed == null ? colors.surface : colors.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WillTrade extends StatelessWidget {
  const _WillTrade({
    required this.amount,
    required this.price,
    required this.tradeType,
  });

  final String amount;
  final String price;
  final TradeType tradeType;

  @override
  Widget build(BuildContext context) {
    final t = double.parse(amount) * double.parse(price);
    var verb = tradeType == TradeType.buy ? 'pay' : 'get';
    return Text('You\'ll $verb ${moneyFormatter('$t')}');
  }
}

class _PositionedTradeModal extends StatelessWidget {
  const _PositionedTradeModal({
    required this.top,
    required this.controller,
    required this.onPageChanged,
    this.children,
  });

  final double top;
  final PageController controller;
  final Function(int) onPageChanged;
  final List<Widget>? children;
  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      top: top,
      duration: dur,
      curve: curve,
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Theme.of(context).colorScheme.surface,
        child: PageView(
          controller: controller,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (i) => onPageChanged(i),
          children: children!,
        ),
      ),
    );
  }
}

class _TradeAmount extends StatelessWidget {
  const _TradeAmount({
    required this.tradeType,
    required this.onTopBarLeadingAction,
    required this.topBarLeadingIcon,
    required this.title,
    required this.symbol,
    required this.amount,
    required this.onKey,
    this.onProceed,
    required this.subtitle,
  });

  final TradeType tradeType;
  final VoidCallback onTopBarLeadingAction;
  final IconData topBarLeadingIcon;
  final String title;
  final String symbol;
  final String amount;
  final Function(String) onKey;
  final VoidCallback? onProceed;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TradeModalBar(
          onAction: onTopBarLeadingAction,
          actionIcon: topBarLeadingIcon,
          title: title,
        ),
        const Spacer(),
        _Amount(amount: amount, symbol: symbol),
        Text(subtitle),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: NumPad(onKey: (v) => onKey(v)),
        ),
        _ConstrainedButton(
          onPressed: onProceed,
          title: tradeType.name.toUpperCase(),
        ),
      ],
    );
  }
}

class _TradeConfirmation extends StatelessWidget {
  const _TradeConfirmation({
    this.onConfirm,
    required this.tradeType,
    required this.onTopBarLeadingAction,
    required this.topBarLeadingIcon,
    required this.title,
    required this.symbol,
    required this.amount,
    required this.processing,
    required this.buyPrice,
    required this.balance,
    required this.counter,
  });

  final TradeType tradeType;
  final VoidCallback? onConfirm;
  final VoidCallback onTopBarLeadingAction;
  final IconData topBarLeadingIcon;
  final String title;
  final String symbol;
  final String amount;
  final bool processing;
  final String buyPrice;
  final String balance;
  final String counter;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TradeModalBar(
          onAction: onTopBarLeadingAction,
          actionIcon: Icons.arrow_back,
          title: title,
        ),
        if (processing) const LinearProgressIndicator(),
        const SizedBox(height: 60.0),
        _Amount(amount: amount, symbol: symbol),
        _WillTrade(amount: amount, price: buyPrice, tradeType: tradeType),
        const SizedBox(height: 60.0),
        const Divider(height: 0.0),
        ListTile(
          title: const Text('Balance'),
          subtitle: Text(moneyFormatter(balance)),
        ),
        const Spacer(),
        _ConstrainedButton(
          onPressed: onConfirm,
          title: processing ? 'Processing' : 'Confirm (${counter}s)',
        ),
      ],
    );
  }
}

class _DeltaText extends StatelessWidget {
  const _DeltaText({required this.prices});

  final List<double> prices;

  @override
  Widget build(BuildContext context) {
    var isBearish = prices.last < prices.secondLast;

    return Text(
      _getDeltaText(prices.last, prices.secondLast),
      style: TextStyle(color: isBearish ? kFolly : kMint),
    );
  }

  String _getDeltaText(double a, double b) {
    var leading = a < b ? '' : '+';
    return '$leading${(((a - b) / b) * 100).toStringAsFixed(2)}%';
  }
}

class _TradeTitle extends StatelessWidget {
  const _TradeTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: textTheme.titleMedium),
        Text(subtitle, style: textTheme.bodySmall),
      ],
    );
  }
}
