package com.nextfiction.resumelabs.ai

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.nextfiction.resumelabs/config"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getFirebasePdfFunctionUrl" -> {
                        val resId = resources.getIdentifier(
                            "firebase_pdf_function_url",
                            "string",
                            packageName
                        )
                        val value = if (resId != 0) getString(resId) else null
                        result.success(value)
                    }

                    else -> result.notImplemented()
                }
            }
    }
}
