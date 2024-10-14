import 'package:decimal/decimal.dart';

class DecimalBigIntConverter {
  static const int usdcDecimals = 6;
  static BigInt scaleFactor = BigInt.from(10).pow(usdcDecimals);

  //Smart contracts take in e.g. 10.00 = 1000
  static const int twoDecimalPrecision = 2;
  static BigInt tdpScaleFactor = BigInt.from(10).pow(twoDecimalPrecision);

  static BigInt decimalToUsdcUnit(Decimal decimal) {
    return (decimal * Decimal.fromBigInt(scaleFactor)).toBigInt();
  }

  static BigInt decimalToBigInt(Decimal decimal) {
    return (decimal * Decimal.fromBigInt(tdpScaleFactor)).toBigInt();
  }

  static Decimal bigIntToDecimal(BigInt bigInt) {
    return (Decimal.fromBigInt(bigInt) / Decimal.fromBigInt(scaleFactor))
        .toDecimal();
  }
}
