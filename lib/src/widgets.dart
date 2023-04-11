library widgets;

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:animations/animations.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_essentials/flutter_essentials.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lyrics/src/constants.dart';
import 'package:lyrics/src/controllers.dart';
import 'package:lyrics/src/helpers.dart';
import 'package:lyrics/src/structures.dart';
import 'package:lyrics/src/utils.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:video_player/video_player.dart';

part 'widgets/control_buttons.dart';
part 'widgets/lyrics_line_view.dart';
part 'widgets/album_art_view.dart';
part 'widgets/lyrics_catalog_view.dart';
part 'widgets/lyrics_view.dart';
part 'widgets/currently_playing.dart';
part 'widgets/player_notification_listener.dart';
part 'widgets/playing_indicator.dart';
part 'widgets/lyrics_list_view.dart';
part 'widgets/app_themed_text_field.dart';
part 'widgets/app_bottom_bar.dart';
part 'widgets/clip_player.dart';
part 'widgets/dim_overlay.dart';
part 'widgets/loading_and_empty_widgets.dart';
part 'widgets/shared_preference_listener.dart';
part 'widgets/app_custom_top_bar.dart';
part 'widgets/app_bottom_navigation_bar.dart';
