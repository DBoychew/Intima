// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bulgarian (`bg`).
class AppLocalizationsBg extends AppLocalizations {
  AppLocalizationsBg([String locale = 'bg']) : super(locale);

  @override
  String get appName => 'Intima';

  @override
  String get onbPrivacyTitle => 'Дискретно и лично';

  @override
  String get onbPrivacyBody =>
      'Дневникът и календарът ти живеят на телефона, заключени с PIN.\nСподеляш с партньор само когато ти решиш.';

  @override
  String get onbCalendarTitle => 'Календар на близостта';

  @override
  String get onbCalendarBody =>
      'Цикъл, настроение, интимни моменти —\nвсичко на един дискретен екран.';

  @override
  String get onbDiaryTitle => 'Дневник на близостта';

  @override
  String get onbDiaryBody =>
      'Записвай моментите, които искаш да запомниш.\nСамо за теб. Или за двама.';

  @override
  String get onbNext => 'Продължи';

  @override
  String get onbStart => 'Започни';

  @override
  String get navCalendar => 'Календар';

  @override
  String get navDiary => 'Дневник';

  @override
  String get navInsights => 'Инсайти';

  @override
  String get navSettings => 'Настройки';

  @override
  String get bootStarting => 'Стартираме…';

  @override
  String get bootDb => 'Отключваме базата…';

  @override
  String get bootPrefs => 'Зареждаме настройките…';

  @override
  String get bootLock => 'Проверяваме защитата…';

  @override
  String get bootSecure => 'Скриваме следите…';

  @override
  String get bootNotifications => 'Подготвяме напомнянията…';

  @override
  String bootStepFailed(Object step, Object error) {
    return '$step — неуспешно ($error)';
  }

  @override
  String get bootRetry => 'Опитай отново';

  @override
  String get lockEnterPin => 'Въведи своя PIN';

  @override
  String get lockWrongPin => 'Грешен PIN — опитай отново';

  @override
  String get pinChoose => 'Избери PIN код';

  @override
  String get pinConfirm => 'Потвърди PIN кода';

  @override
  String get pinMismatch => 'PIN кодовете не съвпадат — опитай отново';

  @override
  String get pinHint => 'Ще го въвеждаш при всяко отваряне на Intima.';

  @override
  String get pinEnterCurrent => 'Въведи текущия PIN';

  @override
  String get weekdaysNarrow => 'П,В,С,Ч,П,С,Н';

  @override
  String get prevMonth => 'Предишен месец';

  @override
  String get nextMonth => 'Следващ месец';

  @override
  String get legendPeriod => 'Менструация';

  @override
  String get legendPredicted => 'Очаквана';

  @override
  String get legendIntimacy => 'Интимност';

  @override
  String get legendFertile => 'Овулация';

  @override
  String get ovulationInfoTitle => 'Овулация и фертилни дни';

  @override
  String get ovulationInfoBody =>
      'Овулацията е моментът, в който яйцеклетката се освобождава — обикновено около 14 дни преди следващата менструация.\n\nНай-голяма е вероятността за забременяване в деня на овулацията и в петте дни преди нея: сперматозоидите оцеляват до 5 дни, а яйцеклетката живее около 24 часа. Затова Intima отбелязва в зелено овулацията и по 2 дни около нея, изчислени според твоя цикъл.\n\nПрогнозата е ориентировъчна — цикълът варира — и не е метод за контрацепция.';

  @override
  String get ovulationGotIt => 'Разбрах';

  @override
  String todayCard(Object date) {
    return 'Днес · $date';
  }

  @override
  String get noLogToday => 'Все още няма запис за днес';

  @override
  String moodLabel(Object emoji) {
    return 'Настроение: $emoji';
  }

  @override
  String get energyLabel => 'Енергия ';

  @override
  String get predictionHint =>
      'Отбележи първия ден от менструацията си и Intima ще предвижда следващия цикъл и овулацията.';

  @override
  String nextCycleAround(Object date, Object countdown) {
    return 'Следващ цикъл — около $date ($countdown)';
  }

  @override
  String get anyMomentNow => 'очаква се всеки момент';

