package com.katya.wtf

import io.flutter.embedding.android.FlutterActivity
import android.os.SystemClock
import android.util.Log

class MainActivity: FlutterActivity() {
    override fun onResume() {
        super.onResume()
        // Simple cold start metric (approx): time since boot minus process start not available here
        // Log app resume as a proxy metric
        val now = SystemClock.elapsedRealtime()
        Log.i("KatyaStartup", "resume_elapsed_ms=$now")
    }
}
