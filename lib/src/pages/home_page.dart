import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

import '../../environments.dart';
import '../apis.dart';
import '../constants.dart';
import '../database/database.dart';
import '../l10n/app_localizations.dart';
import '../models/mark_price.dart';
import '../shared/allocations.dart';
import '../shared/asset_list_tile.dart';
import '../shared/divider_bar.dart';
import '../shared/mark_price_tile.dart';
import '../shared/txn_actions.dart';
import '../shared/user_portfolio_button.dart';
import '../typedefs.dart';
import 'trade_page.dart' show TradePageArgs;
import 'home_page_state.dart';

class NavPage extends StatefulWidget {
  static const routeName = '/home';

  const NavPage({
    super.key,
    required this.latestKnownPrices,
    required this.user,
  });

  final List<String> latestKnownPrices;
  final User user;

  @override
  State<NavPage> createState() => _NavPageState();
}

class _NavPageState extends State<NavPage> {
  final GlobalKey _sliverListKey = GlobalKey();

  late List<String> _topics; // [btcusdt@markPrice, bnbusdt@markPrice]
  late PageController _pageViewController;
  late User _user;
  late SliverObserverController _observerController;
  late WebSocketChannel _channel;
  late Map<String, List<dynamic>> _klines;
  late DateTime _openTime;

  BuildContext? _sliverListCtx;
  ScrollController scrollController = ScrollController();
  List<MarkPrice> _prices = [];
  List<String> _knownPrices = [];
  bool _updateLatestKnownPricesOnce = false;
  int _currentPageIndex = 0;
  int touchedIndex = -1;
  // Caches the index of the last fetched price from klines.
  // Used as a guard clause to avoid redundant processing.
  final List<int> _fetchedIndexes = [];

  final List<String> _incomingSymbols = [];