  @override
  String inDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'след $count дни',
      one: 'след $count ден',
    );
    return '$_temp0';
  }

  @override
  String cycleOfDays(Object days) {
    return 'При цикъл от $days дни · настройва се от Настройки';
  }

  @override
  String get saved => 'Записано ✨';

  @override
  String savedAutoFilled(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Записано ✨ Отбелязахме още $count дни от менструацията',
      one: 'Записано ✨ Отбелязахме още $count ден от менструацията',
    );
    return '$_temp0';
  }

  @override
  String savedCleared(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Записано ✨ Премахнахме и още $count дни от менструацията',
      one: 'Записано ✨ Премахнахме и още $count ден от менструацията',
    );
    return '$_temp0';
  }

  @override
  String get howAreYouToday => 'Как си днес?';

  @override
  String logFor(Object date) {
    return 'Запис за $date';
  }

  @override
  String get intimateMoment => 'Интимен момент ♥';

  @override
  String get tagPeriod => 'Менструация';

  @override
  String get tagPms => 'ПМС';

  @override
  String get tagHeadache => 'Главоболие';

  @override
  String get tagBadSleep => 'Лош сън';

  @override
  String momentN(Object n) {
    return 'Момент $n';
  }

  @override
  String get arousal => 'Възбуда';

  @override
  String get orgasms => 'Оргазми';

  @override
  String get positions => 'Пози';

  @override
  String get posMissionary => 'Мисионерска';

  @override
  String get posSpoons => 'Лъжички';

  @override
  String get posOnTop => 'Отгоре';

  @override
  String get posBehind => 'Отзад';

  @override
  String get posStanding => 'Права';

  @override
  String get pos69 => '69';

  @override
  String get posOther => 'Друга';

  @override
  String get momentNoteHint => 'Опиши момента… (само за теб)';

  @override
  String get addAnotherMoment => 'Добави още един момент';

  @override
  String get libido => 'Либидо';

  @override
  String get energy => 'Енергия';

  @override
  String get saveSparkle => 'Запази ✨';

  @override
  String get diaryTitle => 'Дневник';

  @override
  String get searchEntries => 'Търси в записите…';

  @override
  String get diaryEmpty =>
      'Тук ще живеят твоите моменти. 💜\nЗапочни с бутона долу.';

  @override
  String nothingFoundFor(Object query) {
    return 'Нищо не открихме за „$query“.';
  }

  @override
  String get memoryFromBefore => 'Спомен от преди време';

  @override
  String memoryQuote(Object title, Object date) {
    return '„$title“ · $date';
  }

  @override
  String get newEntry => 'Нов запис';

  @override
  String get editEntry => 'Редакция';

  @override
  String get save => 'Запази';

  @override
  String get deleteEntryTooltip => 'Изтрий записа';

  @override
  String get tplFree => 'Свободен текст';

  @override
  String get tplFreeHint => 'Започни да пишеш…';

  @override
  String get tplFeelings => 'Как се чувствам';

  @override
  String get tplFeelingsHint => 'Какво усещаш в момента? Какво го предизвика?';

  @override
  String get tplGratitude => 'Благодарност';

  @override
  String get tplGratitudeHint => 'Малките неща също се броят.';

  @override
  String get tplGratitudeStarter => 'Днес съм благодарна за ';

  @override
  String get tplUs => 'За нас 💞';

  @override
  String get tplUsHint => 'Момент, който искаш да запомните заедно.';

  @override
  String get tplUsStarter => 'Нещо, което искам да запомня за нас: ';

  @override
  String get addPhoto => 'Добави снимка';

  @override
  String get newTag => 'Нов таг';

  @override
  String get newTagTitle => 'Нов таг';

  @override
  String get tagNameLabel => 'Име на тага';

  @override
  String get tagNameHint => 'напр. нас';

  @override
  String get cancel => 'Отказ';

  @override
  String get add => 'Добави';

  @override
  String get deleteEntryTitle => 'Изтриване на записа?';

  @override
  String get deleteEntryBody => 'Записът и снимките му ще изчезнат завинаги.';

  @override
  String get delete => 'Изтрий';

  @override
  String get removePhotoTitle => 'Премахване на снимката?';

  @override
  String get removePhotoBody => 'Снимката ще бъде изтрита от записа завинаги.';

  @override
  String get remove => 'Премахни';

  @override
  String get galleryUnavailable => 'Галерията не е достъпна';

  @override
  String get photoMissing => 'Снимката липсва 📷';

  @override
  String get addVideo => 'Добави видео';

  @override
  String get removeVideoTitle => 'Премахване на видеото?';

  @override
  String get removeVideoBody => 'Видеото ще бъде изтрито от записа завинаги.';

  @override
  String get videoMissing => 'Видеото не може да се възпроизведе 🎬';

  @override
  String get addAudio => 'Аудио бележка';

  @override
  String get audioRecording => 'Записваме…';

  @override
  String get audioStopSave => 'Стоп и запази';

  @override
  String get audioPermissionDenied =>
      'Нужен е достъп до микрофона, за да запишеш аудио бележка';

  @override
  String get removeAudioTitle => 'Премахване на аудиото?';

  @override
  String get removeAudioBody => 'Аудио бележката ще бъде изтрита завинаги.';

  @override
  String get audioMissing => 'Аудиото не може да се пусне 🎙️';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get sectionCycle => 'ЦИКЪЛ';

  @override
  String get cycleLength => 'Дължина на цикъла';

  @override
  String get cycleLengthSubtitle => 'По нея предвиждаме следващата менструация';

  @override
  String get cycleLengthHint =>
      'От първия ден на една менструация до първия ден на следващата.';

  @override
  String get periodLength => 'Дължина на менструацията';

  @override
  String get periodLengthHint =>
      'Колко дни обикновено продължава менструацията ти.';

  @override
  String daysValue(Object days) {
    return '$days дни';
  }

  @override
  String get expectedNextPeriod => 'Очаквана следваща менструация';

  @override
  String get markPeriodInCalendar => 'Отбележи менструация в календара';

  @override
  String savedNextPeriod(Object date) {
    return 'Записано ✨ Следваща менструация — около $date';
  }

  @override
  String get sectionSecurity => 'СИГУРНОСТ';

  @override
  String get pinLock => 'PIN заключване';

  @override
  String get pinLockSubtitle => 'Изисква PIN при всяко отваряне';

  @override
  String get pinConfirmToDisable => 'Потвърди с PIN, за да изключиш';

  @override
  String get pinEnabled => 'PIN заключването е активно 🔒';

  @override
  String get pinDisabled => 'PIN заключването е изключено';

  @override
  String get biometrics => 'Биометрия';

  @override
  String get biometricsSubtitle => 'Пръстов отпечатък или лице вместо PIN';

  @override
  String get biometricsNeedPin =>
      'Първо активирай PIN — биометрията е допълнение към него';

  @override
  String get biometricsUnavailable =>
      'Биометрията не е налична на това устройство';

  @override
  String get stealthPin => 'Фалшив PIN (Stealth)';

  @override
  String get stealthSubtitle =>
      'Втори PIN, който отваря празно копие на Intima';

  @override
  String get stealthNeedPin => 'Първо активирай PIN заключването';

  @override
  String get stealthSameAsMain =>
      'Този PIN съвпада с основния — избери различен';

  @override
  String get stealthEnabled => 'Фалшивият PIN е активен 🕶️';

  @override
  String get stealthDisabled => 'Фалшивият PIN е изключен';

  @override
  String get stealthChange => 'Промени PIN-а';

  @override
  String get stealthTurnOff => 'Изключи';

  @override
  String get statusOn => 'Вкл.';

  @override
  String get statusOff => 'Изкл.';

  @override
  String get hideInRecents => 'Скрий в скорошни приложения';

  @override
  String get hideInRecentsSubtitle => 'Блокира и скрийншотите';

  @override
  String get sectionReminders => 'НАПОМНЯНИЯ';

  @override
  String get eveningReminder => 'Вечерно напомняне';

  @override
  String get eveningReminderSubtitle =>
      'Дискретно — без да издава съдържанието';

  @override
  String get beforePeriod => 'Преди менструация';

  @override
  String get beforePeriodSubtitle => 'Дискретно, 2 дни по-рано';

  @override
  String get onOvulationDay => 'В деня на овулация';

  @override
  String get timeLabel => 'Час';

  @override
  String get sectionData => 'ДАННИ';

  @override
  String get exportData => 'Експортирай данните';

  @override
  String get exportTitle => 'Експорт на данните';

  @override
  String get exportBody =>
      'Всички записи ще бъдат експортирани като криптиран файл (AES-256). Без ключа от това устройство той не може да бъде прочетен.';

  @override
  String get exportAction => 'Експортирай';

  @override
  String get exportSubject => 'Intima — криптиран архив';

  @override
  String exportFailed(Object error) {
    return 'Експортът не успя: $error';
  }

  @override
  String get deleteAll => 'Изтрий всичко';

  @override
  String get deleteAllTitle => 'Изтриване на всичко?';

  @override
  String get deleteAllBody =>
      'Всички записи ще бъдат изтрити завинаги. Това не може да се отмени.';

  @override
  String get deletedAll => 'Всички данни са изтрити завинаги 🗑️';

  @override
  String get sectionAbout => 'ЗА ПРИЛОЖЕНИЕТО';

  @override
  String get version => 'Версия';

  @override
  String get versionValue => '0.1.0 · прототип';

  @override
  String get themeTitle => 'Тема';

  @override
  String get themeDark => 'Тъмна';

  @override
  String get themeLight => 'Светла';

  @override
  String get themeSystem => 'Според системата';

  @override
  String get sectionGeneral => 'ОБЩИ';

  @override
  String get languageTitle => 'Език';

  @override
  String get languageSystem => 'Според системата';

  @override
  String get paletteTitle => 'Палитра';

  @override
  String get paletteIntima => 'Intima · лилаво и злато';

  @override
  String get paletteRoseGold => 'Роуз голд';

  @override
  String get paletteMidnightBlue => 'Среднощно синьо';

  @override
  String get paletteOcean => 'Океан';

  @override
  String get paletteApplied => 'Палитрата е сменена 🎨';

  @override
  String get sectionPremium => 'INTIMA PREMIUM';

  @override
  String get premiumTitle => 'Intima Premium';

  @override
  String get premiumTagline => 'Повече пространство за близостта';

  @override
  String get premiumSettingsSubtitle => 'PDF експорт, нови теми и още';

  @override
  String get premiumFeaturePdf => 'PDF експорт на дневника';

  @override
  String get premiumFeaturePdfDesc =>
      'Красив документ с всичките ти записи и снимки';

  @override
  String get premiumFeatureThemes => 'Светла тема и нови палитри';

  @override
  String get premiumFeatureStealth => 'Stealth режим и фалшив PIN';

  @override
  String get premiumFeatureInsights => 'Инсайти и статистики';

  @override
  String get premiumFeatureVideo => 'Видео в дневника';

  @override
  String get premiumFeatureAudio => 'Аудио бележки в дневника';

  @override
  String get premiumFeaturePacks => 'Тематични пакети за двойки';

  @override
  String get comingSoon => 'скоро';

  @override
  String get premiumTrial => '7 дни безплатно — отказваш се по всяко време';

  @override
  String get premiumCta => 'Започни пробния период';

  @override
  String get premiumComingSoon => 'Покупките идват с първия ъпдейт ✨';

  @override
  String get premiumActive => 'Premium е активен 💜';

  @override
  String get pdfExportTitle => 'Експорт на дневника в PDF';

  @override
  String get pdfExporting => 'Подготвяме PDF…';

  @override
  String get pdfEmpty => 'Дневникът е празен — няма какво да експортираме.';

  @override
  String get pdfSubject => 'Intima — дневник (PDF)';

  @override
  String get pdfDocTitle => 'Моят дневник';

  @override
  String pdfFailed(Object error) {
    return 'Експортът не успя: $error';
  }

  @override
  String get insightsTitle => 'Инсайти';

  @override
  String get insightsPrivacyNote => 'Изчислено изцяло на устройството 🔒';

  @override
  String get insightsSampleBadge => 'Примерен изглед с демо данни';

  @override
  String get insightsTeaser =>
      'Виж какво разказват твоите данни — реална дължина на цикъла, настроение по фази, тенденции на либидото. Изцяло на устройството, нищо не го напуска.';

  @override
  String get insightsUnlock => 'Отключи с Premium';

  @override
  String get insightsEmpty =>
      'Все още няма достатъчно данни.\nОтбелязвай цикъла и настроението си и тук ще се появят твоите тенденции. 💜';

  @override
  String get insightsCycleCard => 'Твоят цикъл';

  @override
  String insightsAvgDays(Object value) {
    return '$value дни';
  }

  @override
  String insightsMeasuredFrom(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Изчислено от $count реални цикъла',
      one: 'Изчислено от $count реален цикъл',
    );
    return '$_temp0';
  }

  @override
  String insightsCycleRange(Object min, Object max) {
    return 'Между $min и $max дни';
  }

  @override
  String get insightsCycleNeedTwo =>
      'Отбележи поне две менструации в календара и ще изчислим реалната дължина на цикъла ти — не само настройката.';

  @override
  String insightsVsSetting(Object days) {
    return 'Настройка: $days дни';
  }

  @override
  String get insightsMoodCard => 'Настроение по фази';

  @override
  String get phaseMenstrual => 'Менструация';

  @override
  String get phaseFollicular => 'Фоликуларна';

  @override
  String get phaseOvulation => 'Овулация';

  @override
  String get phaseLuteal => 'Лутеална';

  @override
  String get insightsMoodHint =>
      'Записвай настроението си по-често, за да видиш връзката му с цикъла.';

  @override
  String get insightsTrendCard => 'Либидо и енергия по месеци';

  @override
  String get insightsRecapCard => 'Последните 30 дни';

  @override
  String insightsRecapEntries(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count записа в дневника',
      one: '$count запис в дневника',
    );
    return '$_temp0';
  }

  @override
  String insightsRecapMoments(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count интимни момента',
      one: '$count интимен момент',
    );
    return '$_temp0';
  }

  @override
  String insightsRecapOrgasms(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count оргазма',
      one: '$count оргазъм',
    );
    return '$_temp0';
  }

  @override
  String get insightsTopSymptom => 'Най-чест симптом';

  @override
  String get insightsTopPosition => 'Любима поза';

  @override
  String get insightsAvgMood => 'Средно настроение';

  @override
  String get sectionPartner => 'ПАРТНЬОР';

  @override
  String get partnerTitle => 'Партньор';

  @override
  String get partnerSettingsSubtitle =>
      'Свържи се с партньор и си пишете със снимки и видео';

  @override
  String get partnerIntro =>
      'Свържете двете приложения с код и си пишете — текст, снимки и видео. Можете да имате повече от един партньор.';

  @override
  String get partnerStorageNotice =>
      'Споделените съобщения, снимки и видеа се пазят на нашите сървъри, за да стигат до партньора, и може да бъдат преглеждани за сигурност.';

  @override
  String get partnerStatusLinked => 'Свързани сте 💜';

  @override
  String get partnerInvite => 'Покани партньор';

  @override
  String get partnerAddAnother => 'Добави още партньор';

  @override
  String get partnerHaveCode => 'Имам код от партньор';

  @override
  String get partnerSayCode => 'Кажи този код на партньора си. Важи 15 минути.';

  @override
  String get partnerWaiting =>
      'Още никой не е въвел кода. Опитай пак след малко.';

  @override
  String get partnerCheck => 'Провери';

  @override
  String get partnerEnterCodeTitle => 'Код от партньора';

  @override
  String get partnerEnterCodeHint => 'напр. KX7M2PQA';

  @override
  String get partnerJoin => 'Свържи';

  @override
  String get partnerCodeInvalid => 'Непознат, зает или изтекъл код';

  @override
  String get partnerLinked => 'Партньорът е свързан 💜';

  @override
  String get partnerUnlink => 'Прекъсни връзката';

  @override
  String get partnerUnlinkTitle => 'Прекъсване на връзката?';

  @override
  String get partnerUnlinkBody =>
      'Чатът спира и за двамата и споделеното съдържание се изтрива от сървъра.';

  @override
  String get partnerUnlinked => 'Връзката е прекъсната';

  @override
  String get partnerNoteHint => 'Съобщение…';

  @override
  String get partnerSend => 'Изпрати';

  @override
  String get partnerSent => 'Изпратено 💌';

  @override
  String get partnerEmpty => 'Още няма съобщения.\nНапиши първото 💜';

  @override
  String get partnerYou => 'Ти';

  @override
  String partnerUnnamed(Object n) {
    return 'Партньор $n';
  }

  @override
  String get partnerNickname => 'Име на партньора';

  @override
  String get partnerNicknameHint => 'напр. Н.';

  @override
  String get partnerError =>
      'Връзката със сървъра не успя — провери интернета и опитай пак';

  @override
  String get notifChannelName => 'Нежни напомняния';

  @override
  String get notifChannelDesc => 'Дискретни напомняния от Intima';

  @override
  String get notifEvening => 'Малко време само за теб 💜';

  @override
  String get notifPeriod => 'Подготвили сме календара ти 🌸';

  @override
  String get notifOvulation => 'Специален ден от цикъла 💫';
}
