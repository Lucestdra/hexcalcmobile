/// Expression grammar & integer evaluation — Dart twin of the C# domain.
///
/// Must produce identical results to the backend and to the evaluator/v1 and
/// grammar/v1 golden fixtures. See the backend spec
/// docs/gameplay/expression-evaluation.md.
library;

/// MVP binary operators. Carried as an enum, never a glyph.
enum Operator { add, subtract, multiply, divide }

enum TokenKind { number, operator, equals }

/// A single equation token.
class Token {
  const Token._(this.kind, this.numberValue, this.operatorValue);

  final TokenKind kind;

  /// Meaningful only when [kind] is [TokenKind.number].
  final int numberValue;

  /// Meaningful only when [kind] is [TokenKind.operator].
  final Operator? operatorValue;

  factory Token.number(int value) => Token._(TokenKind.number, value, null);

  factory Token.op(Operator op) => Token._(TokenKind.operator, 0, op);

  static const Token equals = Token._(TokenKind.equals, 0, null);
}

/// Grammar error codes (docs/gameplay/expression-evaluation.md §3.2).
class GrammarErrorCodes {
  GrammarErrorCodes._();

  static const String empty = 'EMPTY';
  static const String equalsMissing = 'EQUALS_MISSING';
  static const String equalsMultiple = 'EQUALS_MULTIPLE';
  static const String resultMissing = 'RESULT_MISSING';
  static const String resultMultiple = 'RESULT_MULTIPLE';
  static const String resultNotNumber = 'RESULT_NOT_NUMBER';
  static const String leftEmpty = 'LEFT_EMPTY';
  static const String mustStartWithNumber = 'MUST_START_WITH_NUMBER';
  static const String consecutiveOperators = 'CONSECUTIVE_OPERATORS';
  static const String consecutiveNumbers = 'CONSECUTIVE_NUMBERS';
  static const String operatorMissingOperand = 'OPERATOR_MISSING_OPERAND';
  static const String noOperator = 'NO_OPERATOR';
}

/// Arithmetic error codes (docs/gameplay/expression-evaluation.md §4.4).
class ArithmeticErrorCodes {
  ArithmeticErrorCodes._();

  static const String divisionByZero = 'DIVISION_BY_ZERO';
  static const String divisionNotExact = 'DIVISION_NOT_EXACT';
  static const String negativeIntermediate = 'NEGATIVE_INTERMEDIATE';
  static const String overflow = 'OVERFLOW';
}

/// Result of grammar validation. [equalsIndex] is only meaningful when valid.
class GrammarValidation {
  const GrammarValidation(this.isValid, this.errorCode, this.equalsIndex);

  final bool isValid;
  final String? errorCode;
  final int equalsIndex;

  static GrammarValidation ok(int equalsIndex) =>
      GrammarValidation(true, null, equalsIndex);

  static GrammarValidation fail(String code) =>
      GrammarValidation(false, code, -1);
}

/// Validates a token stream against `number (operator number)+ equals number`.
/// Deterministic, first-failure-wins, exact check order of the spec §3.1.
class EquationGrammar {
  EquationGrammar._();

  static GrammarValidation validate(List<Token> tokens) {
    // 1. Empty.
    if (tokens.isEmpty) {
      return GrammarValidation.fail(GrammarErrorCodes.empty);
    }

    // 2. Count equals tokens.
    int equalsCount = 0;
    int equalsIndex = -1;
    for (int i = 0; i < tokens.length; i++) {
      if (tokens[i].kind == TokenKind.equals) {
        equalsCount++;
        if (equalsIndex < 0) {
          equalsIndex = i;
        }
      }
    }

    if (equalsCount == 0) {
      return GrammarValidation.fail(GrammarErrorCodes.equalsMissing);
    }
    if (equalsCount > 1) {
      return GrammarValidation.fail(GrammarErrorCodes.equalsMultiple);
    }

    // 3. Split at the single equals.
    final int lhsLength = equalsIndex;
    final int rhsLength = tokens.length - equalsIndex - 1;

    // 4. Validate RHS: exactly one number.
    if (rhsLength == 0) {
      return GrammarValidation.fail(GrammarErrorCodes.resultMissing);
    }
    if (rhsLength > 1) {
      return GrammarValidation.fail(GrammarErrorCodes.resultMultiple);
    }
    if (tokens[equalsIndex + 1].kind != TokenKind.number) {
      return GrammarValidation.fail(GrammarErrorCodes.resultNotNumber);
    }

    // 5. Validate LHS: number (operator number)+
    if (lhsLength == 0) {
      return GrammarValidation.fail(GrammarErrorCodes.leftEmpty);
    }

    for (int p = 0; p < lhsLength; p++) {
      final bool expectNumber = p % 2 == 0;
      final TokenKind kind = tokens[p].kind;

      if (expectNumber && kind != TokenKind.number) {
        return GrammarValidation.fail(
          p == 0
              ? GrammarErrorCodes.mustStartWithNumber
              : GrammarErrorCodes.consecutiveOperators,
        );
      }

      if (!expectNumber && kind != TokenKind.operator) {
        return GrammarValidation.fail(GrammarErrorCodes.consecutiveNumbers);
      }
    }

    if (lhsLength % 2 == 0) {
      return GrammarValidation.fail(GrammarErrorCodes.operatorMissingOperand);
    }
    if (lhsLength == 1) {
      return GrammarValidation.fail(GrammarErrorCodes.noOperator);
    }

    return GrammarValidation.ok(equalsIndex);
  }
}

