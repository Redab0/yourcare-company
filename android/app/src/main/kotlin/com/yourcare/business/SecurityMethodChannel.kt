package com.yourcare.business

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class SecurityMethodChannel(private val context: Context) : MethodChannel.MethodCallHandler {
    companion object {
        private const val CHANNEL = "com.kwclean.driver/app_security"
        
        fun registerWith(flutterEngine: FlutterEngine, context: Context) {
            val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            channel.setMethodCallHandler(SecurityMethodChannel(context))
        }
    }
    
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getSigningInfo" -> {
                val packageName = call.argument<String>("packageName")
                if (packageName == null) {
                    result.error("INVALID_ARGUMENT", "Package name is required", null)
                    return
                }
                
                try {
                    val signatures = getAppSignatures(packageName)
                    result.success(signatures)
                } catch (e: Exception) {
                    result.error("ERROR", "Failed to get signing info: ${e.message}", null)
                }
            }
            else -> result.notImplemented()
        }
    }
    
    private fun getAppSignatures(packageName: String): List<String> {
        val signatures = ArrayList<String>()
        
        try {
            val packageInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                val packageInfo = context.packageManager.getPackageInfo(
                    packageName,
                    PackageManager.GET_SIGNING_CERTIFICATES
                )
                
                if (packageInfo.signingInfo!!.hasMultipleSigners()) {
                    packageInfo.signingInfo!!.apkContentsSigners
                } else {
                    packageInfo.signingInfo!!.signingCertificateHistory
                }
            } else {
                @Suppress("DEPRECATION")
                val packageInfo = context.packageManager.getPackageInfo(
                    packageName,
                    PackageManager.GET_SIGNATURES
                )
                packageInfo.signatures
            }
            
            for (signature in packageInfo!!) {
                val hexSignature = bytesToHex(signature.toByteArray())
                signatures.add(hexSignature)
            }
        } catch (e: Exception) {
            // Log the error
        }
        
        return signatures
    }
    
    private fun bytesToHex(bytes: ByteArray): String {
        val hexChars = CharArray(bytes.size * 3 - 1)
        for (i in bytes.indices) {
            val v = bytes[i].toInt() and 0xFF
            hexChars[i * 3] = HEX_ARRAY[v ushr 4]
            hexChars[i * 3 + 1] = HEX_ARRAY[v and 0x0F]
            if (i < bytes.size - 1) {
                hexChars[i * 3 + 2] = ':'
            }
        }
        return String(hexChars)
    }
    
    private val HEX_ARRAY = "0123456789ABCDEF".toCharArray()
}