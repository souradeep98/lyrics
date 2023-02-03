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
Future<List<int>> convertToJpeg(Uint8List imageData) async {
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
