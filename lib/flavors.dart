enum Flavor {
  oroDevelopment,
  oroProduction,
  smartComm,
}

class F {
  static Flavor? appFlavor;

  static String get name => appFlavor?.name ?? '';

  static String get title {
    switch (appFlavor) {
      case Flavor.oroDevelopment:
        return 'ORO';
      case Flavor.oroProduction:
        return 'ORO';
      case Flavor.smartComm:
        return 'SMART COMM';
      default:
        return 'title';
    }
  }

}

