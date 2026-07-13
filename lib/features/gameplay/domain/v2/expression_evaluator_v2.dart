/// Target-swipe expression grammar and exact Int64 evaluation for `rs-v2`.
library;

import '../expression.dart';

/// Stable v2 grammar failures. Arithmetic failures reuse the canonical
/// [ArithmeticErrorCodes] shared with v1.
class ExpressionErrorCodesV2 {
  ExpressionErrorCodesV2._();

  static const String empty = 'EMPTY';
  static const String tooShort = 'TOO_SHORT';
  static const String tooLong = 'TOO_LONG';
  static const String mustStartWithNumber = 'MUST_START_WITH_NUMBER';
  static const String mustEndWithNumber = 'MUST_END_WITH_NUMBER';
  static const String expectedNumber = 'EXPECTED_NUMBER';
  static const String expectedOperator = 'EXPECTED_OPERATOR';
  static const String equalsNotAllowed = 'EQUALS_NOT_ALLOWED';
  static const String negativeNumber = 'NEGATIVE_NUMBER';
  static const String numberOutOfRange = 'NUMBER_OUT_OF_RANGE';
}

enum ExpressionStatusV2 { valid, grammarError, arithmeticError }

class ExpressionResultV2 {
  const ExpressionResultV2(this.status, this.errorCode, this.value);

  final ExpressionStatusV2 status;
  final String? errorCode;
  final int? value;

  bool get isValid => status == ExpressionStatusV2.valid;
}

/// Evaluates `number (operator number)+` with standard precedence.
///
/// The maximum is seven cells (three binary operations). Division is exact,
/// every intermediate is non-negative, and all arithmetic is bounded by
/// Int64.MaxValue. This class intentionally does not alter the frozen v1
/// [EquationEvaluator].
class ExpressionEvaluatorV2 {
  ExpressionEvaluatorV2._();

  static const int maxCells = 7;

  static ExpressionResultV2 evaluate(List<Token> tokens) {
    final String? grammarError = _validate(tokens);
    if (grammarError != null) {
      return ExpressionResultV2(
        ExpressionStatusV2.grammarError,
        grammarError,
        null,
      );
    }

    // Resolve multiplication and division into additive terms first.
    final List<int> terms = <int>[tokens.first.numberValue];
    final List<Operator> additiveOperators = <Operator>[];

    for (int index = 1; index < tokens.length; index += 2) {
      final Operator operator = tokens[index].operatorValue!;
      final int operand = tokens[index + 1].numberValue;
      switch (operator) {
        case Operator.multiply:
          final int left = terms.last;
          if (CheckedMath.mulOverflows(left, operand)) {
            return const ExpressionResultV2(
              ExpressionStatusV2.arithmeticError,
              ArithmeticErrorCodes.overflow,
              null,
            );
          }
          terms[terms.length - 1] = left * operand;
        case Operator.divide:
          if (operand == 0) {
            return const ExpressionResultV2(
              ExpressionStatusV2.arithmeticError,
              ArithmeticErrorCodes.divisionByZero,
              null,
            );
          }
          final int left = terms.last;
          if (left % operand != 0) {
            return const ExpressionResultV2(
              ExpressionStatusV2.arithmeticError,
              ArithmeticErrorCodes.divisionNotExact,
              null,
            );
          }
          terms[terms.length - 1] = left ~/ operand;
        case Operator.add:
        case Operator.subtract:
          additiveOperators.add(operator);
          terms.add(operand);
      }
    }

    // Addition and subtraction are left-associative. Reject at the exact step
    // an intermediate would become negative, even if a later addition could
    // otherwise make the final value positive.
    int value = terms.first;
    for (int index = 0; index < additiveOperators.length; index++) {
      final int operand = terms[index + 1];
      switch (additiveOperators[index]) {
        case Operator.add:
          if (CheckedMath.addOverflows(value, operand)) {
            return const ExpressionResultV2(
              ExpressionStatusV2.arithmeticError,
              ArithmeticErrorCodes.overflow,
              null,
            );
          }
          value += operand;
        case Operator.subtract:
          if (operand > value) {
            return const ExpressionResultV2(
              ExpressionStatusV2.arithmeticError,
              ArithmeticErrorCodes.negativeIntermediate,
              null,
            );
          }
          value -= operand;
        case Operator.multiply:
        case Operator.divide:
          throw StateError('Multiplicative operator escaped precedence pass');
      }
    }

    return ExpressionResultV2(ExpressionStatusV2.valid, null, value);
  }

  static String? _validate(List<Token> tokens) {
    if (tokens.isEmpty) {
      return ExpressionErrorCodesV2.empty;
    }
    if (tokens.length < 3) {
      return ExpressionErrorCodesV2.tooShort;
    }
    if (tokens.length > maxCells) {
      return ExpressionErrorCodesV2.tooLong;
    }
    for (int index = 0; index < tokens.length; index++) {
      final bool expectsNumber = index.isEven;
      final Token token = tokens[index];
      if (token.kind == TokenKind.equals) {
        return ExpressionErrorCodesV2.equalsNotAllowed;
      }
      if (expectsNumber && token.kind != TokenKind.number) {
        return index == 0
            ? ExpressionErrorCodesV2.mustStartWithNumber
            : ExpressionErrorCodesV2.expectedNumber;
      }
      if (!expectsNumber && token.kind != TokenKind.operator) {
        return ExpressionErrorCodesV2.expectedOperator;
      }
      if (expectsNumber && token.numberValue < 0) {
        return ExpressionErrorCodesV2.negativeNumber;
      }
      if (expectsNumber && token.numberValue > CheckedMath.maxInt) {
        return ExpressionErrorCodesV2.numberOutOfRange;
      }
    }
    return tokens.last.kind == TokenKind.number
        ? null
        : ExpressionErrorCodesV2.mustEndWithNumber;
  }

  static String format(List<Token> tokens) => tokens
      .map((Token token) {
        switch (token.kind) {
          case TokenKind.number:
            return token.numberValue.toString();
          case TokenKind.operator:
            return switch (token.operatorValue!) {
              Operator.add => '+',
              Operator.subtract => '-',
              Operator.multiply => '*',
              Operator.divide => '/',
            };
          case TokenKind.equals:
            return '=';
        }
      })
      .join(' ');
}
