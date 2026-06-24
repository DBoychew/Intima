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
  /// **'Дискретно и лично'**
  String get onbPrivacyTitle;

  /// No description provided for @onbPrivacyBody.
  ///
  /// In bg, this message translates to:
  /// **'Заключи приложението с PIN.\nСподеляш с партньор само когато ти решиш.'**
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

  /// No description provided for @navInsights.
  ///
  /// In bg, this message translates to:
  /// **'Инсайти'**
  String get navInsights;

  /// No description provided for @navPartner.
  ///
  /// In bg, this message translates to:
  /// **'Партньор'**
  String get navPartner;

  /// No description provided for @navProfile.
  ///
  /// In bg, this message translates to:
  /// **'Профил'**
  String get navProfile;

  /// No description provided for @navSettings.
  ///
  /// In bg, this message translates to:
  /// **'Настройки'**
  String get navSettings;

  /// No description provided for @dayDetailEdit.
  ///
  /// In bg, this message translates to:
  /// **'Запиши / редактирай'**
  String get dayDetailEdit;

  /// No description provided for @dayPhasePeriod.
  ///
  /// In bg, this message translates to:
  /// **'Менструация'**
  String get dayPhasePeriod;

  /// No description provided for @dayPhasePredicted.
  ///
  /// In bg, this message translates to:
  /// **'Очаквана менструация'**
  String get dayPhasePredicted;

  /// No description provided for @dayPhaseOvulation.
  ///
  /// In bg, this message translates to:
  /// **'Овулация'**
  String get dayPhaseOvulation;

  /// No description provided for @dayPhaseFertile.
  ///
  /// In bg, this message translates to:
  /// **'Фертилен прозорец'**
  String get dayPhaseFertile;

  /// No description provided for @dayPhaseRegular.
  ///
  /// In bg, this message translates to:
  /// **'Извън фертилния прозорец'**
  String get dayPhaseRegular;

  /// No description provided for @dayNoData.
  ///
  /// In bg, this message translates to:
  /// **'Няма запис за този ден'**
  String get dayNoData;

  /// No description provided for @detailMood.
  ///
  /// In bg, this message translates to:
  /// **'Настроение'**
  String get detailMood;

  /// No description provided for @detailLibido.
  ///
  /// In bg, this message translates to:
  /// **'Либидо'**
  String get detailLibido;

  /// No description provided for @detailEnergy.
  ///
  /// In bg, this message translates to:
  /// **'Енергия'**
  String get detailEnergy;

  /// No description provided for @detailSymptoms.
  ///
  /// In bg, this message translates to:
  /// **'Симптоми'**
  String get detailSymptoms;

  /// No description provided for @detailMoments.
  ///
  /// In bg, this message translates to:
  /// **'{count, plural, one{{count} интимен момент} other{{count} интимни момента}}'**
  String detailMoments(num count);

  /// No description provided for @fertilityTitle.
  ///
  /// In bg, this message translates to:
  /// **'Шанс за забременяване'**
  String get fertilityTitle;

  /// No description provided for @fertVeryHigh.
  ///
  /// In bg, this message translates to:
  /// **'Много висок'**
  String get fertVeryHigh;

  /// No description provided for @fertHigh.
  ///
  /// In bg, this message translates to:
  /// **'Висок'**
  String get fertHigh;

  /// No description provided for @fertModerate.
  ///
  /// In bg, this message translates to:
  /// **'Умерен'**
  String get fertModerate;

  /// No description provided for @fertLow.
  ///
  /// In bg, this message translates to:
  /// **'Нисък'**
  String get fertLow;

  /// No description provided for @fertNegligible.
  ///
  /// In bg, this message translates to:
  /// **'Незначителен'**
  String get fertNegligible;

  /// No description provided for @fertApprox.
  ///
  /// In bg, this message translates to:
  /// **'около {pct}%'**
  String fertApprox(Object pct);

  /// No description provided for @fertOnOvulation.
  ///
  /// In bg, this message translates to:
  /// **'Днес е денят на овулацията'**
  String get fertOnOvulation;

  /// No description provided for @fertBeforeOvulation.
  ///
  /// In bg, this message translates to:
  /// **'{days, plural, one{{days} ден преди овулацията} other{{days} дни преди овулацията}}'**
  String fertBeforeOvulation(num days);

  /// No description provided for @fertAfterOvulation.
  ///
  /// In bg, this message translates to:
  /// **'{days, plural, one{{days} ден след овулацията} other{{days} дни след овулацията}}'**
  String fertAfterOvulation(num days);

  /// No description provided for @fertDisclaimer.
  ///
  /// In bg, this message translates to:
  /// **'Приблизителна оценка по дни от овулацията — не е метод за контрацепция.'**
  String get fertDisclaimer;

  /// No description provided for @fertNoData.
  ///
  /// In bg, this message translates to:
  /// **'Отбележи менструация, за да изчислим шанса.'**
  String get fertNoData;

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
  /// **'Овулация'**
  String get legendFertile;

  /// No description provided for @ovulationInfoTitle.
  ///
  /// In bg, this message translates to:
  /// **'Овулация и фертилни дни'**
  String get ovulationInfoTitle;

  /// No description provided for @ovulationInfoBody.
  ///
  /// In bg, this message translates to:
  /// **'Овулацията е моментът, в който яйцеклетката се освобождава — обикновено около 14 дни преди следващата менструация.\n\nНай-голяма е вероятността за забременяване в деня на овулацията и в петте дни преди нея: сперматозоидите оцеляват до 5 дни, а яйцеклетката живее около 24 часа. Затова Intima отбелязва в зелено овулацията и по 2 дни около нея, изчислени според твоя цикъл.\n\nПрогнозата е ориентировъчна — цикълът варира — и не е метод за контрацепция.'**
  String get ovulationInfoBody;

  /// No description provided for @ovulationGotIt.
  ///
  /// In bg, this message translates to:
  /// **'Разбрах'**
  String get ovulationGotIt;

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
  /// **'Отбележи първия ден от менструацията си и Intima ще предвижда следващия цикъл и овулацията.'**
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

  /// No description provided for @addVideo.
  ///
  /// In bg, this message translates to:
  /// **'Добави видео'**
  String get addVideo;

  /// No description provided for @removeVideoTitle.
  ///
  /// In bg, this message translates to:
  /// **'Премахване на видеото?'**
  String get removeVideoTitle;

  /// No description provided for @removeVideoBody.
  ///
  /// In bg, this message translates to:
  /// **'Видеото ще бъде изтрито от записа завинаги.'**
  String get removeVideoBody;

  /// No description provided for @videoMissing.
  ///
  /// In bg, this message translates to:
  /// **'Видеото не може да се възпроизведе 🎬'**
  String get videoMissing;

  /// No description provided for @addAudio.
  ///
  /// In bg, this message translates to:
  /// **'Аудио бележка'**
  String get addAudio;

  /// No description provided for @audioRecording.
  ///
  /// In bg, this message translates to:
  /// **'Записваме…'**
  String get audioRecording;

  /// No description provided for @audioStopSave.
  ///
  /// In bg, this message translates to:
  /// **'Стоп и запази'**
  String get audioStopSave;

  /// No description provided for @audioPermissionDenied.
  ///
  /// In bg, this message translates to:
  /// **'Нужен е достъп до микрофона, за да запишеш аудио бележка'**
  String get audioPermissionDenied;

  /// No description provided for @removeAudioTitle.
  ///
  /// In bg, this message translates to:
  /// **'Премахване на аудиото?'**
  String get removeAudioTitle;

  /// No description provided for @removeAudioBody.
  ///
  /// In bg, this message translates to:
  /// **'Аудио бележката ще бъде изтрита завинаги.'**
  String get removeAudioBody;

  /// No description provided for @audioMissing.
  ///
  /// In bg, this message translates to:
  /// **'Аудиото не може да се пусне 🎙️'**
  String get audioMissing;

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

  /// No description provided for @stealthPin.
  ///
  /// In bg, this message translates to:
  /// **'Фалшив PIN (Stealth)'**
  String get stealthPin;

  /// No description provided for @stealthSubtitle.
  ///
  /// In bg, this message translates to:
  /// **'Втори PIN, който отваря празно копие на Intima'**
  String get stealthSubtitle;

  /// No description provided for @stealthNeedPin.
  ///
  /// In bg, this message translates to:
  /// **'Първо активирай PIN заключването'**
  String get stealthNeedPin;

  /// No description provided for @stealthSameAsMain.
  ///
  /// In bg, this message translates to:
  /// **'Този PIN съвпада с основния — избери различен'**
  String get stealthSameAsMain;

  /// No description provided for @stealthEnabled.
  ///
  /// In bg, this message translates to:
  /// **'Фалшивият PIN е активен 🕶️'**
  String get stealthEnabled;

  /// No description provided for @stealthDisabled.
  ///
  /// In bg, this message translates to:
  /// **'Фалшивият PIN е изключен'**
  String get stealthDisabled;

  /// No description provided for @stealthChange.
  ///
  /// In bg, this message translates to:
  /// **'Промени PIN-а'**
  String get stealthChange;

  /// No description provided for @stealthTurnOff.
  ///
  /// In bg, this message translates to:
  /// **'Изключи'**
  String get stealthTurnOff;

  /// No description provided for @statusOn.
  ///
  /// In bg, this message translates to:
  /// **'Вкл.'**
  String get statusOn;

  /// No description provided for @statusOff.
  ///
  /// In bg, this message translates to:
  /// **'Изкл.'**
  String get statusOff;

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

  /// No description provided for @aboutData.
  ///
  /// In bg, this message translates to:
  /// **'Данни и поверителност'**
  String get aboutData;

  /// No description provided for @aboutDataTitle.
  ///
  /// In bg, this message translates to:
  /// **'Данни и поверителност'**
  String get aboutDataTitle;

  /// No description provided for @aboutDataBody.
  ///
  /// In bg, this message translates to:
  /// **'Записите в дневника, календара и инсайтите се пазят криптирани на това устройство и може да се заключат с PIN.\n\nСнимките и видеата, които добавяш в дневника, се качват и на нашите сървъри като лично копие — вижда ги само твоят профил, а за сигурност може да бъдат преглеждани от нас.\n\nКогато се свържеш с партньор, споделените съобщения, снимки и видеа се пазят на нашите сървъри, за да стигат до партньора, и може да бъдат преглеждани за сигурност. Прекъсването на връзката премахва активната партньорска връзка и чат записите; пълно server-side изтриване може да се поиска през privacy контакта.\n\nПълните подробности са в Политиката за поверителност.'**
  String get aboutDataBody;

  /// No description provided for @close.
  ///
  /// In bg, this message translates to:
  /// **'Затвори'**
  String get close;

  /// No description provided for @themeTitle.
  ///
  /// In bg, this message translates to:
  /// **'Тема'**
  String get themeTitle;

  /// No description provided for @themeDark.
  ///
  /// In bg, this message translates to:
  /// **'Тъмна'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In bg, this message translates to:
  /// **'Светла'**
  String get themeLight;

  /// No description provided for @themeSystem.
  ///
  /// In bg, this message translates to:
  /// **'Според системата'**
  String get themeSystem;

  /// No description provided for @sectionGeneral.
  ///
  /// In bg, this message translates to:
  /// **'ОБЩИ'**
  String get sectionGeneral;

  /// No description provided for @languageTitle.
  ///
  /// In bg, this message translates to:
  /// **'Език'**
  String get languageTitle;

  /// No description provided for @languageSystem.
  ///
  /// In bg, this message translates to:
  /// **'Според системата'**
  String get languageSystem;

  /// No description provided for @profileTitle.
  ///
  /// In bg, this message translates to:
  /// **'Профил'**
  String get profileTitle;

  /// No description provided for @profileSetName.
  ///
  /// In bg, this message translates to:
  /// **'Задай име'**
  String get profileSetName;

  /// No description provided for @profileName.
  ///
  /// In bg, this message translates to:
  /// **'Име'**
  String get profileName;

  /// No description provided for @profileNameHint.
  ///
  /// In bg, this message translates to:
  /// **'Как да те наричаме'**
  String get profileNameHint;

  /// No description provided for @profileChangePhoto.
  ///
  /// In bg, this message translates to:
  /// **'Смени снимката'**
  String get profileChangePhoto;

  /// No description provided for @sectionAccount.
  ///
  /// In bg, this message translates to:
  /// **'АКАУНТ'**
  String get sectionAccount;

  /// No description provided for @accountSignedOut.
  ///
  /// In bg, this message translates to:
  /// **'Влез, за да пазиш профила си и да го ползваш на няколко устройства.'**
  String get accountSignedOut;

  /// No description provided for @accountSignedIn.
  ///
  /// In bg, this message translates to:
  /// **'Влязъл/а си 💜'**
  String get accountSignedIn;

  /// No description provided for @accountSignOut.
  ///
  /// In bg, this message translates to:
  /// **'Изход'**
  String get accountSignOut;

  /// No description provided for @signInFacebook.
  ///
  /// In bg, this message translates to:
  /// **'Продължи с Facebook'**
  String get signInFacebook;

  /// No description provided for @signInGoogle.
  ///
  /// In bg, this message translates to:
  /// **'Продължи с Google'**
  String get signInGoogle;

  /// No description provided for @accountProvidersNote.
  ///
  /// In bg, this message translates to:
  /// **'Instagram и TikTok вход все още не се поддържат.'**
  String get accountProvidersNote;

  /// No description provided for @paletteTitle.
  ///
  /// In bg, this message translates to:
  /// **'Палитра'**
  String get paletteTitle;

  /// No description provided for @paletteIntima.
  ///
  /// In bg, this message translates to:
  /// **'Intima · лилаво и злато'**
  String get paletteIntima;

  /// No description provided for @paletteRoseGold.
  ///
  /// In bg, this message translates to:
  /// **'Роуз голд'**
  String get paletteRoseGold;

  /// No description provided for @paletteMidnightBlue.
  ///
  /// In bg, this message translates to:
  /// **'Среднощно синьо'**
  String get paletteMidnightBlue;

  /// No description provided for @paletteOcean.
  ///
  /// In bg, this message translates to:
  /// **'Океан'**
  String get paletteOcean;

  /// No description provided for @paletteApplied.
  ///
  /// In bg, this message translates to:
  /// **'Палитрата е сменена 🎨'**
  String get paletteApplied;

  /// No description provided for @sectionPremium.
  ///
  /// In bg, this message translates to:
  /// **'INTIMA PREMIUM'**
  String get sectionPremium;

  /// No description provided for @premiumTitle.
  ///
  /// In bg, this message translates to:
  /// **'Intima Premium'**
  String get premiumTitle;

  /// No description provided for @premiumTagline.
  ///
  /// In bg, this message translates to:
  /// **'Повече пространство за близостта'**
  String get premiumTagline;

  /// No description provided for @premiumSettingsSubtitle.
  ///
  /// In bg, this message translates to:
  /// **'PDF експорт, нови теми и още'**
  String get premiumSettingsSubtitle;

  /// No description provided for @premiumFeaturePdf.
  ///
  /// In bg, this message translates to:
  /// **'PDF експорт на дневника'**
  String get premiumFeaturePdf;

  /// No description provided for @premiumFeaturePdfDesc.
  ///
  /// In bg, this message translates to:
  /// **'Красив документ с всичките ти записи и снимки'**
  String get premiumFeaturePdfDesc;

  /// No description provided for @premiumFeatureThemes.
  ///
  /// In bg, this message translates to:
  /// **'Светла тема и нови палитри'**
  String get premiumFeatureThemes;

  /// No description provided for @premiumFeatureStealth.
  ///
  /// In bg, this message translates to:
  /// **'Stealth режим и фалшив PIN'**
  String get premiumFeatureStealth;

  /// No description provided for @premiumFeatureInsights.
  ///
  /// In bg, this message translates to:
  /// **'Инсайти и статистики'**
  String get premiumFeatureInsights;

  /// No description provided for @premiumFeatureVideo.
  ///
  /// In bg, this message translates to:
  /// **'Видео в дневника'**
  String get premiumFeatureVideo;

  /// No description provided for @premiumFeatureAudio.
  ///
  /// In bg, this message translates to:
  /// **'Аудио бележки в дневника'**
  String get premiumFeatureAudio;

  /// No description provided for @premiumFeaturePacks.
  ///
  /// In bg, this message translates to:
  /// **'Тематични пакети за двойки'**
  String get premiumFeaturePacks;

  /// No description provided for @comingSoon.
  ///
  /// In bg, this message translates to:
  /// **'скоро'**
  String get comingSoon;

  /// No description provided for @premiumTrial.
  ///
  /// In bg, this message translates to:
  /// **'7 дни безплатно — отказваш се по всяко време'**
  String get premiumTrial;

  /// No description provided for @premiumCta.
  ///
  /// In bg, this message translates to:
  /// **'Започни пробния период'**
  String get premiumCta;

  /// No description provided for @premiumComingSoon.
  ///
  /// In bg, this message translates to:
  /// **'Покупките идват с първия ъпдейт ✨'**
  String get premiumComingSoon;

  /// No description provided for @premiumActive.
  ///
  /// In bg, this message translates to:
  /// **'Premium е активен 💜'**
  String get premiumActive;

  /// No description provided for @pdfExportTitle.
  ///
  /// In bg, this message translates to:
  /// **'Експорт на дневника в PDF'**
  String get pdfExportTitle;

  /// No description provided for @pdfExporting.
  ///
  /// In bg, this message translates to:
  /// **'Подготвяме PDF…'**
  String get pdfExporting;

  /// No description provided for @pdfEmpty.
  ///
  /// In bg, this message translates to:
  /// **'Дневникът е празен — няма какво да експортираме.'**
  String get pdfEmpty;

  /// No description provided for @pdfSubject.
  ///
  /// In bg, this message translates to:
  /// **'Intima — дневник (PDF)'**
  String get pdfSubject;

  /// No description provided for @pdfDocTitle.
  ///
  /// In bg, this message translates to:
  /// **'Моят дневник'**
  String get pdfDocTitle;

  /// No description provided for @pdfFailed.
  ///
  /// In bg, this message translates to:
  /// **'Експортът не успя: {error}'**
  String pdfFailed(Object error);

  /// No description provided for @insightsTitle.
  ///
  /// In bg, this message translates to:
  /// **'Инсайти'**
  String get insightsTitle;

  /// No description provided for @insightsPrivacyNote.
  ///
  /// In bg, this message translates to:
  /// **'Изчислено изцяло на устройството 🔒'**
  String get insightsPrivacyNote;

  /// No description provided for @insightsSampleBadge.
  ///
  /// In bg, this message translates to:
  /// **'Примерен изглед с демо данни'**
  String get insightsSampleBadge;

  /// No description provided for @insightsTeaser.
  ///
  /// In bg, this message translates to:
  /// **'Виж какво разказват твоите данни — реална дължина на цикъла, настроение по фази, тенденции на либидото.'**
  String get insightsTeaser;

  /// No description provided for @insightsUnlock.
  ///
  /// In bg, this message translates to:
  /// **'Отключи с Premium'**
  String get insightsUnlock;

  /// No description provided for @insightsEmpty.
  ///
  /// In bg, this message translates to:
  /// **'Все още няма достатъчно данни.\nОтбелязвай цикъла и настроението си и тук ще се появят твоите тенденции. 💜'**
  String get insightsEmpty;

  /// No description provided for @insightsCycleCard.
  ///
  /// In bg, this message translates to:
  /// **'Твоят цикъл'**
  String get insightsCycleCard;

  /// No description provided for @insightsAvgDays.
  ///
  /// In bg, this message translates to:
  /// **'{value} дни'**
  String insightsAvgDays(Object value);

  /// No description provided for @insightsMeasuredFrom.
  ///
  /// In bg, this message translates to:
  /// **'{count, plural, one{Изчислено от {count} реален цикъл} other{Изчислено от {count} реални цикъла}}'**
  String insightsMeasuredFrom(num count);

  /// No description provided for @insightsCycleRange.
  ///
  /// In bg, this message translates to:
  /// **'Между {min} и {max} дни'**
  String insightsCycleRange(Object min, Object max);

  /// No description provided for @insightsCycleNeedTwo.
  ///
  /// In bg, this message translates to:
  /// **'Отбележи поне две менструации в календара и ще изчислим реалната дължина на цикъла ти — не само настройката.'**
  String get insightsCycleNeedTwo;

  /// No description provided for @insightsVsSetting.
  ///
  /// In bg, this message translates to:
  /// **'Настройка: {days} дни'**
  String insightsVsSetting(Object days);

  /// No description provided for @insightsMoodCard.
  ///
  /// In bg, this message translates to:
  /// **'Настроение по фази'**
  String get insightsMoodCard;

  /// No description provided for @phaseMenstrual.
  ///
  /// In bg, this message translates to:
  /// **'Менструация'**
  String get phaseMenstrual;

  /// No description provided for @phaseFollicular.
  ///
  /// In bg, this message translates to:
  /// **'Фоликуларна'**
  String get phaseFollicular;

  /// No description provided for @phaseOvulation.
  ///
  /// In bg, this message translates to:
  /// **'Овулация'**
  String get phaseOvulation;

  /// No description provided for @phaseLuteal.
  ///
  /// In bg, this message translates to:
  /// **'Лутеална'**
  String get phaseLuteal;

  /// No description provided for @insightsMoodHint.
  ///
  /// In bg, this message translates to:
  /// **'Записвай настроението си по-често, за да видиш връзката му с цикъла.'**
  String get insightsMoodHint;

  /// No description provided for @insightsTrendCard.
  ///
  /// In bg, this message translates to:
  /// **'Либидо и енергия по месеци'**
  String get insightsTrendCard;

  /// No description provided for @insightsRecapCard.
  ///
  /// In bg, this message translates to:
  /// **'Последните 30 дни'**
  String get insightsRecapCard;

  /// No description provided for @insightsRecapEntries.
  ///
  /// In bg, this message translates to:
  /// **'{count, plural, one{{count} запис в дневника} other{{count} записа в дневника}}'**
  String insightsRecapEntries(num count);

  /// No description provided for @insightsRecapMoments.
  ///
  /// In bg, this message translates to:
  /// **'{count, plural, one{{count} интимен момент} other{{count} интимни момента}}'**
  String insightsRecapMoments(num count);

  /// No description provided for @insightsRecapOrgasms.
  ///
  /// In bg, this message translates to:
  /// **'{count, plural, one{{count} оргазъм} other{{count} оргазма}}'**
  String insightsRecapOrgasms(num count);

  /// No description provided for @insightsTopSymptom.
  ///
  /// In bg, this message translates to:
  /// **'Най-чест симптом'**
  String get insightsTopSymptom;

  /// No description provided for @insightsTopPosition.
  ///
  /// In bg, this message translates to:
  /// **'Любима поза'**
  String get insightsTopPosition;

  /// No description provided for @insightsAvgMood.
  ///
  /// In bg, this message translates to:
  /// **'Средно настроение'**
  String get insightsAvgMood;

  /// No description provided for @insightsCorrTitle.
  ///
  /// In bg, this message translates to:
  /// **'Какво забелязваме'**
  String get insightsCorrTitle;

  /// No description provided for @corrMoodFertileUp.
  ///
  /// In bg, this message translates to:
  /// **'Настроението ти обикновено е по-добро във фертилните дни.'**
  String get corrMoodFertileUp;

  /// No description provided for @corrMoodFertileDown.
  ///
  /// In bg, this message translates to:
  /// **'Настроението ти обикновено е по-ниско във фертилните дни.'**
  String get corrMoodFertileDown;

  /// No description provided for @corrIntimacyFertile.
  ///
  /// In bg, this message translates to:
  /// **'Около {pct}% от интимните моменти попадат във фертилния прозорец.'**
  String corrIntimacyFertile(Object pct);

  /// No description provided for @corrLibidoEnergyTogether.
  ///
  /// In bg, this message translates to:
  /// **'Либидото и енергията ти често вървят заедно.'**
  String get corrLibidoEnergyTogether;

  /// No description provided for @corrLibidoEnergyOpposite.
  ///
  /// In bg, this message translates to:
  /// **'Либидото и енергията ти често се движат в различни посоки.'**
  String get corrLibidoEnergyOpposite;

  /// No description provided for @promptSuggestionTitle.
  ///
  /// In bg, this message translates to:
  /// **'Подсказка за днес'**
  String get promptSuggestionTitle;

  /// No description provided for @promptUse.
  ///
  /// In bg, this message translates to:
  /// **'Използвай'**
  String get promptUse;

  /// No description provided for @promptMenstrual.
  ///
  /// In bg, this message translates to:
  /// **'Как се грижиш за себе си тези дни?'**
  String get promptMenstrual;

  /// No description provided for @promptFollicular.
  ///
  /// In bg, this message translates to:
  /// **'Какво те вдъхновява тази седмица?'**
  String get promptFollicular;

  /// No description provided for @promptOvulation.
  ///
  /// In bg, this message translates to:
  /// **'Кое те кара да се чувстваш близо до някого днес?'**
  String get promptOvulation;

  /// No description provided for @promptLuteal.
  ///
  /// In bg, this message translates to:
  /// **'Какво ти носи спокойствие, когато енергията спадне?'**
  String get promptLuteal;

  /// No description provided for @promptNeutral.
  ///
  /// In bg, this message translates to:
  /// **'За какво искаш да си спомняш този ден?'**
  String get promptNeutral;

  /// No description provided for @sectionPartner.
  ///
  /// In bg, this message translates to:
  /// **'ПАРТНЬОР'**
  String get sectionPartner;

  /// No description provided for @partnerTitle.
  ///
  /// In bg, this message translates to:
  /// **'Партньор'**
  String get partnerTitle;

  /// No description provided for @partnerSettingsSubtitle.
  ///
  /// In bg, this message translates to:
  /// **'Свържи се с партньор и си пишете със снимки и видео'**
  String get partnerSettingsSubtitle;

  /// No description provided for @partnerIntro.
  ///
  /// In bg, this message translates to:
  /// **'Свържете двете приложения с код и си пишете — текст, снимки и видео. Можете да имате повече от един партньор.'**
  String get partnerIntro;

  /// No description provided for @partnerStorageNotice.
  ///
  /// In bg, this message translates to:
  /// **'Споделените съобщения, снимки и видеа се пазят на нашите сървъри, за да стигат до партньора, и може да бъдат преглеждани за сигурност.'**
  String get partnerStorageNotice;

  /// No description provided for @partnerStatusLinked.
  ///
  /// In bg, this message translates to:
  /// **'Свързани сте 💜'**
  String get partnerStatusLinked;

  /// No description provided for @partnerInvite.
  ///
  /// In bg, this message translates to:
  /// **'Покани партньор'**
  String get partnerInvite;

  /// No description provided for @partnerAddAnother.
  ///
  /// In bg, this message translates to:
  /// **'Добави още партньор'**
  String get partnerAddAnother;

  /// No description provided for @partnerHaveCode.
  ///
  /// In bg, this message translates to:
  /// **'Имам код от партньор'**
  String get partnerHaveCode;

  /// No description provided for @partnerSayCode.
  ///
  /// In bg, this message translates to:
  /// **'Кажи този код на партньора си. Важи 15 минути.'**
  String get partnerSayCode;

  /// No description provided for @partnerWaiting.
  ///
  /// In bg, this message translates to:
  /// **'Още никой не е въвел кода. Опитай пак след малко.'**
  String get partnerWaiting;

  /// No description provided for @partnerCheck.
  ///
  /// In bg, this message translates to:
  /// **'Провери'**
  String get partnerCheck;

  /// No description provided for @partnerEnterCodeTitle.
  ///
  /// In bg, this message translates to:
  /// **'Код от партньора'**
  String get partnerEnterCodeTitle;

  /// No description provided for @partnerEnterCodeHint.
  ///
  /// In bg, this message translates to:
  /// **'напр. KX7M2PQA'**
  String get partnerEnterCodeHint;

  /// No description provided for @partnerJoin.
  ///
  /// In bg, this message translates to:
  /// **'Свържи'**
  String get partnerJoin;

  /// No description provided for @partnerCodeInvalid.
  ///
  /// In bg, this message translates to:
  /// **'Непознат, зает или изтекъл код'**
  String get partnerCodeInvalid;

  /// No description provided for @partnerLinked.
  ///
  /// In bg, this message translates to:
  /// **'Партньорът е свързан 💜'**
  String get partnerLinked;

  /// No description provided for @partnerUnlink.
  ///
  /// In bg, this message translates to:
  /// **'Прекъсни връзката'**
  String get partnerUnlink;

  /// No description provided for @partnerUnlinkTitle.
  ///
  /// In bg, this message translates to:
  /// **'Прекъсване на връзката?'**
  String get partnerUnlinkTitle;

  /// No description provided for @partnerUnlinkBody.
  ///
  /// In bg, this message translates to:
  /// **'Чатът спира и за двамата. Активната партньорска връзка и чат записите се премахват; пълно server-side изтриване може да се поиска през privacy контакта.'**
  String get partnerUnlinkBody;

  /// No description provided for @partnerUnlinked.
  ///
  /// In bg, this message translates to:
  /// **'Връзката е прекъсната'**
  String get partnerUnlinked;

  /// No description provided for @partnerNoteHint.
  ///
  /// In bg, this message translates to:
  /// **'Съобщение…'**
  String get partnerNoteHint;

  /// No description provided for @partnerSend.
  ///
  /// In bg, this message translates to:
  /// **'Изпрати'**
  String get partnerSend;

  /// No description provided for @partnerSent.
  ///
  /// In bg, this message translates to:
  /// **'Изпратено 💌'**
  String get partnerSent;

  /// No description provided for @partnerEmpty.
  ///
  /// In bg, this message translates to:
  /// **'Още няма съобщения.\nНапиши първото 💜'**
  String get partnerEmpty;

  /// No description provided for @partnerYou.
  ///
  /// In bg, this message translates to:
  /// **'Ти'**
  String get partnerYou;

  /// No description provided for @partnerUnnamed.
  ///
  /// In bg, this message translates to:
  /// **'Партньор {n}'**
  String partnerUnnamed(Object n);

  /// No description provided for @partnerNickname.
  ///
  /// In bg, this message translates to:
  /// **'Име на партньора'**
  String get partnerNickname;

  /// No description provided for @partnerNicknameHint.
  ///
  /// In bg, this message translates to:
  /// **'напр. Н.'**
  String get partnerNicknameHint;

  /// No description provided for @partnerError.
  ///
  /// In bg, this message translates to:
  /// **'Връзката със сървъра не успя — провери интернета и опитай пак'**
  String get partnerError;

  /// No description provided for @posesTitle.
  ///
  /// In bg, this message translates to:
  /// **'Библиотека с пози'**
  String get posesTitle;

  /// No description provided for @posesSubtitle.
  ///
  /// In bg, this message translates to:
  /// **'Идеи за близост — отбелязвай, оценявай, пробвай'**
  String get posesSubtitle;

  /// No description provided for @posesEmpty.
  ///
  /// In bg, this message translates to:
  /// **'Няма пози по този филтър.'**
  String get posesEmpty;

  /// No description provided for @poseArtNote.
  ///
  /// In bg, this message translates to:
  /// **'Стилизирани илюстрации предстоят'**
  String get poseArtNote;

  /// No description provided for @filterAll.
  ///
  /// In bg, this message translates to:
  /// **'Всички'**
  String get filterAll;

  /// No description provided for @poseDifficulty.
  ///
  /// In bg, this message translates to:
  /// **'Трудност'**
  String get poseDifficulty;

  /// No description provided for @poseIntensity.
  ///
  /// In bg, this message translates to:
  /// **'Интензивност'**
  String get poseIntensity;

  /// No description provided for @poseMoodLabel.
  ///
  /// In bg, this message translates to:
  /// **'Настроение'**
  String get poseMoodLabel;

  /// No description provided for @poseStatusLabel.
  ///
  /// In bg, this message translates to:
  /// **'Статус'**
  String get poseStatusLabel;

  /// No description provided for @packStarter.
  ///
  /// In bg, this message translates to:
  /// **'Старт'**
  String get packStarter;

  /// No description provided for @packRomance.
  ///
  /// In bg, this message translates to:
  /// **'Романтика'**
  String get packRomance;

  /// No description provided for @packAdventure.
  ///
  /// In bg, this message translates to:
  /// **'Приключение'**
  String get packAdventure;

  /// No description provided for @poseMoodTender.
  ///
  /// In bg, this message translates to:
  /// **'Нежно'**
  String get poseMoodTender;

  /// No description provided for @poseMoodPlayful.
  ///
  /// In bg, this message translates to:
  /// **'Игриво'**
  String get poseMoodPlayful;

  /// No description provided for @poseMoodPassionate.
  ///
  /// In bg, this message translates to:
  /// **'Страстно'**
  String get poseMoodPassionate;

  /// No description provided for @poseMoodAdventurous.
  ///
  /// In bg, this message translates to:
  /// **'Приключенско'**
  String get poseMoodAdventurous;

  /// No description provided for @poseMoodSlow.
  ///
  /// In bg, this message translates to:
  /// **'Бавно'**
  String get poseMoodSlow;

  /// No description provided for @poseStatusWantToTry.
  ///
  /// In bg, this message translates to:
  /// **'Искам да пробвам'**
  String get poseStatusWantToTry;

  /// No description provided for @poseStatusTried.
  ///
  /// In bg, this message translates to:
  /// **'Пробвано'**
  String get poseStatusTried;

  /// No description provided for @poseStatusFavorite.
  ///
  /// In bg, this message translates to:
  /// **'Любимо'**
  String get poseStatusFavorite;

  /// No description provided for @poseLocked.
  ///
  /// In bg, this message translates to:
  /// **'Тази колекция е Premium'**
  String get poseLocked;

  /// No description provided for @poseUnlock.
  ///
  /// In bg, this message translates to:
  /// **'Отключи с Premium'**
  String get poseUnlock;

  /// No description provided for @poseRate.
  ///
  /// In bg, this message translates to:
  /// **'Оцени'**
  String get poseRate;

  /// No description provided for @poseNote.
  ///
  /// In bg, this message translates to:
  /// **'Лична бележка'**
  String get poseNote;

  /// No description provided for @poseNoteHint.
  ///
  /// In bg, this message translates to:
  /// **'Само за теб…'**
  String get poseNoteHint;

  /// No description provided for @poseTriedOn.
  ///
  /// In bg, this message translates to:
  /// **'Пробвано на'**
  String get poseTriedOn;

  /// No description provided for @poseMarkTriedToday.
  ///
  /// In bg, this message translates to:
  /// **'Отбележи „пробвано днес“'**
  String get poseMarkTriedToday;

  /// No description provided for @poseSaved.
  ///
  /// In bg, this message translates to:
  /// **'Запазено ✨'**
  String get poseSaved;

  /// No description provided for @coupleMatchTitle.
  ///
  /// In bg, this message translates to:
  /// **'Съвпадение 💘'**
  String get coupleMatchTitle;

  /// No description provided for @coupleMatchBody.
  ///
  /// In bg, this message translates to:
  /// **'Ти и {partner} искате да пробвате „{pose}“.'**
  String coupleMatchBody(Object partner, Object pose);

  /// No description provided for @coupleMatchNew.
  ///
  /// In bg, this message translates to:
  /// **'Имате ново съвпадение 💘'**
  String get coupleMatchNew;

  /// No description provided for @poseMatchBadge.
  ///
  /// In bg, this message translates to:
  /// **'Съвпадение'**
  String get poseMatchBadge;

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
