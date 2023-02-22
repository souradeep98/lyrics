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
  required String extension,
  String? prefixPath,
}) {
  //final String extension = path.extension(file.path);
  //final Uint8List bytes = await file.readAsBytes();
  final Digest x = sha1.convert(data);
  final String hash = x.toString();
  final String filename = hash;
  if (prefixPath != null) {
    return path.setExtension(path.join(prefixPath, filename), ".$extension");
  }
  return "$filename$extension";
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
  /*final Digest x = sha1.convert(bytes);
  final String hash = x.toString();
  final String filename = hash;
  if (prefixPath != null) {
    return path.join(prefixPath, "$filename$extension");
  }
  return "$filename$extension";*/
}
