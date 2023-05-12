part of '../helpers.dart';

@pragma("vm:entry-point")
int compareResolvedPlayers(
  ResolvedPlayerData a,
  ResolvedPlayerData b, {
  bool playingFirst = true,
}) {
  if (playingFirst) {
    return a.playerData.state.state.opposite.index
        .compareTo(b.playerData.state.state.opposite.index);
  }
  return a.playerData.state.state.index
      .compareTo(b.playerData.state.state.index);
}

@pragma("vm:entry-point")
Future<Uint8List> convertToJpeg(Uint8List imageData) async {
  final Uint8List result = await compute<Uint8List, Uint8List>(
    (imageData) {
      final imagelib.Image? image = imagelib.decodeImage(imageData);
      if (image == null) {
        throw "Could not decode image";
      }
      final Uint8List jpegImage = imagelib.encodeJpg(image);

      return jpegImage;
    },
    imageData,
  );

  return result;
}

@pragma("vm:entry-point")
String getHashPathForData({
  required Uint8List data,
  String? extension,
  String? prefixPath,
}) {
  final String hash = sha512.convert(data).toString();

  final String filePathWithoutExtension =
      (prefixPath != null) ? path.join(prefixPath, hash) : hash;

  if (extension == null) {
    return filePathWithoutExtension;
  }

  final String finalExtension =
      extension.startsWith(".") ? extension : ".$extension";
  return path.setExtension(filePathWithoutExtension, finalExtension);
}

@pragma("vm:entry-point")
Future<String> getHashPathForFile({
  required File file,
  String? prefixPath,
}) async {
  final String extension = path.extension(file.path);
  final Uint8List bytes = await file.readAsBytes();

  return getHashPathForData(
    data: bytes,
    extension: extension,
    prefixPath: prefixPath,
  );
}

extension StringLocaleExtension on String {
  Locale toLocale({
    String separator = "_",
  }) {
    final List<String> splits = split(separator);
    switch (splits.length) {
      case 1:
        return Locale(splits.first);
      case 2:
        return Locale(splits.first, splits.last);
      case 3:
        return Locale.fromSubtags(
          languageCode: splits.first,
          scriptCode: splits[1],
          countryCode: splits.last,
        );
      default:
        throw "Error! Unknown Locale format!";
    }
  }
}

@pragma("vm:entry-point")
Version getAppVersionFromPackageInfo(PackageInfo packageInfo) {
  if (Platform.isAndroid || Platform.isIOS) {
    return Version.parse("${packageInfo.version}+${packageInfo.buildNumber}");
  } else {
    return Version.parse(packageInfo.version);
  }
}

extension DateTimeEx on DateTime {
  String format([DateFormat? format]) {
    final Locale locale =
        Localizations.localeOf(GKeys.navigatorKey.currentContext!);
    final DateFormat dateFormat = format ?? DateFormat.yMd(locale.toString());
    return dateFormat.format(this);
  }
}

extension IntFileSizeExtension on int {
  String toFileSizePrettyString({
    int fractionDigits = 2,
    bool abbreviate = true,
    String separator = " ",
  }) {
    late final double number;
    late final String unitName;

    String getUnit(double number, String unit) {
      if (number == 1) {
        return unit;
      }
      return "${unit}s";
    }

    if (this >= 1e+15) {
      number = this / 1e+15;
      unitName = abbreviate ? "PB" : getUnit(number, "Petabyte");
    } else if (this >= 1e+12) {
      number = this / 1e+12;
      unitName = abbreviate ? "TB" : getUnit(number, "Terabyte");
    } else if (this >= 1e+9) {
      number = this / 1e+9;
      unitName = abbreviate ? "GB" : getUnit(number, "Gigabyte");
    } else if (this >= 1e+6) {
      number = this / 1e+6;
      unitName = abbreviate ? "MB" : getUnit(number, "Megabyte");
    } else if (this >= 1000) {
      number = this / 1000;
      unitName = abbreviate ? "KB" : getUnit(number, "Kilobyte");
    } else {
      number = toDouble();
      unitName = abbreviate ? "B" : getUnit(number, "Byte");
    }

    return "${number.toPrettyStringAsFixed(fractionDigits)}$separator$unitName";
  }
}

extension DoublePrettyStringExtension on double {
  String toPrettyString() {
    return toString().replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), '');
  }

  String toPrettyStringAsFixed(int fractionDigits) {
    return toStringAsFixed(fractionDigits).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), '');
  }
}
