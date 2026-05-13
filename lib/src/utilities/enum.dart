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
