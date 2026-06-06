import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final phoneContactPickerProvider = Provider<PhoneContactPicker>((ref) {
  return const MethodChannelPhoneContactPicker();
});

class PhoneContact {
  const PhoneContact({
    required this.name,
    required this.phone,
  });

  final String? name;
  final String? phone;

  bool get hasUsableValue {
    return (name != null && name!.trim().isNotEmpty) ||
        (phone != null && phone!.trim().isNotEmpty);
  }
}

abstract class PhoneContactPicker {
  Future<PhoneContact?> pickContact();
}

class MethodChannelPhoneContactPicker implements PhoneContactPicker {
  const MethodChannelPhoneContactPicker();

  static const _channel = MethodChannel('kajupilot/contacts');

  @override
  Future<PhoneContact?> pickContact() async {
    final result = await _channel.invokeMapMethod<String, Object?>(
      'pickPhoneContact',
    );

    if (result == null) {
      return null;
    }

    final contact = PhoneContact(
      name: result['name'] as String?,
      phone: result['phone'] as String?,
    );

    return contact.hasUsableValue ? contact : null;
  }
}
