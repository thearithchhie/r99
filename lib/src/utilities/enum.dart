enum StorageBox {
  announcement,
  aboutUS,
  contactUS,
  privacyPolicy,
  logsResponse,
  logsSocket,
  logsRoute,
  generalBox,
  countryCode,
  banksList,
  authBox(true),
  appBox,
  homeTransaction;

  const StorageBox([this.inEncrypt = false]);

  final bool inEncrypt;
}

enum KeyboardType { normal, number, double }

enum CurrencyType {
  usd(title: 'US Dollar', symbol: '\$', path: '', currentCode: "USD"),
  khr(title: 'Khmer Riel', symbol: '៛', path: '', currentCode: "KHR");

  const CurrencyType({required this.title, required this.path, required this.symbol, required this.currentCode});

  final String title;
  final String path;
  final String symbol;
  final String currentCode;

  static CurrencyType get fallback => CurrencyType.usd;

  static CurrencyType fromRawPrice(String rawPrice) {
    final trimmed = rawPrice.trim();

    for (final currency in CurrencyType.values) {
      if (trimmed.startsWith(currency.symbol)) {
        return currency;
      }
    }

    return fallback;
  }
}

enum ColumMapHeader {
  shop(key: 'shop', value: 'Shop'),
  customername(key: 'customername', value: 'Customer Name'),
  phone(key: 'phone', value: 'Phone'),
  location(key: 'location', value: 'Location'),
  totalprice(key: 'totalprice', value: 'Total Price'),
  deliverService(key: 'deliver_service', value: 'Deliver Service');

  const ColumMapHeader({required this.key, required this.value});

  final String key;
  final String value;
}
