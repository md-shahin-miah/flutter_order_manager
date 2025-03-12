package com.example.flutter_order_manager

import android.media.MediaPlayer
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.flutter_order_manager/sound"
    private var mediaPlayer: MediaPlayer? = null
    private var isLooping = false

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "playOrderCreatedSound" -> {
                    playOrderCreatedSound()
                    result.success(null)
                }
                "stopSound" -> {
                    stopSound()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun playOrderCreatedSound() {
        // Release any existing media player
        mediaPlayer?.release()
        
        // Create a new media player and play the sound
        mediaPlayer = MediaPlayer.create(this, R.raw.alarm)
        mediaPlayer?.isLooping = true // Set to loop continuously
        isLooping = true
        mediaPlayer?.start()
    }
    
    private fun stopSound() {
        if (isLooping) {
            mediaPlayer?.isLooping = false
            mediaPlayer?.stop()
            mediaPlayer?.release()
            mediaPlayer = null
            isLooping = false
        }
    }
    
    override fun onDestroy() {
        mediaPlayer?.release()
        mediaPlayer = null
        super.onDestroy()
    }
}

