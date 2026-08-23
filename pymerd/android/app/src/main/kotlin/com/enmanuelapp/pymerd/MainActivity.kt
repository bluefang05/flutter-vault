package com.enmanuelapp.pymerd

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.provider.OpenableColumns
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.enmanuelapp.pymerd/files"
    private val saveRequestCode = 7301
    private val pickBytesRequestCode = 7302
    private val pickFileRequestCode = 7303

    private var pendingResult: MethodChannel.Result? = null
    private var pendingBytes: ByteArray? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result -> handleMethodCall(call, result) }
    }

    private fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (pendingResult != null) {
            result.error("BUSY", "Ya hay una operación de archivo en curso.", null)
            return
        }

        when (call.method) {
            "saveBytes" -> {
                val fileName = call.argument<String>("fileName") ?: "pymerd_export.dat"
                val mimeType = call.argument<String>("mimeType") ?: "application/octet-stream"
                val bytes = call.argument<ByteArray>("bytes")
                if (bytes == null) {
                    result.error("NO_BYTES", "No se recibieron datos para guardar.", null)
                    return
                }
                pendingResult = result
                pendingBytes = bytes
                val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                    addCategory(Intent.CATEGORY_OPENABLE)
                    type = mimeType
                    putExtra(Intent.EXTRA_TITLE, fileName)
                }
                startActivityForResult(intent, saveRequestCode)
            }

            "pickBytes", "pickFile" -> {
                val mimeType = call.argument<String>("mimeType") ?: "*/*"
                pendingResult = result
                val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                    addCategory(Intent.CATEGORY_OPENABLE)
                    type = mimeType
                }
                val requestCode = if (call.method == "pickFile") {
                    pickFileRequestCode
                } else {
                    pickBytesRequestCode
                }
                startActivityForResult(intent, requestCode)
            }

            else -> result.notImplemented()
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        when (requestCode) {
            saveRequestCode -> finishSave(resultCode, data?.data)
            pickBytesRequestCode -> finishPickBytes(resultCode, data?.data)
            pickFileRequestCode -> finishPickFile(resultCode, data?.data)
        }
    }

    private fun finishSave(resultCode: Int, uri: Uri?) {
        val result = pendingResult
        try {
            if (resultCode != Activity.RESULT_OK || uri == null) {
                result?.success(false)
                return
            }
            val bytes = pendingBytes ?: throw IllegalStateException("No hay datos pendientes.")
            contentResolver.openOutputStream(uri)?.use { stream ->
                stream.write(bytes)
                stream.flush()
            } ?: throw IllegalStateException("No se pudo abrir el destino seleccionado.")
            result?.success(true)
        } catch (error: Exception) {
            result?.error("SAVE_FAILED", error.message, null)
        } finally {
            clearPending()
        }
    }

    private fun finishPickBytes(resultCode: Int, uri: Uri?) {
        val result = pendingResult
        try {
            if (resultCode != Activity.RESULT_OK || uri == null) {
                result?.success(null)
                return
            }
            result?.success(readBytes(uri))
        } catch (error: Exception) {
            result?.error("PICK_FAILED", error.message, null)
        } finally {
            clearPending()
        }
    }

    private fun finishPickFile(resultCode: Int, uri: Uri?) {
        val result = pendingResult
        try {
            if (resultCode != Activity.RESULT_OK || uri == null) {
                result?.success(null)
                return
            }
            val payload = hashMapOf<String, Any?>(
                "name" to queryDisplayName(uri),
                "mimeType" to (contentResolver.getType(uri) ?: "application/octet-stream"),
                "bytes" to readBytes(uri),
            )
            result?.success(payload)
        } catch (error: Exception) {
            result?.error("PICK_FAILED", error.message, null)
        } finally {
            clearPending()
        }
    }

    private fun readBytes(uri: Uri): ByteArray {
        return contentResolver.openInputStream(uri)?.use { it.readBytes() }
            ?: throw IllegalStateException("No se pudo leer el archivo seleccionado.")
    }

    private fun queryDisplayName(uri: Uri): String {
        contentResolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)?.use { cursor ->
            if (cursor.moveToFirst()) {
                val index = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                if (index >= 0) return cursor.getString(index)
            }
        }
        return uri.lastPathSegment ?: "archivo"
    }

    private fun clearPending() {
        pendingResult = null
        pendingBytes = null
    }
}
