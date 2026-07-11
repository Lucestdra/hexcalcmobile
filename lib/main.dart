import 'app/bootstrap.dart';
import 'app/flavors/flavor_config.dart';

/// Default entrypoint (`flutter run` with no `-t`). Mirrors the development
/// flavor so a plain run still works; CI and stores use the explicit
/// `main_<flavor>.dart` entrypoints.
void main() => bootstrap(FlavorConfig.development);
