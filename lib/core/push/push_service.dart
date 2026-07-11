/// The push-notification seam. FCM is wired in a later phase; the MVP ships a
/// no-op so nothing requests notification permission or a device token yet.
abstract interface class PushService {
  Future<bool> requestPermission();
  Future<String?> retrieveToken();
  Future<void> subscribe(String topic);
}

class NoopPushService implements PushService {
  const NoopPushService();

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<String?> retrieveToken() async => null;

  @override
  Future<void> subscribe(String topic) async {}
}
