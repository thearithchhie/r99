package com.elriztechnology.unified_esc_pos_printer

import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.MethodChannel

class PermissionHandler {

    companion object {
        private const val REQUEST_CODE = 29501
    }

    private var activity: Activity? = null
    private var pendingResult: MethodChannel.Result? = null

    fun setActivity(activity: Activity?) {
        this.activity = activity
    }

    fun requestPermissions(result: MethodChannel.Result) {
        val act = activity
        if (act == null) {
            result.success(false)
            return
        }

        val needed = getRequiredPermissions().filter {
            ContextCompat.checkSelfPermission(act, it) != PackageManager.PERMISSION_GRANTED
        }

        if (needed.isEmpty()) {
            result.success(true)
            return
        }

        pendingResult = result
        ActivityCompat.requestPermissions(act, needed.toTypedArray(), REQUEST_CODE)
    }

    fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ): Boolean {
        if (requestCode != REQUEST_CODE) return false

        val allGranted = grantResults.isNotEmpty() &&
                grantResults.all { it == PackageManager.PERMISSION_GRANTED }
        pendingResult?.success(allGranted)
        pendingResult = null
        return true
    }

    private fun getRequiredPermissions(): List<String> {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            // Android 12+
            listOf(
                Manifest.permission.BLUETOOTH_SCAN,
                Manifest.permission.BLUETOOTH_CONNECT,
            )
        } else {
            // Pre-Android 12
            listOf(
                Manifest.permission.BLUETOOTH,
                Manifest.permission.BLUETOOTH_ADMIN,
                Manifest.permission.ACCESS_FINE_LOCATION,
            )
        }
    }
}
