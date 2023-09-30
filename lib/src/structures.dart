library structures;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:crypto/crypto.dart';
import 'package:duration/duration.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_essentials/flutter_essentials.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lyrics/src/helpers.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:simplytranslate/simplytranslate.dart';

import 'package:lyrics/src/controllers.dart';
import 'package:lyrics/src/globals.dart';
import 'package:transparent_image/transparent_image.dart';

part 'structures/database.dart';
part 'structures/detected_player_data.dart';
part 'structures/lyrics.dart';
part 'structures/lyrics_translator.dart';
part 'structures/notification_stream_filter.dart';
part 'structures/offline_database.dart';
part 'structures/player_data.dart';
part 'structures/recognised_player.dart';
part 'structures/resolved_player_data.dart';
part 'structures/simply_lyrics_translator.dart';
part 'structures/song.dart';
part 'structures/state.dart';
part 'structures/update_checker.dart';
part 'structures/unsupported_update_checker.dart';
part 'structures/translation_data.dart';
part 'structures/player_media_info.dart';
