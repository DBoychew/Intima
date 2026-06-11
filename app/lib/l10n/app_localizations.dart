import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bg.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bg'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In bg, this message translates to:
  /// **'Intima'**
  String get appName;

  /// No description provided for @onbPrivacyTitle.
  ///
  /// In bg, this message translates to:
  /// **'Само твое.'**
  String get onbPrivacyTitle;

  /// No description provided for @onbPrivacyBody.
  ///
  /// In bg, this message translates to:
  /// **'Всичко остава на телефона ти, криптирано.\nБез акаунт. Без облак. Без любопитни очи.'**
  String get onbPrivacyBody;

  /// No description provided for @onbCalendarTitle.
  ///
  /// In bg, this message translates to:
  /// **'Календар на близостта'**
  String get onbCalendarTitle;

  /// No description provided for @onbCalendarBody.
  ///
  /// In bg, this message translates to:
  /// **'Цикъл, настроение, интимни моменти —\nвсичко на един дискретен екран.'**
  String get onbCalendarBody;

  /// No description provided for @onbDiaryTitle.
  ///
  /// In bg, this message translates to:
  /// **'Дневник на близостта'**
  String get onbDiaryTitle;

  /// No description provided for @onbDiaryBody.
  ///
  /// In bg, this message translates to:
  /// **'Записвай моментите, които искаш да запомниш.\nСамо за теб. Или за двама.'**
  String get onbDiaryBody;

  /// No description provided for @onbNext.
  ///
  /// In bg, this message translates to:
  /// **'Продължи'**
  String get onbNext;

  /// No description provided for @onbStart.
  ///
  /// In bg, this message translates to:
  /// **'Започни'**
  String get onbStart;

  /// No description provided for @navCalendar.
  ///
  /// In bg, this message translates to:
  /// **'Календар'**
  String get navCalendar;

  /// No description provided for @navDiary.
  ///
  /// In bg, this message translates to:
  /// **'Дневник'**
  String get navDiary;

  /// No description provided for @navSettings.
  ///
  /// In bg, this message translates to:
  /// **'Настройки'**
  String get navSettings;

  /// No description provided for @bootStarting.
  ///
  /// In bg, this message translates to:
  /// **'Стартираме…'**
  String get bootStarting;

  /// No description provided for @bootDb.
  ///
  /// In bg, this message translates to:
  /// **'Отключваме базата…'**
  String get bootDb;

  /// No description provided for @bootPrefs.
  ///
  /// In bg, this message translates to:
  /// **'Зареждаме настройките…'**
  String get bootPrefs;

  /// No description provided for @bootLock.
  ///
  /// In bg, this message translates to:
  /// **'Проверяваме защитата…'**
  String get bootLock;

  /// No description provided for @bootSecure.
  ///
  /// In bg, this message translates to:
  /// **'Скриваме следите…'**
  String get bootSecure;

  /// No description provided for @bootNotifications.
  ///
  /// In bg, this message translates to:
  /// **'Подготвяме напомнянията…'**
  String get bootNotifications;

  /// No description provided for @bootStepFailed.
  ///
  /// In bg, this message translates to:
  /// **'{step} — неуспешно ({error})'**
  String bootStepFailed(Object step, Object error);

  /// No description provided for @bootRetry.
  ///
  /// In bg, this message translates to:
  /// **'Опитай отново'**
  String get bootRetry;

  /// No description provided for @lockEnterPin.
  ///
  /// In bg, this message translates to:
  /// **'Въведи своя PIN'**
  String get lockEnterPin;

  /// No description provided for @lockWrongPin.
  ///
  /// In bg, this message translates to:
  /// **'Грешен PIN — опитай отново'**
  String get lockWrongPin;

  /// No description provided for @pinChoose.
  ///
  /// In bg, this message translates to:
  /// **'Избери PIN код'**
  String get pinChoose;

  /// No description provided for @pinConfirm.
  ///
  /// In bg, this message translates to:
  /// **'Потвърди PIN кода'**
  String get pinConfirm;

  /// No description provided for @pinMismatch.
  ///
  /// In bg, this message translates to:
  /// **'PIN кодовете не съвпадат — опитай отново'**
  String get pinMismatch;

  /// No description provided for @pinHint.
  ///
  /// In bg, this message translates to:
  /// **'Ще го въвеждаш при всяко отваряне на Intima.'**
  String get pinHint;

  /// No description provided for @pinEnterCurrent.
  ///
  /// In bg, this message translates to:
  /// **'Въведи текущия PIN'**
  String get pinEnterCurrent;

  /// No description provided for @weekdaysNarrow.
  ///
  /// In bg, this message translates to:
  /// **'П,В,С,Ч,П,С,Н'**
  String get weekdaysNarrow;

  /// No description provided for @prevMonth.
  ///
  /// In bg, this message translates to:
  /// **'Предишен месец'**
  String get prevMonth;

  /// No description provided for @nextMonth.
  ///
  /// In bg, this message translates to:
  /// **'Следващ месец'**
  String get nextMonth;

  /// No description provided for @legendPeriod.
  ///
  /// In bg, this message translates to:
  /// **'Менструация'**
  String get legendPeriod;

  /// No description provided for @legendPredicted.
  ///
  /// In bg, this message translates to:
  /// **'Очаквана'**
  String get legendPredicted;

  /// No description provided for @legendIntimacy.
  ///
  /// In bg, this message translates to:
  /// **'Интимност'**
  String get legendIntimacy;

  /// No description provided for @legendFertile.
  ///
  /// In bg, this message translates to:
  /// **'Фертилни дни'**
  String get legendFertile;

  /// No description provided for @todayCard.
  ///
  /// In bg, this message translates to:
  /// **'Днес · {date}'**
  String todayCard(Object date);

  /// No description provided for @noLogToday.
  ///
  /// In bg, this message translates to:
  /// **'Все още няма запис за днес'**
  String get noLogToday;

  /// No description provided for @moodLabel.
  ///
  /// In bg, this message translates to:
  /// **'Настроение: {emoji}'**
  String moodLabel(Object emoji);

  /// No description provided for @energyLabel.
  ///
  /// In bg, this message translates to:
  /// **'Енергия '**
  String get energyLabel;

  /// No description provided for @predictionHint.
  ///
  /// In bg, this message translates to:
  /// **'Отбележи първия ден от менструацията си и Intima ще предвижда следващия цикъл и фертилните дни.'**
  String get predictionHint;

  /// No description provided for @nextCycleAround.
  ///
  /// In bg, this message translates to:
  /// **'Следващ цикъл — около {date} ({countdown})'**
  String nextCycleAround(Object date, Object countdown);

  /// No description provided for @anyMomentNow.
  ///
  /// In bg, this message translates to:
  /// **'очаква се всеки момент'**
  String get anyMomentNow;

  /// No description provided for @inDays.
  ///
  /// In bg, this message translates to:
  /// **'{count, plural, one{след {count} ден} other{след {count} дни}}'**
  String inDays(num count);

  /// No description provided for @cycleOfDays.
  ///
  /// In bg, this message translates to:
  /// **'При цикъл от {days} дни · настройва се от Настройки'**
  String cycleOfDays(Object days);

  /// No description provided for @saved.
  ///
  /// In bg, this message translates to:
  /// **'Записано ✨'**
  String get saved;

  /// No description provided for @savedAutoFilled.
  ///
  /// In bg, this message translates to:
  /// **'{count, plural, one{Записано ✨ Отбелязахме още {count} ден от менструацията} other{Записано ✨ Отбелязахме още {count} дни от менструацията}}'**
  String savedAutoFilled(num count);

  /// No description provided for @savedCleared.
  ///
  /// In bg, this message translates to:
  /// **'{count, plural, one{Записано ✨ Премахнахме и още {count} ден от менструацията} other{Записано ✨ Премахнахме и още {count} дни от менструацията}}'**
  String savedCleared(num count);

  /// No description provided for @howAreYouToday.
  ///
  /// In bg, this message translates to:
  /// **'Как си днес?'**
  String get howAreYouToday;

  /// No description provided for @logFor.
  ///
  /// In bg, this message translates to:
  /// **'Запис за {date}'**
  String logFor(Object date);

  /// No description provided for @intimateMoment.
  ///
  /// In bg, this message translates to:
  /// **'Интимен момент ♥'**
  String get intimateMoment;

  /// No description provided for @tagPeriod.
  ///
  /// In bg, this message translates to:
  /// **'Менструация'**
  String get tagPeriod;

  /// No description provided for @tagPms.
  ///
  /// In bg, this message translates to:
  /// **'ПМС'**
  String get tagPms;

  /// No description provided for @tagHeadache.
  ///
  /// In bg, this message translates to:
  /// **'Главоболие'**
  String get tagHeadache;

  /// No description provided for @tagBadSleep.
  ///
  /// In bg, this message translates to:
  /// **'Лош сън'**
  String get tagBadSleep;

  /// No description provided for @momentN.
  ///
  /// In bg, this message translates to:
  /// **'Момент {n}'**
  String momentN(Object n);

  /// No description provided for @arousal.
  ///
  /// In bg, this message translates to:
  /// **'Възбуда'**
  String get arousal;

  /// No description provided for @orgasms.
  ///
  /// In bg, this message translates to:
  /// **'Оргазми'**
  String get orgasms;

  /// No description provided for @positions.
  ///
  /// In bg, this message translates to:
  /// **'Пози'**
  String get positions;

  /// No description provided for @posMissionary.
  ///
  /// In bg, this message translates to:
  /// **'Мисионерска'**
  String get posMissionary;

  /// No description provided for @posSpoons.
  ///
  /// In bg, this message translates to:
  /// **'Лъжички'**
  String get posSpoons;

  /// No description provided for @posOnTop.
  ///
  /// In bg, this message translates to:
  /// **'Отгоре'**
  String get posOnTop;

  /// No description provided for @posBehind.
  ///
  /// In bg, this message translates to:
  /// **'Отзад'**
  String get posBehind;

  /// No description provided for @posStanding.
  ///
  /// In bg, this message translates to:
  /// **'Права'**
  String get posStanding;

  /// No description provided for @pos69.
  ///
  /// In bg, this message translates to:
  /// **'69'**
  String get pos69;

  /// No description provided for @posOther.
  ///
  /// In bg, this message translates to:
  /// **'Друга'**
  String get posOther;

  /// No description provided for @momentNoteHint.
  ///
  /// In bg, this message translates to:
  /// **'Опиши момента… (само за теб)'**
  String get momentNoteHint;

  /// No description provided for @addAnotherMoment.
  ///
  /// In bg, this message translates to:
  /// **'Добави още един момент'**
  String get addAnotherMoment;

  /// No description provided for @libido.
  ///
  /// In bg, this message translates to:
  /// **'Либидо'**
  String get libido;

  /// No description provided for @energy.
  ///
  /// In bg, this message translates to:
  /// **'Енергия'**
  String get energy;

  /// No description provided for @saveSparkle.
  ///
  /// In bg, this message translates to:
  /// **'Запази ✨'**
  String get saveSparkle;

  /// No description provided for @diaryTitle.
  ///
  /// In bg, this message translates to:
  /// **'Дневник'**
  String get diaryTitle;

  /// No description provided for @searchEntries.
  ///
  /// In bg, this message translates to:
  /// **'Търси в записите…'**
  String get searchEntries;

  /// No description provided for @diaryEmpty.
  ///
  /// In bg, this message translates to:
  /// **'Тук ще живеят твоите моменти. 💜\nЗапочни с бутона долу.'**
  String get diaryEmpty;

  /// No description provided for @nothingFoundFor.
  ///
  /// In bg, this message translates to:
  /// **'Нищо не открихме за „{query}“.'**
  String nothingFoundFor(Object query);

  /// No description provided for @memoryFromBefore.
  ///
  /// In bg, this message translates to:
  /// **'Спомен от преди време'**
  String get memoryFromBefore;

  /// No description provided for @memoryQuote.
  ///
  /// In bg, this message translates to:
  /// **'„{title}“ · {date}'**
  String memoryQuote(Object title, Object date);

  /// No description provided for @newEntry.
  ///
  /// In bg, this message translates to:
  /// **'Нов запис'**
  String get newEntry;

  /// No description provided for @editEntry.
  ///
  /// In bg, this message translates to:
  /// **'Редакция'**
  String get editEntry;

  /// No description provided for @save.
  ///
  /// In bg, this message translates to:
  /// **'Запази'**
  String get save;

  /// No description provided for @deleteEntryTooltip.
  ///
  /// In bg, this message translates to:
  /// **'Изтрий записа'**
  String get deleteEntryTooltip;

  /// No description provided for @tplFree.
  ///
  /// In bg, this message translates to:
  /// **'Свободен текст'**
  String get tplFree;

  /// No description provided for @tplFreeHint.
  ///
  /// In bg, this message translates to:
  /// **'Започни да пишеш…'**
  String get tplFreeHint;

  /// No description provided for @tplFeelings.
  ///
  /// In bg, this message translates to:
  /// **'Как се чувствам'**
  String get tplFeelings;

  /// No description provided for @tplFeelingsHint.
  ///
  /// In bg, this message translates to:
  /// **'Какво усещаш в момента? Какво го предизвика?'**
  String get tplFeelingsHint;

  /// No description provided for @tplGratitude.
  ///
  /// In bg, this message translates to:
  /// **'Благодарност'**
  String get tplGratitude;

  /// No description provided for @tplGratitudeHint.
  ///
  /// In bg, this message translates to:
  /// **'Малките неща също се броят.'**
  String get tplGratitudeHint;

  /// No description provided for @tplGratitudeStarter.
  ///
  /// In bg, this message translates to:
  /// **'Днес съм благодарна за '**
  String get tplGratitudeStarter;

  /// No description provided for @tplUs.
  ///
  /// In bg, this message translates to:
  /// **'За нас 💞'**
  String get tplUs;

  /// No description provided for @tplUsHint.
  ///
  /// In bg, this message translates to:
  /// **'Момент, който искаш да запомните заедно.'**
  String get tplUsHint;

  /// No description provided for @tplUsStarter.
  ///
  /// In bg, this message translates to:
  /// **'Нещо, което искам да запомня за нас: '**
  String get tplUsStarter;

  /// No description provided for @addPhoto.
  ///
  /// In bg, this message translates to:
  /// **'Добави снимка'**
  String get addPhoto;

  /// No description provided for @newTag.
  ///
  /// In bg, this message translates to:
  /// **'Нов таг'**
  String get newTag;

  /// No description provided for @newTagTitle.
  ///
  /// In bg, this message translates to:
  /// **'Нов таг'**
  String get newTagTitle;

  /// No description provided for @tagNameLabel.
  ///
  /// In bg, this message translates to:
  /// **'Име на тага'**
  String get tagNameLabel;

  /// No description provided for @tagNameHint.
  ///
  /// In bg, this message translates to:
  /// **'напр. нас'**
  String get tagNameHint;

  /// No description provided for @cancel.
  ///
  /// In bg, this message translates to:
  /// **'Отказ'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In bg, this message translates to:
  /// **'Добави'**
  String get add;

  /// No description provided for @deleteEntryTitle.
  ///
  /// In bg, this message translates to:
  /// **'Изтриване на записа?'**
  String get deleteEntryTitle;

  /// No description provided for @deleteEntryBody.
  ///
  /// In bg, this message translates to:
  /// **'Записът и снимките му ще изчезнат завинаги.'**
  String get deleteEntryBody;

  /// No description provided for @delete.
  ///
  /// In bg, this message translates to:
  /// **'Изтрий'**
  String get delete;

  /// No description provided for @removePhotoTitle.
  ///
  /// In bg, this message translates to:
  /// **'Премахване на снимката?'**
  String get removePhotoTitle;

  /// No description provided for @removePhotoBody.
  ///
  /// In bg, this message translates to:
  /// **'Снимката ще бъде изтрита от записа завинаги.'**
  String get removePhotoBody;

  /// No description provided for @remove.
  ///
  /// In bg, this message translates to:
  /// **'Премахни'**
  String get remove;

  /// No description provided for @galleryUnavailable.
  ///
  /// In bg, this message translates to:
  /// **'Галерията не е достъпна'**
  String get galleryUnavailable;

  /// No description provided for @photoMissing.
  ///
  /// In bg, this message translates to:
  /// **'Снимката липсва 📷'**
  String get photoMissing;

  /// No description provided for @settingsTitle.
  ///
  /// In bg, this message translates to:
  /// **'Настройки'**
  String get settingsTitle;

  /// No description provided for @sectionCycle.
  ///
  /// In bg, this message translates to:
  /// **'ЦИКЪЛ'**
  String get sectionCycle;

  /// No description provided for @cycleLength.
  ///
  /// In bg, this message translates to:
  /// **'Дължина на цикъла'**
  String get cycleLength;

  /// No description provided for @cycleLengthSubtitle.
  ///
  /// In bg, this message translates to:
  /// **'По нея предвиждаме следващата менструация'**
  String get cycleLengthSubtitle;

  /// No description provided for @cycleLengthHint.
  ///
  /// In bg, this message translates to:
  /// **'От първия ден на една менструация до първия ден на следващата.'**
  String get cycleLengthHint;

  /// No description provided for @periodLength.
  ///
  /// In bg, this message translates to:
  /// **'Дължина на менструацията'**
  String get periodLength;

  /// No description provided for @periodLengthHint.
  ///
  /// In bg, this message translates to:
  /// **'Колко дни обикновено продължава менструацията ти.'**
  String get periodLengthHint;

  /// No description provided for @daysValue.
  ///
  /// In bg, this message translates to:
  /// **'{days} дни'**
  String daysValue(Object days);

  /// No description provided for @expectedNextPeriod.
  ///
  /// In bg, this message translates to:
  /// **'Очаквана следваща менструация'**
  String get expectedNextPeriod;

  /// No description provided for @markPeriodInCalendar.
  ///
  /// In bg, this message translates to:
  /// **'Отбележи менструация в календара'**
  String get markPeriodInCalendar;

  /// No description provided for @savedNextPeriod.
  ///
  /// In bg, this message translates to:
  /// **'Записано ✨ Следваща менструация — около {date}'**
  String savedNextPeriod(Object date);

  /// No description provided for @sectionSecurity.
  ///
  /// In bg, this message translates to:
  /// **'СИГУРНОСТ'**
  String get sectionSecurity;

  /// No description provided for @pinLock.
  ///
  /// In bg, this message translates to:
  /// **'PIN заключване'**
  String get pinLock;

  /// No description provided for @pinLockSubtitle.
  ///
  /// In bg, this message translates to:
  /// **'Изисква PIN при всяко отваряне'**
  String get pinLockSubtitle;

  /// No description provided for @pinConfirmToDisable.
  ///
  /// In bg, this message translates to:
  /// **'Потвърди с PIN, за да изключиш'**
  String get pinConfirmToDisable;

  /// No description provided for @pinEnabled.
  ///
  /// In bg, this message translates to:
  /// **'PIN заключването е активно 🔒'**
  String get pinEnabled;

  /// No description provided for @pinDisabled.
  ///
  /// In bg, this message translates to:
  /// **'PIN заключването е изключено'**
  String get pinDisabled;

  /// No description provided for @biometrics.
  ///
  /// In bg, this message translates to:
  /// **'Биометрия'**
  String get biometrics;

  /// No description provided for @biometricsSubtitle.
  ///
  /// In bg, this message translates to:
  /// **'Пръстов отпечатък или лице вместо PIN'**
  String get biometricsSubtitle;

  /// No description provided for @biometricsNeedPin.
  ///
  /// In bg, this message translates to:
  /// **'Първо активирай PIN — биометрията е допълнение към него'**
  String get biometricsNeedPin;

  /// No description provided for @biometricsUnavailable.
  ///
  /// In bg, this message translates to:
  /// **'Биометрията не е налична на това устройство'**
  String get biometricsUnavailable;

  /// No description provided for @hideInRecents.
  ///
  /// In bg, this message translates to:
  /// **'Скрий в скорошни приложения'**
  String get hideInRecents;

  /// No description provided for @hideInRecentsSubtitle.
  ///
  /// In bg, this message translates to:
  /// **'Блокира и скрийншотите'**
  String get hideInRecentsSubtitle;

  /// No description provided for @sectionReminders.
  ///
  /// In bg, this message translates to:
  /// **'НАПОМНЯНИЯ'**
  String get sectionReminders;

  /// No description provided for @eveningReminder.
  ///
  /// In bg, this message translates to:
  /// **'Вечерно напомняне'**
  String get eveningReminder;

  /// No description provided for @eveningReminderSubtitle.
  ///
  /// In bg, this message translates to:
  /// **'Дискретно — без да издава съдържанието'**
  String get eveningReminderSubtitle;

  /// No description provided for @beforePeriod.
  ///
  /// In bg, this message translates to:
  /// **'Преди менструация'**
  String get beforePeriod;

  /// No description provided for @beforePeriodSubtitle.
  ///
  /// In bg, this message translates to:
  /// **'Дискретно, 2 дни по-рано'**
  String get beforePeriodSubtitle;

  /// No description provided for @onOvulationDay.
  ///
  /// In bg, this message translates to:
  /// **'В деня на овулация'**
  String get onOvulationDay;

  /// No description provided for @timeLabel.
  ///
  /// In bg, this message translates to:
  /// **'Час'**
  String get timeLabel;

  /// No description provided for @sectionData.
  ///
  /// In bg, this message translates to:
  /// **'ДАННИ'**
  String get sectionData;

  /// No description provided for @exportData.
  ///
  /// In bg, this message translates to:
  /// **'Експортирай данните'**
  String get exportData;

  /// No description provided for @exportTitle.
  ///
  /// In bg, this message translates to:
  /// **'Експорт на данните'**
  String get exportTitle;

  /// No description provided for @exportBody.
  ///
  /// In bg, this message translates to:
  /// **'Всички записи ще бъдат експортирани като криптиран файл (AES-256). Без ключа от това устройство той не може да бъде прочетен.'**
  String get exportBody;

  /// No description provided for @exportAction.
  ///
  /// In bg, this message translates to:
  /// **'Експортирай'**
  String get exportAction;

  /// No description provided for @exportSubject.
  ///
  /// In bg, this message translates to:
  /// **'Intima — криптиран архив'**
  String get exportSubject;

  /// No description provided for @exportFailed.
  ///
  /// In bg, this message translates to:
  /// **'Експортът не успя: {error}'**
  String exportFailed(Object error);

  /// No description provided for @deleteAll.
  ///
  /// In bg, this message translates to:
  /// **'Изтрий всичко'**
  String get deleteAll;

  /// No description provided for @deleteAllTitle.
  ///
  /// In bg, this message translates to:
  /// **'Изтриване на всичко?'**
  String get deleteAllTitle;

  /// No description provided for @deleteAllBody.
  ///
  /// In bg, this message translates to:
  /// **'Всички записи ще бъдат изтрити завинаги. Това не може да се отмени.'**
  String get deleteAllBody;

  /// No description provided for @deletedAll.
  ///
  /// In bg, this message translates to:
  /// **'Всички данни са изтрити завинаги 🗑️'**
  String get deletedAll;

  /// No description provided for @sectionAbout.
  ///
  /// In bg, this message translates to:
  /// **'ЗА ПРИЛОЖЕНИЕТО'**
  String get sectionAbout;

  /// No description provided for @version.
  ///
  /// In bg, this message translates to:
  /// **'Версия'**
  String get version;

  /// No description provided for @versionValue.
  ///
  /// In bg, this message translates to:
  /// **'0.1.0 · прототип'**
  String get versionValue;

  /// No description provided for @notifChannelName.
  ///
  /// In bg, this message translates to:
  /// **'Нежни напомняния'**
  String get notifChannelName;

  /// No description provided for @notifChannelDesc.
  ///
  /// In bg, this message translates to:
  /// **'Дискретни напомняния от Intima'**
  String get notifChannelDesc;

  /// No description provided for @notifEvening.
  ///
  /// In bg, this message translates to:
  /// **'Малко време само за теб 💜'**
  String get notifEvening;

  /// No description provided for @notifPeriod.
  ///
  /// In bg, this message translates to:
  /// **'Подготвили сме календара ти 🌸'**
  String get notifPeriod;

  /// No description provided for @notifOvulation.
  ///
  /// In bg, this message translates to:
  /// **'Специален ден от цикъла 💫'**
  String get notifOvulation;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bg', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bg':
      return AppLocalizationsBg();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
