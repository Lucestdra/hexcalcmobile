import 'dart:convert';
import 'dart:io';

import 'package:hexcalc/features/gameplay/domain/v2/v2.dart';

void main(List<String> arguments) {
  final String path = arguments.isEmpty
      ? 'assets/gameplay/maps-v1.json'
      : arguments.first;
  try {
    final Map<String, dynamic> json =
        jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
    final CatalogValidationReportV2 report = MapValidatorV2.validateCatalog(
      MapCatalogV1.fromJson(json),
    );
    stdout.writeln(const JsonEncoder.withIndent('  ').convert(report.toJson()));
    if (!report.isValid) {
      exitCode = 1;
    }
  } on Object catch (error) {
    stderr.writeln(
      jsonEncode(<String, dynamic>{
        'catalogVersion': 'maps-v1',
        'valid': false,
        'fatalError': error.toString(),
      }),
    );
    exitCode = 1;
  }
}
