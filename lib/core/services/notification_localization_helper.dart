class NotificationLocalizationHelper {
  NotificationLocalizationHelper._();

  static String _currentLanguage = 'en';

  static void setLanguage(String languageCode) {
    _currentLanguage = languageCode.startsWith('ar') ? 'ar' : 'en';
  }

  static String get currentLanguage => _currentLanguage;

  static String deliveryTitle([String? languageCode]) {
    final lang = languageCode ?? _currentLanguage;
    return lang.startsWith('ar')
        ? 'تذكير بموعد التسليم'
        : 'Delivery Reminder';
  }

  static String deliveryBody({
    required String vin,
    required String customer,
    String? languageCode,
  }) {
    final lang = languageCode ?? _currentLanguage;
    if (lang.startsWith('ar')) {
      return 'السيارة $vin الخاصة بالعميل $customer موعد تسليمها الآن.';
    }
    return 'Vehicle $vin for $customer is due for delivery now.';
  }

  static String advanceTitle({
    required int minutes,
    String? languageCode,
  }) {
    final lang = languageCode ?? _currentLanguage;
    if (lang.startsWith('ar')) {
      return 'تذكير بقرب موعد التسليم ($minutes د)';
    }
    return 'Upcoming Delivery (${minutes}m)';
  }

  static String advanceBody({
    required String vin,
    required String customer,
    required int minutes,
    String? languageCode,
  }) {
    final lang = languageCode ?? _currentLanguage;
    if (lang.startsWith('ar')) {
      return 'السيارة $vin للعميل $customer موعد تسليمها بعد $minutes دقيقة.';
    }
    return 'Vehicle $vin for $customer is scheduled for delivery in $minutes minutes.';
  }

  static String testTitle([String? languageCode]) {
    final lang = languageCode ?? _currentLanguage;
    return lang.startsWith('ar')
        ? 'إشعارات AutoDesk نشطة'
        : 'AutoDesk Notifications Active';
  }

  static String testBody([String? languageCode]) {
    final lang = languageCode ?? _currentLanguage;
    return lang.startsWith('ar')
        ? 'تم ضبط تذكيرات تسليم السيارات وتعمل بشكل صحيح.'
        : 'Vehicle delivery reminders are configured and working properly.';
  }
}

