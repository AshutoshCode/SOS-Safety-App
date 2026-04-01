package com.example.emergency_alert

import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.example.emergency_alert.services.SmsService

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.emergency_alert/sms"
    private val SMS_PERMISSION_CODE = 1001

    private lateinit var smsService: SmsService

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        smsService = SmsService(this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "sendSms" -> {
                    val phoneNumber = call.argument<String>("phoneNumber")
                    val message = call.argument<String>("message")

                    if (phoneNumber != null && message != null) {
                        val success = smsService.sendSms(phoneNumber, message)
                        result.success(success)
                    } else {
                        result.error("INVALID_ARGS", "Missing phone number or message", null)
                    }
                }

                "hasSmsPermission" -> {
                    val hasPermission = smsService.hasSmsPermission()
                    result.success(hasPermission)
                }

                "requestSmsPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        if (ContextCompat.checkSelfPermission(
                                this,
                                android.Manifest.permission.SEND_SMS
                            ) != PackageManager.PERMISSION_GRANTED
                        ) {
                            ActivityCompat.requestPermissions(
                                this,
                                arrayOf(android.Manifest.permission.SEND_SMS),
                                SMS_PERMISSION_CODE
                            )
                            result.success(false)
                        } else {
                            result.success(true)
                        }
                    } else {
                        result.success(true)
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        if (requestCode == SMS_PERMISSION_CODE) {
            val channel = MethodChannel(
                flutterEngine!!.dartExecutor.binaryMessenger,
                CHANNEL
            )
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                channel.invokeMethod("onSmsPermissionGranted", null)
            } else {
                channel.invokeMethod("onSmsPermissionDenied", null)
            }
        }
    }
}
