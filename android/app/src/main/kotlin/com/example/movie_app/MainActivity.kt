package com.example.movie_app

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import android.content.pm.PackageManager
import android.util.Base64
import android.util.Log
import java.security.MessageDigest

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        Log.e("KeyHash", "========== BẮT ĐẦU LẤY KEY HASH ==========")
        
        // Lấy Facebook Key Hash
        try {
            Log.e("KeyHash", "Đang lấy package info...")
            
            @Suppress("DEPRECATION")
            val info = packageManager.getPackageInfo(
                packageName,
                PackageManager.GET_SIGNATURES
            )
            
            Log.e("KeyHash", "Package name: $packageName")
            
            @Suppress("DEPRECATION")
            val signatures = info.signatures
            
            if (signatures == null || signatures.isEmpty()) {
                Log.e("KeyHash", "Không tìm thấy signatures!")
            } else {
                Log.e("KeyHash", "Tìm thấy ${signatures.size} signature(s)")
                
                signatures.forEach { signature ->
                    val md = MessageDigest.getInstance("SHA")
                    md.update(signature.toByteArray())
                    val keyHash = Base64.encodeToString(md.digest(), Base64.DEFAULT)
                    Log.e("KeyHash", "========================================")
                    Log.e("KeyHash", "KEY HASH: $keyHash")
                    Log.e("KeyHash", "========================================")
                }
            }
        } catch (e: Exception) {
            Log.e("KeyHash", "LỖI: ${e.message}")
            Log.e("KeyHash", "Stack trace:")
            e.printStackTrace()
        }
        
        Log.e("KeyHash", "========== KẾT THÚC LẤY KEY HASH ==========")
    }
}