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
Future<List<int>> convertToJpeg(List<int> imageData) async {
  final List<int> result = await compute<List<int>, List<int>>(
    (imageData) {
      final imagelib.Image? image = imagelib.decodeImage(imageData);
      if (image == null) {
        throw "Could not decode image";
      }
      final List<int> jpegImage = imagelib.encodeJpg(image);

      return jpegImage;
    },
    imageData,
  );

  return result;
}
