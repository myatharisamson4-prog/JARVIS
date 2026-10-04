package com.example.jarvis_assistant

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent

class JarvisAccessibilityService : AccessibilityService() {

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        // JARVIS will use this service to observe and interact with app UI.
    }

    override fun onInterrupt() {
        // Accessibility service interrupted.
    }
}
