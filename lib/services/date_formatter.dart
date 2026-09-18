import 'package:intl/intl.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'storage_service.dart';

class DateFormatter {
  static Future<String> format(String adDate) async {
    final dateType = await StorageService.getDateType();
    DateTime? dt = DateTime.tryParse(adDate);
    if (dt == null) return adDate;

    if (dateType == 'BS') {
      NepaliDateTime nt = dt.toNepaliDateTime();
      return NepaliDateFormat('yyyy-MM-dd').format(nt);
    } else {
      return DateFormat('yyyy-MM-dd').format(dt);
    }
  }

  static String formatSync(String adDate, String dateType) {
    DateTime? dt = DateTime.tryParse(adDate);
    if (dt == null) return adDate;

    if (dateType == 'BS') {
      NepaliDateTime nt = dt.toNepaliDateTime();
      return NepaliDateFormat('yyyy-MM-dd').format(nt);
    } else {
      return DateFormat('yyyy-MM-dd').format(dt);
    }
  }
}
