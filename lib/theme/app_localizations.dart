import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'settings': 'Settings',
      'account': 'Account',
      'premium': 'Premium Services',
      'privacy': 'Privacy',
      'communication': 'Communication',
      'localization': 'Localization',
      'support': 'Support',
      'experience_languages': 'Experience & Languages',
      'notifications': 'Notifications',
      'search': 'Search',
      'home': 'Home',
      'profile': 'Profile',
      'logout': 'Log out',
    },
    'ne': {
      'settings': 'सेटिङहरू',
      'account': 'खाता',
      'premium': 'प्रिमियम सेवाहरू',
      'privacy': 'गोपनीयता',
      'communication': 'सञ्चार',
      'localization': 'स्थानीयकरण',
      'support': 'सहयोग',
      'experience_languages': 'अनुभव र भाषाहरू',
      'notifications': 'सूचनाहरू',
      'search': 'खोज्नुहोस्',
      'home': 'गृह',
      'profile': 'प्रोफाइल',
      'logout': 'लग आउट',
    },
    'ja': {
      'settings': '設定',
      'account': 'アカウント',
      'premium': 'プレミアムサービス',
      'privacy': 'プライバシー',
      'communication': 'コミュニケーション',
      'localization': 'ローカリゼーション',
      'support': 'サポート',
      'experience_languages': '体験と言語',
      'notifications': '通知',
      'search': '検索',
      'home': 'ホーム',
      'profile': 'プロフィール',
      'logout': 'ログアウト',
    },
    'zh': {
      'settings': '设置',
      'account': '账户',
      'premium': '高级服务',
      'privacy': '隐私',
      'communication': '沟通',
      'localization': '本地化',
      'support': '支持',
      'experience_languages': '体验与语言',
      'notifications': '通知',
      'search': '搜索',
      'home': '首页',
      'profile': '个人资料',
      'logout': '登出',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? _localizedValues['en']![key] ?? key;
  }

  String get settings => translate('settings');
  String get account => translate('account');
  String get premium => translate('premium');
  String get privacy => translate('privacy');
  String get communication => translate('communication');
  String get localization => translate('localization');
  String get support => translate('support');
  String get experienceLanguages => translate('experience_languages');
  String get notifications => translate('notifications');
  String get search => translate('search');
  String get home => translate('home');
  String get profile => translate('profile');
  String get logout => translate('logout');
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ne', 'ja', 'zh'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