  @override
  void initState() {
    super.initState();

    _knownPrices = widget.latestKnownPrices;
    _topics = getTopics(kAvailablePairs);
    _prices = initMarkPrices(_topics, _knownPrices);
    _klines = initKlines(_topics);

    _pageViewController = PageController();
    _observerController = SliverObserverController(
      controller: scrollController,
    );

    var uri = Uri.parse(
      '$kWssBaseUrl/stream?streams=${_topics.reversed.join('/')}',
    );
    if (kIsWeb) {
      _channel = WebSocketChannel.connect(uri);
    } else {
      _channel = IOWebSocketChannel.connect(uri);
    }

    ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((_) {
      _observerController.dispatchOnceObserve(sliverContext: _sliverListCtx!);
    });

    // Start by fetching APIs to populate the first five items in the list.
    // Then, use a scroll observer to load data for any new items that come
    // into view and remain unpopulated.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _onChildIndex(List.generate(kAvailablePairs.length, (i) => i));
    });

    _user = widget.user;
    _openTime = DateTime.now();
  }

  @override
  void dispose() {
    _channel.sink.close();
    _observerController.controller?.dispose();
    _pageViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final buttonStyle = TextButton.styleFrom(
      backgroundColor: colors.onSurface,
      foregroundColor: colors.surface,
    );

    return StreamBuilder(
      stream: _channel.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData && _prices.isNotEmpty && _klines.isNotEmpty) {
          final decoded = json.decode(snapshot.data);
          final data = MarkPrice.fromJson(decoded['data']);
          _onTick(data);
        }

        return Scaffold(
          body: PageView(
            controller: _pageViewController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              SliverViewObserver(
                controller: _observerController,
                sliverContexts: () {
                  return [if (_sliverListCtx != null) _sliverListCtx!];
                },
                onObserveAll: (resultMap) async {
                  final resMap = resultMap[_sliverListCtx];
                  if (resMap != null &&
                      resMap.visible &&
                      resMap is ListViewObserveModel) {
                    await _onChildIndex(resMap.displayingChildIndexList);
                  }
                },
                child: CustomScrollView(
                  slivers: [
                    const SliverAppBar.large(title: Text('Market')),
                    SliverList(
                      key: _sliverListKey,
                      delegate: SliverChildBuilderDelegate((context, i) {
                        _sliverListCtx ??= context;
                        final s = _prices[i].symbol!;

                        return MarkPriceTile(
                          onPressed: () => _onMarkPriceTile(
                            _prices[i],
                            getPrices(_klines[s]!),
                          ),
                          fillColor: Theme.of(context).colorScheme.surface,
                          asset: getAsset(_prices[i]),
                          subtitle: getCurrentPrice(_prices[i].estSettlePrice!),
                          title: kCryptos[kSymbols[s]!['short']!]!['name']!,
                          prices: getPrices(_klines[s]),
                          badgeText: getBadgeText(_klines[s]),
                          isBearish: isBearish(_klines[s]),
                        );
                      }, childCount: _prices.length),
                    ),
                  ],
                ),
              ),
              CustomScrollView(
                slivers: [
                  SliverAppBar.large(
                    title: UserPortfolioButton(onPressed: () {}, user: _user),
                    actions: [
                      Visibility(
                        visible: widget.user.name.isEmpty,
                        replacement: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.more_vert),
                        ),
                        child: TextButton(
                          style: buttonStyle,
                          onPressed: () => _toCreate(),
                          child: Text(l10n.createAccount),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        TxnActions(
                          onDeposit: () => _onDeposit(),
                          onWithdraw: () => _onWithdraw(),
                        ),
                        const Divider(height: 0.0),
                        const DividerBar(title: 'Allocations'),
                        _ConstrainedAllocations(
                          touchCallback: _onTouchCallback,
                          user: widget.user,
                          touchedIndex: touchedIndex,
                        ),
                        const Divider(height: 0.0),
                        const DividerBar(title: 'Assets'),
                      ],
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, i) {
                      final c = kCryptos.keys.map((key) => key).toList();
                      final s = '${c[i].toUpperCase()}USDT';
                      final p = c[i] == 'usdt'
                          ? '0.0'
                          : '${_klines[s]![_klines[s]!.length - 1][4]}';

                      return AssetListTile(
                        onPressed: () {},
                        asset: kCryptos[c[i]]!['image']!,
                        short: c[i].toUpperCase(),
                        name: kCryptos[c[i]]!['name']!,
                        amount: getAssetAmount(c[i], _user.portfolio),
                        value: getAssetValue(c[i], _user.portfolio, p),
                      );
                    }, childCount: kCryptos.length),
                  ),
                ],
              ),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentPageIndex,
            onDestinationSelected: (i) {
              setState(() {
                _currentPageIndex = i;
                _pageViewController.animateToPage(
                  _currentPageIndex,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              });
            },
            destinations: const <Widget>[
              NavigationDestination(
                selectedIcon: Icon(Icons.line_axis),
                icon: Icon(Icons.line_axis),
                label: 'Market',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.pie_chart),
                icon: Icon(Icons.pie_chart_outline),
                label: 'Portfolio',
              ),
            ],
          ),
        );
      },
    );
  }

  void _onTouchCallback(
    FlTouchEvent event,
    PieTouchResponse? pieTouchResponse,
  ) {
    setState(() {
      if (!event.isInterestedForInteractions ||
          pieTouchResponse == null ||
          pieTouchResponse.touchedSection == null) {
        touchedIndex = -1;
        return;
      }
      touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
    });
  }

  void _toCreate() => Navigator.of(context).pushNamed('/create-account');

  void _onMarkPriceTile(MarkPrice markPrice, List<double> prices) {
    final nav = Navigator.of(context);
    final args = TradePageArgs(markPrice.symbol!, prices, _user);
    if (prices.isNotEmpty) nav.pushNamed('/trade', arguments: args);
  }

  Future<void> _onSymbol(String symbol) async {
    if (_updateLatestKnownPricesOnce) return;

    if (_incomingSymbols.isEmpty) {
      _incomingSymbols.add(symbol);
    } else {
      if (!_incomingSymbols.contains(symbol)) _incomingSymbols.add(symbol);
    }

    if (_incomingSymbols.length == _topics.length) {
      final prefs = await SharedPreferences.getInstance();
      final latestKnownPrices = getPricesStringFromMarkPrices(_prices);
      await prefs.setString('latestKnownPrices', latestKnownPrices);
      _updateLatestKnownPricesOnce = true;
    }
  }

  void _onTick(MarkPrice markPrice) {
    if (mounted) {
      _onSymbol(markPrice.symbol!);

      var i = _prices.indexWhere((v) => v.symbol == markPrice.symbol);
      if (i >= 0) _prices[i] = markPrice;

      final now = DateTime.now();

      final diff = now.difference(_openTime).inSeconds;
      if (diff >= kIntervals['1d']!['durations']!) {
        final newKline = getKlinesFromMarkPrice(markPrice);
        _klines[_prices[i].symbol]!.removeAt(0);
        _klines[_prices[i].symbol]!.add(newKline);
        _openTime = DateTime.now();
      } else {
        final newKline = getKlinesFromMarkPrice(markPrice);
        final lastIndex = _klines[_prices[i].symbol]!.length - 1;
        if (lastIndex > 0) _klines[_prices[i].symbol]![lastIndex] = newKline;
      }
    }
  }

  Future<void> _onChildIndex(List<int> indexes) async {
    final msg = ScaffoldMessenger.of(context);

    for (var i in indexes) {
      if (!_fetchedIndexes.contains(i)) {
        _fetchedIndexes.add(i);
        final symbol = _prices[i].symbol;
        if (_klines[symbol]!.isEmpty) {
          const err = 'Failed to load';
          // TODO: Caching mechanism for klines
          final klines = await fetchKlines(
            symbol!,
            '1d',
            (_) => msg.showSnackBar(const SnackBar(content: Text(err))),
          );
          if (klines.isNotEmpty) _klines[symbol] = klines;
          if (_prices[i].estSettlePrice!.isEmpty) {
            _prices[i].estSettlePrice = klines.last[4];
          }
        }
      }
    }
  }

  void _onDeposit() {
    final msg = ScaffoldMessenger.of(context);
    msg.showSnackBar(const SnackBar(content: Text('Under development')));
  }

  void _onWithdraw() {
    final msg = ScaffoldMessenger.of(context);
    msg.showSnackBar(const SnackBar(content: Text('Under development')));
  }
}

class HomePageArgs {
  const HomePageArgs(this.latestKnownPrices, this.user);

  final List<String> latestKnownPrices;
  final User user;
}

class _ConstrainedAllocations extends StatelessWidget {
  const _ConstrainedAllocations({
    required this.touchCallback,
    required this.user,
    required this.touchedIndex,
  });

  final Function(FlTouchEvent, PieTouchResponse?)? touchCallback;
  final User user;
  final int touchedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(12.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: double.infinity,
          maxWidth: 360.0,
          minHeight: 0.0,
          minWidth: 0.0,
        ),
        child: Allocations(
          touchCallback: touchCallback,
          user: user,
          touchedIndex: touchedIndex,
        ),
      ),
    );
  }
}
