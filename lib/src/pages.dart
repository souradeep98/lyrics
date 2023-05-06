library pages;

import 'dart:async';
import 'dart:io';
import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_essentials/flutter_essentials.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:lyrics/src/constants.dart';
import 'package:lyrics/src/controllers.dart';
import 'package:lyrics/src/globals.dart';
import 'package:lyrics/src/helpers.dart';
import 'package:lyrics/src/structures.dart';
import 'package:lyrics/src/utils.dart';
import 'package:lyrics/src/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:lottie/lottie.dart';
import 'package:transparent_image/transparent_image.dart';

part 'pages/home.dart';
part 'pages/splash.dart';
part 'pages/settings/notification_access_permission_request.dart';
part 'pages/forms/lyrics_form.dart';
part 'pages/forms/lyrics_synchronization.dart';
part 'pages/forms/song_details_form.dart';
part 'pages/forms/album_art_and_clip_form.dart';
part 'pages/settings.dart';
part 'pages/settings/update_page.dart';
part 'pages/settings/notification_settings.dart';
part 'pages/settings/app_language_and_translation_settings.dart';
part 'pages/settings/theme_settings.dart';
