package com.example.jarvis_assistant

import android.accessibilityservice.AccessibilityService
import android.util.Log
import android.view.accessibility.AccessibilityEvent

class JarvisAccessibilityService : AccessibilityService() {

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        event ?: return

        val packageName = event.packageName?.toString() ?: "unknown"
        val eventType = event.eventType

        Log.d(
            "JARVIS_ACCESSIBILITY",
            "App: $packageName | Event type: $eventType"
        )
    }

    override fun onInterrupt() {
        Log.d("JARVIS_ACCESSIBILITY", "Accessibility service interrupted")
    }
}
