import 'app/bootstrap.dart';
import 'app/flavors/flavor_config.dart';

/// Production flavor entrypoint: `flutter run -t lib/main_production.dart`.
void main() => bootstrap(FlavorConfig.production);
