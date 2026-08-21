import 'package:r99/export.dart';

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
  deliverService(key: 'deliver_service', value: 'Deliver Service'),
  sticker(key: 'sticker', value: 'Sticker'),
  status(key: 'status', value: 'Status'),
  chatRespondentName(key: 'chat_respondent_name', value: 'Chat Respondent Name'),
  link(key: 'link', value: 'Link'),
  outlet(key: 'outlet', value: 'Outlet'),
  createdBy(key: 'created_by', value: 'Created By');

  const ColumMapHeader({required this.key, required this.value});

  final String key;
  final String value;
}

class StickerValue {
  const StickerValue._();

  static const String ok   = 'ok 👌';
  static const String love = 'love ❤️';
}

class OrderStatus {
  const OrderStatus._();

  static const String alradyPaid = 'ALRADY_PAID';
  static const String padding    = 'PADDING';
}

enum ShopType {
  r99(key: 'key_R99', value: 'R99'),
  r99II(key: 'key_R99_II', value: 'R99-II');

  const ShopType({required this.key, required this.value});

  final String key;
  final String value;

  static ShopType fallback = ShopType.r99;

  static ShopType? fromRaw(String value) {
    final normalized = value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.isEmpty ||
        normalized == ColumMapHeader.shop.key ||
        normalized == 'r99' ||
        normalized == r99.key.toLowerCase()) {
      return r99;
    }
    if (normalized == 'r99-ii' ||
        normalized == 'r99 ii' ||
        normalized == 'r99 2' ||
        normalized == r99II.key.toLowerCase()) {
      return r99II;
    }
    return null;
  }

  static String normalizeKey(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'none') {
      return 'none';
    }
    return fromRaw(value)?.key ?? fallback.key;
  }
}

enum SupabaseAuthErrorCode {
  invalidCredentials(
    key: 'invalid_credentials',
    message: 'Invalid email or password. Please check your credentials and try again.',
  ),
  overEmailSendRateLimit(
    key: 'over_email_send_rate_limit',
    message:
        'Supabase email limit reached. Please wait and try again, or ask admin to create/confirm your account in Supabase.',
  ),
  networkUnavailable(
    key: 'network_unavailable',
    message: 'Cannot connect to Supabase. Please check internet/DNS connection and try again.',
  );

  const SupabaseAuthErrorCode({required this.key, required this.message});

  final String key;
  final String message;

  static SupabaseAuthErrorCode? fromKey(String? key) {
    if (key == null || key.isEmpty) {
      return null;
    }

    for (final code in SupabaseAuthErrorCode.values) {
      if (code.key == key) {
        return code;
      }
    }

    return null;
  }
}

enum FlavorType {
  development(env: EnvDev()),
  staging(env: EnvStg()),
  production(env: EnvPro()),
  local(env: EnvLocal());

  const FlavorType({required this.env});

  final AppEnv env;
}
