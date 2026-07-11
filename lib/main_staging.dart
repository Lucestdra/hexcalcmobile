import 'app/bootstrap.dart';
import 'app/flavors/flavor_config.dart';

/// Staging flavor entrypoint: `flutter run -t lib/main_staging.dart`.
void main() => bootstrap(FlavorConfig.staging);
