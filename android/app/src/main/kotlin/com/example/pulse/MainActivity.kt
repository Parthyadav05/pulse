package com.example.pulse

import io.flutter.embedding.android.FlutterActivity
import android.view.WindowManager
import android.os.Bundle

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Explicitly allow screenshots by ensuring FLAG_SECURE is not set
        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }
}
