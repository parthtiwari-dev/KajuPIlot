package com.kajupilot.app

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.provider.ContactsContract
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var pendingContactResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CONTACTS_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "pickPhoneContact" -> pickPhoneContact(result)
                else -> result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode != PICK_PHONE_CONTACT_REQUEST) {
            return
        }

        val result = pendingContactResult ?: return
        pendingContactResult = null

        if (resultCode != Activity.RESULT_OK || data?.data == null) {
            result.success(null)
            return
        }

        val contactUri = data.data
        val projection = arrayOf(
            ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME,
            ContactsContract.CommonDataKinds.Phone.NUMBER,
        )

        try {
            contentResolver.query(contactUri!!, projection, null, null, null).use { cursor ->
                if (cursor == null || !cursor.moveToFirst()) {
                    result.success(null)
                    return
                }

                val nameIndex = cursor.getColumnIndex(
                    ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME,
                )
                val phoneIndex = cursor.getColumnIndex(
                    ContactsContract.CommonDataKinds.Phone.NUMBER,
                )
                val name = if (nameIndex >= 0) cursor.getString(nameIndex) else null
                val phone = if (phoneIndex >= 0) cursor.getString(phoneIndex) else null

                result.success(mapOf("name" to name, "phone" to phone))
            }
        } catch (error: Exception) {
            result.error(
                "contact_read_failed",
                error.message ?: "Could not read selected contact",
                null,
            )
        }
    }

    private fun pickPhoneContact(result: MethodChannel.Result) {
        if (pendingContactResult != null) {
            result.error(
                "contact_picker_busy",
                "A contact picker is already open",
                null,
            )
            return
        }

        pendingContactResult = result
        val intent = Intent(
            Intent.ACTION_PICK,
            ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
        )

        try {
            startActivityForResult(intent, PICK_PHONE_CONTACT_REQUEST)
        } catch (error: ActivityNotFoundException) {
            pendingContactResult = null
            result.error(
                "contact_picker_unavailable",
                "No contacts app is available on this device",
                null,
            )
        }
    }

    companion object {
        private const val CONTACTS_CHANNEL = "kajupilot/contacts"
        private const val PICK_PHONE_CONTACT_REQUEST = 4201
    }
}
