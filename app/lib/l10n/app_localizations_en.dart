// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Intima';

  @override
  String get onbPrivacyTitle => 'Yours alone.';

  @override
  String get onbPrivacyBody =>
      'Everything stays on your phone, encrypted.\nNo account. No cloud. No prying eyes.';

  @override
  String get onbCalendarTitle => 'Intimacy calendar';

  @override
  String get onbCalendarBody =>
      'Cycle, mood, intimate moments —\nall on one discreet screen.';

  @override
  String get onbDiaryTitle => 'Intimacy diary';

  @override
  String get onbDiaryBody =>
      'Capture the moments you want to remember.\nJust for you. Or for two.';

  @override
  String get onbNext => 'Continue';

  @override
  String get onbStart => 'Get started';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navDiary => 'Diary';

  @override
  String get navInsights => 'Insights';

  @override
  String get navSettings => 'Settings';

  @override
  String get bootStarting => 'Starting…';

  @override
  String get bootDb => 'Unlocking your data…';

  @override
  String get bootPrefs => 'Loading preferences…';

  @override
  String get bootLock => 'Checking protection…';

  @override
  String get bootSecure => 'Covering your tracks…';

  @override
  String get bootNotifications => 'Preparing reminders…';

  @override
  String bootStepFailed(Object step, Object error) {
    return '$step — failed ($error)';
  }

  @override
  String get bootRetry => 'Try again';

  @override
  String get lockEnterPin => 'Enter your PIN';

  @override
  String get lockWrongPin => 'Wrong PIN — try again';

  @override
  String get pinChoose => 'Choose a PIN';

  @override
  String get pinConfirm => 'Confirm your PIN';

  @override
  String get pinMismatch => 'The PINs don\'t match — try again';

  @override
  String get pinHint => 'You\'ll enter it every time you open Intima.';

  @override
  String get pinEnterCurrent => 'Enter your current PIN';

  @override
  String get weekdaysNarrow => 'M,T,W,T,F,S,S';

  @override
  String get prevMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get legendPeriod => 'Period';

  @override
  String get legendPredicted => 'Expected';

  @override
  String get legendIntimacy => 'Intimacy';

  @override
  String get legendFertile => 'Fertile days';

  @override
  String todayCard(Object date) {
    return 'Today · $date';
  }

  @override
  String get noLogToday => 'No entry for today yet';

  @override
  String moodLabel(Object emoji) {
    return 'Mood: $emoji';
  }

  @override
  String get energyLabel => 'Energy ';

  @override
  String get predictionHint =>
      'Mark the first day of your period and Intima will predict your next cycle and fertile days.';

  @override
  String nextCycleAround(Object date, Object countdown) {
    return 'Next cycle — around $date ($countdown)';
  }

  @override
  String get anyMomentNow => 'expected any moment';

  @override
  String inDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in $count days',
      one: 'in $count day',
    );
    return '$_temp0';
  }

  @override
  String cycleOfDays(Object days) {
    return 'Based on a $days-day cycle · adjust in Settings';
  }

  @override
  String get saved => 'Saved ✨';

  @override
  String savedAutoFilled(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Saved ✨ We marked $count more period days',
      one: 'Saved ✨ We marked $count more period day',
    );
    return '$_temp0';
  }

  @override
  String savedCleared(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Saved ✨ We also cleared $count more period days',
      one: 'Saved ✨ We also cleared $count more period day',
    );
    return '$_temp0';
  }

  @override
  String get howAreYouToday => 'How are you today?';

  @override
  String logFor(Object date) {
    return 'Entry for $date';
  }

  @override
  String get intimateMoment => 'Intimate moment ♥';

  @override
  String get tagPeriod => 'Period';

  @override
  String get tagPms => 'PMS';

  @override
  String get tagHeadache => 'Headache';

  @override
  String get tagBadSleep => 'Poor sleep';

  @override
  String momentN(Object n) {
    return 'Moment $n';
  }

  @override
  String get arousal => 'Arousal';

  @override
  String get orgasms => 'Orgasms';

  @override
  String get positions => 'Positions';

  @override
  String get posMissionary => 'Missionary';

  @override
  String get posSpoons => 'Spooning';

  @override
  String get posOnTop => 'On top';

  @override
  String get posBehind => 'From behind';

  @override
  String get posStanding => 'Standing';

  @override
  String get pos69 => '69';

  @override
  String get posOther => 'Other';

  @override
  String get momentNoteHint => 'Describe the moment… (just for you)';

  @override
  String get addAnotherMoment => 'Add another moment';

  @override
  String get libido => 'Libido';

  @override
  String get energy => 'Energy';

  @override
  String get saveSparkle => 'Save ✨';

  @override
  String get diaryTitle => 'Diary';

  @override
  String get searchEntries => 'Search your entries…';

  @override
  String get diaryEmpty =>
      'Your moments will live here. 💜\nStart with the button below.';

  @override
  String nothingFoundFor(Object query) {
    return 'Nothing found for “$query”.';
  }

  @override
  String get memoryFromBefore => 'A memory from a while ago';

  @override
  String memoryQuote(Object title, Object date) {
    return '“$title” · $date';
  }

  @override
  String get newEntry => 'New entry';

  @override
  String get editEntry => 'Edit entry';

  @override
  String get save => 'Save';

  @override
  String get deleteEntryTooltip => 'Delete entry';

  @override
  String get tplFree => 'Free writing';

  @override
  String get tplFreeHint => 'Start writing…';

  @override
  String get tplFeelings => 'How I feel';

  @override
  String get tplFeelingsHint =>
      'What are you feeling right now? What sparked it?';

  @override
  String get tplGratitude => 'Gratitude';

  @override
  String get tplGratitudeHint => 'The little things count too.';

  @override
  String get tplGratitudeStarter => 'Today I\'m grateful for ';

  @override
  String get tplUs => 'About us 💞';

  @override
  String get tplUsHint => 'A moment you want to remember together.';

  @override
  String get tplUsStarter => 'Something I want to remember about us: ';

  @override
  String get addPhoto => 'Add photo';

  @override
  String get newTag => 'New tag';

  @override
  String get newTagTitle => 'New tag';

  @override
  String get tagNameLabel => 'Tag name';

  @override
  String get tagNameHint => 'e.g. us';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get deleteEntryTitle => 'Delete this entry?';

  @override
  String get deleteEntryBody =>
      'The entry and its photos will be gone forever.';

  @override
  String get delete => 'Delete';

  @override
  String get removePhotoTitle => 'Remove this photo?';

  @override
  String get removePhotoBody =>
      'The photo will be permanently removed from the entry.';

  @override
  String get remove => 'Remove';

  @override
  String get galleryUnavailable => 'Gallery is not available';

  @override
  String get photoMissing => 'Photo missing 📷';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get sectionCycle => 'CYCLE';

  @override
  String get cycleLength => 'Cycle length';

  @override
  String get cycleLengthSubtitle => 'Used to predict your next period';

  @override
  String get cycleLengthHint =>
      'From the first day of one period to the first day of the next.';

  @override
  String get periodLength => 'Period length';

  @override
  String get periodLengthHint => 'How many days your period usually lasts.';

  @override
  String daysValue(Object days) {
    return '$days days';
  }

  @override
  String get expectedNextPeriod => 'Expected next period';

  @override
  String get markPeriodInCalendar => 'Mark a period in the calendar';

  @override
  String savedNextPeriod(Object date) {
    return 'Saved ✨ Next period — around $date';
  }

  @override
  String get sectionSecurity => 'SECURITY';

  @override
  String get pinLock => 'PIN lock';

  @override
  String get pinLockSubtitle => 'Requires a PIN every time you open the app';

  @override
  String get pinConfirmToDisable => 'Confirm with your PIN to turn off';

  @override
  String get pinEnabled => 'PIN lock is on 🔒';

  @override
  String get pinDisabled => 'PIN lock is off';

  @override
  String get biometrics => 'Biometrics';

  @override
  String get biometricsSubtitle => 'Fingerprint or face instead of a PIN';

  @override
  String get biometricsNeedPin =>
      'Enable a PIN first — biometrics complement it';

  @override
  String get biometricsUnavailable =>
      'Biometrics are not available on this device';

  @override
  String get stealthPin => 'Decoy PIN (Stealth)';

  @override
  String get stealthSubtitle =>
      'A second PIN that opens an empty copy of Intima';

  @override
  String get stealthNeedPin => 'Enable the PIN lock first';

  @override
  String get stealthSameAsMain =>
      'That PIN matches your main one — choose a different one';

  @override
  String get stealthEnabled => 'Decoy PIN is on 🕶️';

  @override
  String get stealthDisabled => 'Decoy PIN is off';

  @override
  String get stealthChange => 'Change PIN';

  @override
  String get stealthTurnOff => 'Turn off';

  @override
  String get statusOn => 'On';

  @override
  String get statusOff => 'Off';

  @override
  String get hideInRecents => 'Hide in recent apps';

  @override
  String get hideInRecentsSubtitle => 'Also blocks screenshots';

  @override
  String get sectionReminders => 'REMINDERS';

  @override
  String get eveningReminder => 'Evening reminder';

  @override
  String get eveningReminderSubtitle => 'Discreet — never reveals the content';

  @override
  String get beforePeriod => 'Before your period';

  @override
  String get beforePeriodSubtitle => 'Discreet, 2 days ahead';

  @override
  String get onOvulationDay => 'On ovulation day';

  @override
  String get timeLabel => 'Time';

  @override
  String get sectionData => 'DATA';

  @override
  String get exportData => 'Export your data';

  @override
  String get exportTitle => 'Export your data';

  @override
  String get exportBody =>
      'All entries will be exported as an encrypted file (AES-256). It cannot be read without the key from this device.';

  @override
  String get exportAction => 'Export';

  @override
  String get exportSubject => 'Intima — encrypted archive';

  @override
  String exportFailed(Object error) {
    return 'Export failed: $error';
  }

  @override
  String get deleteAll => 'Delete everything';

  @override
  String get deleteAllTitle => 'Delete everything?';

  @override
  String get deleteAllBody =>
      'All entries will be deleted forever. This cannot be undone.';

  @override
  String get deletedAll => 'All data has been deleted forever 🗑️';

  @override
  String get sectionAbout => 'ABOUT';

  @override
  String get version => 'Version';

  @override
  String get versionValue => '0.1.0 · prototype';

  @override
  String get themeTitle => 'Theme';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get themeSystem => 'Follow system';

  @override
  String get paletteTitle => 'Palette';

  @override
  String get paletteIntima => 'Intima · purple & gold';

  @override
  String get paletteRoseGold => 'Rose gold';

  @override
  String get paletteMidnightBlue => 'Midnight blue';

  @override
  String get paletteOcean => 'Ocean';

  @override
  String get paletteApplied => 'Palette changed 🎨';

  @override
  String get sectionPremium => 'INTIMA PREMIUM';

  @override
  String get premiumTitle => 'Intima Premium';

  @override
  String get premiumTagline => 'More room for intimacy';

  @override
  String get premiumSettingsSubtitle => 'PDF export, new themes and more';

  @override
  String get premiumFeaturePdf => 'Diary PDF export';

  @override
  String get premiumFeaturePdfDesc =>
      'A beautiful document with all your entries and photos';

  @override
  String get premiumFeatureThemes => 'Light theme and new palettes';

  @override
  String get premiumFeatureStealth => 'Stealth mode and decoy PIN';

  @override
  String get premiumFeaturePacks => 'Themed packs for couples';

  @override
  String get comingSoon => 'soon';

  @override
  String get premiumTrial => '7 days free — cancel anytime';

  @override
  String get premiumCta => 'Start your free trial';

  @override
  String get premiumComingSoon => 'Purchases arrive with the first update ✨';

  @override
  String get premiumActive => 'Premium is active 💜';

  @override
  String get pdfExportTitle => 'Export diary to PDF';

  @override
  String get pdfExporting => 'Preparing your PDF…';

  @override
  String get pdfEmpty => 'Your diary is empty — nothing to export yet.';

  @override
  String get pdfSubject => 'Intima — diary (PDF)';

  @override
  String get pdfDocTitle => 'My diary';

  @override
  String pdfFailed(Object error) {
    return 'Export failed: $error';
  }

  @override
  String get insightsTitle => 'Insights';

  @override
  String get insightsPrivacyNote => 'Computed entirely on your device 🔒';

  @override
  String get insightsTeaser =>
      'See what your data has to say — your real cycle length, mood by phase, libido trends. Entirely on your device, nothing ever leaves it.';

  @override
  String get insightsUnlock => 'Unlock with Premium';

  @override
  String get insightsEmpty =>
      'Not enough data yet.\nKeep logging your cycle and mood and your trends will appear here. 💜';

  @override
  String get insightsCycleCard => 'Your cycle';

  @override
  String insightsAvgDays(Object value) {
    return '$value days';
  }

  @override
  String insightsMeasuredFrom(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Measured from $count real cycles',
      one: 'Measured from $count real cycle',
    );
    return '$_temp0';
  }

  @override
  String insightsCycleRange(Object min, Object max) {
    return 'Between $min and $max days';
  }

  @override
  String get insightsCycleNeedTwo =>
      'Mark at least two periods in the calendar and we\'ll measure your real cycle length — not just the setting.';

  @override
  String insightsVsSetting(Object days) {
    return 'Setting: $days days';
  }

  @override
  String get insightsMoodCard => 'Mood by phase';

  @override
  String get phaseMenstrual => 'Menstrual';

  @override
  String get phaseFollicular => 'Follicular';

  @override
  String get phaseOvulation => 'Ovulation';

  @override
  String get phaseLuteal => 'Luteal';

  @override
  String get insightsMoodHint =>
      'Log your mood more often to see how it relates to your cycle.';

  @override
  String get insightsTrendCard => 'Libido & energy by month';

  @override
  String get insightsRecapCard => 'The last 30 days';

  @override
  String insightsRecapEntries(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count diary entries',
      one: '$count diary entry',
    );
    return '$_temp0';
  }

  @override
  String insightsRecapMoments(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count intimate moments',
      one: '$count intimate moment',
    );
    return '$_temp0';
  }

  @override
  String insightsRecapOrgasms(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orgasms',
      one: '$count orgasm',
    );
    return '$_temp0';
  }

  @override
  String get insightsTopSymptom => 'Most frequent symptom';

  @override
  String get insightsTopPosition => 'Favourite position';

  @override
  String get insightsAvgMood => 'Average mood';

  @override
  String get notifChannelName => 'Gentle reminders';

  @override
  String get notifChannelDesc => 'Discreet reminders from Intima';

  @override
  String get notifEvening => 'A little time just for you 💜';

  @override
  String get notifPeriod => 'We\'ve prepared your calendar 🌸';

  @override
  String get notifOvulation => 'A special day of your cycle 💫';
}