/// Explicit overflow predicates for non-negative 64-bit integers, identical to
/// the C# `CheckedMath`. Dart native `int` is 64-bit two's complement and wraps
/// silently on overflow, so these predicates (not exceptions) are the contract.
/// See docs/gameplay/expression-evaluation.md §4.1.
class CheckedMath {
  CheckedMath._();

  /// Int64.MaxValue.
  static const int maxInt = 9223372036854775807;

  static bool addOverflows(int a, int b) => b > maxInt - a;

  static bool mulOverflows(int a, int b) => a != 0 && b > maxInt ~/ a;
}

/// The four mutually exclusive outcomes of evaluating a token stream.
enum EquationStatus { valid, grammarError, arithmeticError, resultMismatch }

/// The combined evaluation result. See the spec §5 for exactly which fields are
/// populated per status.
class EquationResult {
  const EquationResult(
    this.status,
    this.errorCode,
    this.leftHandValue,
    this.resultValue,
  );

  final EquationStatus status;
  final String? errorCode;
  final int? leftHandValue;
  final int? resultValue;

  bool get isValid => status == EquationStatus.valid;
}

/// The single evaluation entry point. Validates grammar, evaluates the LHS with
/// standard precedence and integer semantics, then compares to the result token.
class EquationEvaluator {
  EquationEvaluator._();

  static EquationResult evaluate(List<Token> tokens) {
    final GrammarValidation grammar = EquationGrammar.validate(tokens);
    if (!grammar.isValid) {
      return EquationResult(
        EquationStatus.grammarError,
        grammar.errorCode,
        null,
        null,
      );
    }

    final int equalsIndex = grammar.equalsIndex;
    final int resultValue = tokens[equalsIndex + 1].numberValue;

    // Pass 1 — resolve * and / left to right into additive terms.
    final List<int> terms = <int>[tokens[0].numberValue];
    final List<Operator> addOps = <Operator>[];

    for (int p = 1; p < equalsIndex; p += 2) {
      final Operator op = tokens[p].operatorValue!;
      final int n = tokens[p + 1].numberValue;

      switch (op) {
        case Operator.multiply:
          final int last = terms[terms.length - 1];
          if (CheckedMath.mulOverflows(last, n)) {
            return EquationResult(
              EquationStatus.arithmeticError,
              ArithmeticErrorCodes.overflow,
              null,
              resultValue,
            );
          }
          terms[terms.length - 1] = last * n;
        case Operator.divide:
          if (n == 0) {
            return EquationResult(
              EquationStatus.arithmeticError,
              ArithmeticErrorCodes.divisionByZero,
              null,
              resultValue,
            );
          }
          final int last = terms[terms.length - 1];
          if (last % n != 0) {
            return EquationResult(
              EquationStatus.arithmeticError,
              ArithmeticErrorCodes.divisionNotExact,
              null,
              resultValue,
            );
          }
          terms[terms.length - 1] = last ~/ n;
        case Operator.add:
        case Operator.subtract:
          addOps.add(op);
          terms.add(n);
      }
    }

    // Pass 2 — resolve + and - left to right, checking negative-intermediate.
    int acc = terms[0];
    for (int k = 0; k < addOps.length; k++) {
      final int t = terms[k + 1];
      if (addOps[k] == Operator.add) {
        if (CheckedMath.addOverflows(acc, t)) {
          return EquationResult(
            EquationStatus.arithmeticError,
            ArithmeticErrorCodes.overflow,
            null,
            resultValue,
          );
        }
        acc += t;
      } else {
        if (t > acc) {
          return EquationResult(
            EquationStatus.arithmeticError,
            ArithmeticErrorCodes.negativeIntermediate,
            null,
            resultValue,
          );
        }
        acc -= t;
      }
    }

    return acc == resultValue
        ? EquationResult(EquationStatus.valid, null, acc, resultValue)
        : EquationResult(EquationStatus.resultMismatch, null, acc, resultValue);
  }
}
