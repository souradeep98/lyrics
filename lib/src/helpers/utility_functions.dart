part of helpers;

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
    final Locale locale = Localizations.localeOf(GKeys.navigatorKey.currentContext!);
    final DateFormat dateFormat = format ?? DateFormat.yMd(locale.toString());
    return dateFormat.format(this);
  }
}
