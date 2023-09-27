package com.lyrics.app

import android.content.Context
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.view.FlutterCallbackInformation

class Helpers {
    companion object {
        fun getFlutterEngine(context: Context) : FlutterEngine {
            val cachedFlutterEngine = FlutterEngineCache.getInstance().get(Constants.flutterEngineCacheKey)

            if (cachedFlutterEngine != null) {
                return cachedFlutterEngine
            }

            // new engine initialization
            val flutterEngine = FlutterEngine(context)

            // ensure initialization
            FlutterInjector.instance().flutterLoader().startInitialization(context)
            FlutterInjector.instance().flutterLoader().ensureInitializationComplete(context, null)

            cacheFlutterEngine(flutterEngine)

            return flutterEngine
        }

        fun cacheFlutterEngine(flutterEngine: FlutterEngine) {
            FlutterEngineCache.getInstance().put(Constants.flutterEngineCacheKey, flutterEngine)
        }

        fun setDartInitializerCallback(context: Context, callbackHandle: Long?) {
            val prefs = context.getSharedPreferences("dart_callbacks", Context.MODE_PRIVATE)

            val key = "media_session_listener"

            with(prefs.edit()) {
                if (callbackHandle == null) {
                    remove(key)
                } else {
                    putLong(key, callbackHandle)
                }
            }
        }

        fun callDartInitializerCallback(context: Context) {
            val flutterEngine = Helpers.getFlutterEngine(context)
            val prefs = context.getSharedPreferences("dart_callbacks", Context.MODE_PRIVATE)
            val callbackHandle = prefs.getLong("media_session_listener", 0L)

            if (callbackHandle == 0L) {
                return
            }

            val callbackInfo = FlutterCallbackInformation.lookupCallbackInformation(callbackHandle)

            val callback = DartExecutor.DartCallback(
                context.assets,
                FlutterInjector.instance().flutterLoader().findAppBundlePath(),
                callbackInfo,
            )

            flutterEngine.dartExecutor.executeDartCallback(callback)
        }
    }
}