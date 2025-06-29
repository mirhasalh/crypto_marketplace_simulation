const Map<String, Map<String, String>> kSymbols = {
  'BTCUSDT': {'short': 'btc', 'separated': 'BTC/USDT'},
  'BNBUSDT': {'short': 'bnb', 'separated': 'BNB/USDT'},
  'ETHUSDT': {'short': 'eth', 'separated': 'ETH/USDT'},
  'XRPUSDT': {'short': 'xrp', 'separated': 'XRP/USDT'},
  'SOLUSDT': {'short': 'sol', 'separated': 'SOL/USDT'},
};

// Topics to stream
// const kTopics = [
//   'btcusdt@markPrice',
//   'bnbusdt@markPrice',
//   'ethusdt@markPrice',
//   'xrpusdt@markPrice',
//   'solusdt@markPrice',
// ];

// General recommendation for klines
const Map<String, Map<String, int>> kIntervals = {
  '5m': {'range': 1, 'limit': 168, 'durations': 300},
  '1h': {'range': 7, 'limit': 288, 'durations': 900},
  '15m': {'range': 3, 'limit': 288, 'durations': 3600},
  '1d': {'range': 90, 'limit': 90, 'durations': 86400},
};

// Not all cryptocurrencies support streaming. Use kAvailablePairs to
// generate streaming topics.
const Map<String, Map<String, String>> kCryptos = {
  'usdt': {'image': 'img/tether.webp', 'name': 'USDT', 'hex': '419293'},
  'btc': {'image': 'img/bitcoin.webp', 'name': 'Bitcoin', 'hex': 'ea983d'},
  'bnb': {'image': 'img/binancecoin.webp', 'name': 'BNB', 'hex': 'e8bb41'},
  'eth': {'image': 'img/ethereum.webp', 'name': 'Ethereum', 'hex': '8c93af'},
  'xrp': {'image': 'img/ripple.webp', 'name': 'XRP', 'hex': '005bcc'},
  'sol': {'image': 'img/solana.webp', 'name': 'Solana', 'hex': '8f4af2'},
};

const Map<String, Map<String, String>> kAvailablePairs = {
  'btc': {'image': 'img/bitcoin.webp', 'name': 'Bitcoin'},
  'bnb': {'image': 'img/binancecoin.webp', 'name': 'BNB'},
  'eth': {'image': 'img/ethereum.webp', 'name': 'Ethereum'},
  'xrp': {'image': 'img/ripple.webp', 'name': 'XRP'},
  'sol': {'image': 'img/solana.webp', 'name': 'Solana'},
};

const kNames = [
  'Satoshi Nakamoto',
  'Hal Finney',
  'Nick Szabo',
  'Gavin Andresen',
  'Andreas M. Antonopoulos',
  'Roger Ver',
  'Craig Wright',
  'Adam Back',
  'Charlie Shrem',
  'Ross Ulbricht',
  'Vitalik Buterin',
];

const kKeyboardKeys = '1:2:3:4:5:6:7:8:9:.:0:b';

const kLgBtnHeight = 43.0;
