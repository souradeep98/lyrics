library structures;

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:duration/duration.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_essentials/flutter_essentials.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lyrics/src/helpers.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:simplytranslate/simplytranslate.dart';

import 'package:lyrics/src/controllers.dart';
import 'package:lyrics/src/globals.dart';

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
part 'structures/log_helper_mixin.dart';
