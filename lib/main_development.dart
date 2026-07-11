import 'app/bootstrap.dart';
import 'app/flavors/flavor_config.dart';

/// Development flavor entrypoint: `flutter run -t lib/main_development.dart`.
void main() => bootstrap(FlavorConfig.development);
