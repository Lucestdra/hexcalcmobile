import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/features/gameplay/domain/domain.dart';

void main() {
  group('ExpressionEvaluatorV2', () {
    test('uses multiplication precedence before addition', () {
      final ExpressionResultV2 result = ExpressionEvaluatorV2.evaluate(<Token>[
        Token.number(3),
        Token.op(Operator.add),
        Token.number(5),
        Token.op(Operator.multiply),
        Token.number(2),
      ]);

      expect(result.status, ExpressionStatusV2.valid);
      expect(result.value, 13);
    });

    test('supports exact division', () {
      final ExpressionResultV2 result = ExpressionEvaluatorV2.evaluate(<Token>[
        Token.number(8),
        Token.op(Operator.divide),
        Token.number(2),
        Token.op(Operator.add),
        Token.number(3),
      ]);
      expect(result.value, 7);
    });

    test('rejects inexact division and division by zero', () {
      expect(
        ExpressionEvaluatorV2.evaluate(<Token>[
          Token.number(5),
          Token.op(Operator.divide),
          Token.number(2),
        ]).errorCode,
        ArithmeticErrorCodes.divisionNotExact,
      );
      expect(
        ExpressionEvaluatorV2.evaluate(<Token>[
          Token.number(5),
          Token.op(Operator.divide),
          Token.number(0),
        ]).errorCode,
        ArithmeticErrorCodes.divisionByZero,
      );
    });

    test('rejects negative intermediates', () {
      final ExpressionResultV2 result = ExpressionEvaluatorV2.evaluate(<Token>[
        Token.number(3),
        Token.op(Operator.subtract),
        Token.number(5),
        Token.op(Operator.add),
        Token.number(9),
      ]);
      expect(result.status, ExpressionStatusV2.arithmeticError);
      expect(result.errorCode, ArithmeticErrorCodes.negativeIntermediate);
    });

    test('rejects Int64 addition and multiplication overflow', () {
      expect(
        ExpressionEvaluatorV2.evaluate(<Token>[
          Token.number(CheckedMath.maxInt),
          Token.op(Operator.add),
          Token.number(1),
        ]).errorCode,
        ArithmeticErrorCodes.overflow,
      );
      expect(
        ExpressionEvaluatorV2.evaluate(<Token>[
          Token.number(CheckedMath.maxInt),
          Token.op(Operator.multiply),
          Token.number(2),
        ]).errorCode,
        ArithmeticErrorCodes.overflow,
      );
    });

    test('enforces v2 grammar and seven-cell maximum', () {
      expect(
        ExpressionEvaluatorV2.evaluate(<Token>[
          Token.number(1),
          Token.op(Operator.add),
          Token.number(2),
          Token.op(Operator.add),
          Token.number(3),
          Token.op(Operator.add),
          Token.number(4),
          Token.op(Operator.add),
          Token.number(5),
        ]).errorCode,
        ExpressionErrorCodesV2.tooLong,
      );
      expect(
        ExpressionEvaluatorV2.evaluate(<Token>[
          Token.number(1),
          Token.equals,
          Token.number(1),
        ]).errorCode,
        ExpressionErrorCodesV2.equalsNotAllowed,
      );
      expect(
        ExpressionEvaluatorV2.evaluate(<Token>[
          Token.number(-1),
          Token.op(Operator.add),
          Token.number(2),
        ]).errorCode,
        ExpressionErrorCodesV2.negativeNumber,
      );
      expect(
        ExpressionEvaluatorV2.evaluate(<Token>[
          Token.number(1),
          Token.number(2),
          Token.op(Operator.add),
        ]).errorCode,
        ExpressionErrorCodesV2.expectedOperator,
      );
    });

    test('formats a canonical ASCII live expression', () {
      expect(
        ExpressionEvaluatorV2.format(<Token>[
          Token.number(3),
          Token.op(Operator.multiply),
          Token.number(4),
        ]),
        '3 * 4',
      );
    });
  });
}
