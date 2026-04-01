package com.example.emergency_alert.services

import android.media.MediaRecorder
import android.util.Log
import java.io.File

class AudioRecorderService(private val outputDir: File) {
    private var recorder: MediaRecorder? = null

    fun startRecording(fileName: String) {
        val file = File(outputDir, fileName)
        recorder = MediaRecorder().apply {
            setAudioSource(MediaRecorder.AudioSource.MIC)
            setOutputFormat(MediaRecorder.OutputFormat.THREE_GPP)
            setAudioEncoder(MediaRecorder.AudioEncoder.AMR_NB)
            setOutputFile(file.absolutePath)
            try {
                prepare()
                start()
            } catch (e: Exception) {
                Log.e("AudioRecorder", "Recording failed: ${e.message}")
            }
        }
    }

    fun stopRecording() {
        recorder?.apply {
            stop()
            release()
        }
        recorder = null
    }
}
