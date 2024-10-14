enum Erc20UsdcFunctions {
  allowance,
  approve,
}

extension Erc20UsdcFunctionsExtension on Erc20UsdcFunctions {
  String get functionName {
    switch (this) {
      case Erc20UsdcFunctions.allowance:
        return 'allowance';
      case Erc20UsdcFunctions.approve:
        return 'approve';
      default:
        throw ArgumentError('Invalid function');
    }
  }
}
