import 'package:flutter/material.dart';

class YaqinLocalization {
  final Locale locale;
  YaqinLocalization(this.locale);

  static YaqinLocalization of(BuildContext context) {
    return Localizations.of<YaqinLocalization>(context, YaqinLocalization) ??
        YaqinLocalization(const Locale('ru'));
  }

  static const _localizedValues = <String, Map<String, String>>{
    'ru': {
      'app_title': 'Yaqin',
      'login': 'Войти',
      'signup': 'Регистрация',
      'email': 'Электронная почта',
      'password': 'Пароль',
      'name': 'Имя',
      'age': 'Возраст',
      'bio': 'О себе',
      'interests': 'Интересы (через запятую)',
      'stealth_mode': 'Режим невидимки (Стелс)',
      'stealth_desc': 'Вас не видно на радаре и карте',
      'radar': 'Радар',
      'map': 'Карта',
      'capsules': 'Капсулы',
      'messages': 'Сообщения',
      'profile': 'Профиль',
      'drop_capsule': 'Оставить капсулу',
      'capsule_hint': 'Короткое сообщение (до 150 символов)...',
      'capsule_lifespan': 'Время жизни (часы)',
      'is_phantom': 'Фантомная капсула (исчезнет для 1-го открывшего)',
      'phantom_badge': 'ФАНТОМ',
      'drop_now': 'Оставить здесь',
      'distance': 'Дистанция',
      'unlock_capsule': 'Открыть капсулу',
      'too_far': 'Подойдите ближе (в пределах 15-20 м)',
      'match_alert_title': 'Рядом кто-то есть!',
      'match_alert_msg': 'Вы находитесь рядом более 10 минут. Взаимная симпатия?',
      'share_meeting_pin': 'Поделиться точкой встречи',
      'type_message': 'Введите сообщение...',
      'swipe_like': 'Лайк',
      'swipe_pass': 'Пропустить',
      'status_stationary': 'Вы на месте. Поиск совпадений в радиусе 15м...',
    },
    'tg': {
      'app_title': 'Yaqin',
      'login': 'Воридшавӣ',
      'signup': 'Қайдгирӣ',
      'email': 'Почтаи электронӣ',
      'password': 'Рамз',
      'name': 'Ном',
      'age': 'Синну сол',
      'bio': 'Дар бораи худ',
      'interests': 'Шавқу рағбат (бо вергул)',
      'stealth_mode': 'Реҷаи пинҳонӣ (Стелс)',
      'stealth_desc': 'Шумо дар радар ва харита дида намешавед',
      'radar': 'Радар',
      'map': 'Харита',
      'capsules': 'Капсулаҳо',
      'messages': 'Паёмҳо',
      'profile': 'Профил',
      'drop_capsule': 'Капсула гузоштан',
      'capsule_hint': 'Паёми кӯтоҳ (то 150 аломат)...',
      'capsule_lifespan': 'Муддати фаъолият (соат)',
      'is_phantom': 'Капсулаи фантом (барои нафари аввал)',
      'phantom_badge': 'ФАНТОМ',
      'drop_now': 'Дар ин ҷо мондан',
      'distance': 'Масофа',
      'unlock_capsule': 'Кушодани капсула',
      'too_far': 'Наздиктар равед (дар ҳудуди 15-20 метр)',
      'match_alert_title': 'Дар наздикии шумо касе ҳаст!',
      'match_alert_msg': 'Шумо зиёда аз 10 дақиқа дар як ҷоед. Ҳамсуҳбат мешавед?',
      'share_meeting_pin': 'Нуқтаи вохӯриро нишон додан',
      'type_message': 'Паём нависед...',
      'swipe_like': 'Писанд',
      'swipe_pass': 'Гузаштан',
      'status_stationary': 'Шумо дар ҷоед. Ҷустуҷӯ дар радиуси 15м...',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? _localizedValues['ru']![key] ?? key;
  }
}

class YaqinLocalizationDelegate extends LocalizationsDelegate<YaqinLocalization> {
  const YaqinLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => ['ru', 'tg'].contains(locale.languageCode);

  @override
  Future<YaqinLocalization> load(Locale locale) async {
    return YaqinLocalization(locale);
  }

  @override
  bool shouldReload(YaqinLocalizationDelegate old) => false;
}
