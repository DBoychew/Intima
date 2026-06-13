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
  String get onbPrivacyTitle => 'Discreet and personal';

  @override
  String get onbPrivacyBody =>
      'Your diary and calendar live on your phone, locked with a PIN.\nShare with a partner only when you choose.';

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
  String get navPartner => 'Partner';

  @override
  String get navProfile => 'Profile';

  @override
  String get navSettings => 'Settings';

  @override
  String get dayDetailEdit => 'Log / edit';

  @override
  String get dayPhasePeriod => 'Period';

  @override
  String get dayPhasePredicted => 'Expected period';

  @override
  String get dayPhaseOvulation => 'Ovulation';

  @override
  String get dayPhaseFertile => 'Fertile window';

  @override
  String get dayPhaseRegular => 'Outside the fertile window';

  @override
  String get dayNoData => 'No entry for this day';

  @override
  String get detailMood => 'Mood';

  @override
  String get detailLibido => 'Libido';

  @override
  String get detailEnergy => 'Energy';

  @override
  String get detailSymptoms => 'Symptoms';

  @override
  String detailMoments(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count intimate moments',
      one: '$count intimate moment',
    );
    return '$_temp0';
  }

  @override
  String get fertilityTitle => 'Chance of pregnancy';

  @override
  String get fertVeryHigh => 'Very high';

  @override
  String get fertHigh => 'High';

  @override
  String get fertModerate => 'Moderate';

  @override
  String get fertLow => 'Low';

  @override
  String get fertNegligible => 'Negligible';

  @override
  String fertApprox(Object pct) {
    return 'about $pct%';
  }

  @override
  String get fertOnOvulation => 'Today is ovulation day';

  @override
  String fertBeforeOvulation(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days before ovulation',
      one: '$days day before ovulation',
    );
    return '$_temp0';
  }

  @override
  String fertAfterOvulation(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days after ovulation',
      one: '$days day after ovulation',
    );
    return '$_temp0';
  }

  @override
  String get fertDisclaimer =>
      'An estimate based on days from ovulation — not a method of contraception.';

  @override
  String get fertNoData => 'Mark a period so we can estimate the chance.';

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
  String get legendFertile => 'Ovulation';

  @override
  String get ovulationInfoTitle => 'Ovulation & fertile days';

  @override
  String get ovulationInfoBody =>
      'Ovulation is the moment an egg is released — usually about 14 days before your next period.\n\nPregnancy is most likely on the day of ovulation and during the five days before it: sperm can survive up to 5 days, while the egg lives for about 24 hours. That\'s why Intima highlights ovulation plus 2 days around it in green, based on your cycle.\n\nThe prediction is an estimate — cycles vary — and is not a method of contraception.';

  @override
  String get ovulationGotIt => 'Got it';

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
      'Mark the first day of your period and Intima will predict your next cycle and ovulation.';

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
  String get addVideo => 'Add video';

  @override
  String get removeVideoTitle => 'Remove this video?';

  @override
  String get removeVideoBody =>
      'The video will be deleted from the entry forever.';

  @override
  String get videoMissing => 'This video can\'t be played 🎬';

  @override
  String get addAudio => 'Audio note';

  @override
  String get audioRecording => 'Recording…';

  @override
  String get audioStopSave => 'Stop & save';

  @override
  String get audioPermissionDenied =>
      'Microphone access is needed to record an audio note';

  @override
  String get removeAudioTitle => 'Remove this audio note?';

  @override
  String get removeAudioBody => 'The audio note will be deleted forever.';

  @override
  String get audioMissing => 'This audio can\'t be played 🎙️';

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
  String get sectionGeneral => 'GENERAL';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSystem => 'Follow system';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileSetName => 'Set a name';

  @override
  String get profileName => 'Name';

  @override
  String get profileNameHint => 'What should we call you';

  @override
  String get profileChangePhoto => 'Change photo';

  @override
  String get sectionAccount => 'ACCOUNT';

  @override
  String get accountSignedOut =>
      'Sign in to keep your profile and use it across devices.';

  @override
  String get accountSignedIn => 'You\'re signed in 💜';

  @override
  String get accountSignOut => 'Sign out';

  @override
  String get signInFacebook => 'Continue with Facebook';

  @override
  String get signInGoogle => 'Continue with Google';

  @override
  String get accountProvidersNote =>
      'Instagram and TikTok sign-in aren\'t supported yet.';

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
  String get premiumFeatureInsights => 'Insights & statistics';

  @override
  String get premiumFeatureVideo => 'Videos in your diary';

  @override
  String get premiumFeatureAudio => 'Audio notes in your diary';

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
  String get insightsSampleBadge => 'Sample view with demo data';

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
  String get insightsCorrTitle => 'What we notice';

  @override
  String get corrMoodFertileUp =>
      'Your mood is usually better during your fertile days.';

  @override
  String get corrMoodFertileDown =>
      'Your mood is usually lower during your fertile days.';

  @override
  String corrIntimacyFertile(Object pct) {
    return 'About $pct% of intimate moments fall in the fertile window.';
  }

  @override
  String get corrLibidoEnergyTogether =>
      'Your libido and energy often rise and fall together.';

  @override
  String get corrLibidoEnergyOpposite =>
      'Your libido and energy often move in different directions.';

  @override
  String get promptSuggestionTitle => 'Today\'s prompt';

  @override
  String get promptUse => 'Use';

  @override
  String get promptMenstrual =>
      'How are you taking care of yourself these days?';

  @override
  String get promptFollicular => 'What\'s inspiring you this week?';

  @override
  String get promptOvulation => 'What makes you feel close to someone today?';

  @override
  String get promptLuteal => 'What brings you calm when your energy dips?';

  @override
  String get promptNeutral => 'What do you want to remember about this day?';

  @override
  String get sectionPartner => 'PARTNER';

  @override
  String get partnerTitle => 'Partner';

  @override
  String get partnerSettingsSubtitle =>
      'Link with a partner and chat with photos and video';

  @override
  String get partnerIntro =>
      'Link your two apps with a code and chat — text, photos and video. You can have more than one partner.';

  @override
  String get partnerStorageNotice =>
      'Shared messages, photos and videos are stored on our servers so they reach your partner, and may be reviewed for safety.';

  @override
  String get partnerStatusLinked => 'You\'re linked 💜';

  @override
  String get partnerInvite => 'Invite a partner';

  @override
  String get partnerAddAnother => 'Add another partner';

  @override
  String get partnerHaveCode => 'I have a code';

  @override
  String get partnerSayCode =>
      'Tell your partner this code. It\'s valid for 15 minutes.';

  @override
  String get partnerWaiting =>
      'Nobody has entered the code yet. Try again in a moment.';

  @override
  String get partnerCheck => 'Check';

  @override
  String get partnerEnterCodeTitle => 'Partner\'s code';

  @override
  String get partnerEnterCodeHint => 'e.g. KX7M2PQA';

  @override
  String get partnerJoin => 'Link';

  @override
  String get partnerCodeInvalid => 'Unknown, taken or expired code';

  @override
  String get partnerLinked => 'Partner linked 💜';

  @override
  String get partnerUnlink => 'Unlink';

  @override
  String get partnerUnlinkTitle => 'Unlink from this partner?';

  @override
  String get partnerUnlinkBody =>
      'The chat stops for both of you and the shared content is deleted from the server.';

  @override
  String get partnerUnlinked => 'Unlinked';

  @override
  String get partnerNoteHint => 'Message…';

  @override
  String get partnerSend => 'Send';

  @override
  String get partnerSent => 'Sent 💌';

  @override
  String get partnerEmpty => 'No messages yet.\nWrite the first one 💜';

  @override
  String get partnerYou => 'You';

  @override
  String partnerUnnamed(Object n) {
    return 'Partner $n';
  }

  @override
  String get partnerNickname => 'Partner\'s name';

  @override
  String get partnerNicknameHint => 'e.g. N.';

  @override
  String get partnerError =>
      'Couldn\'t reach the server — check your connection and try again';

  @override
  String get posesTitle => 'Pose library';

  @override
  String get posesSubtitle => 'Intimacy ideas — save, rate, try';

  @override
  String get posesEmpty => 'No poses match this filter.';

  @override
  String get poseArtNote => 'Stylised illustrations coming soon';

  @override
  String get filterAll => 'All';

  @override
  String get poseDifficulty => 'Difficulty';

  @override
  String get poseIntensity => 'Intensity';

  @override
  String get poseMoodLabel => 'Mood';

  @override
  String get poseStatusLabel => 'Status';

  @override
  String get packStarter => 'Starter';

  @override
  String get packRomance => 'Romance';

  @override
  String get packAdventure => 'Adventure';

  @override
  String get poseMoodTender => 'Tender';

  @override
  String get poseMoodPlayful => 'Playful';

  @override
  String get poseMoodPassionate => 'Passionate';

  @override
  String get poseMoodAdventurous => 'Adventurous';

  @override
  String get poseMoodSlow => 'Slow';

  @override
  String get poseStatusWantToTry => 'Want to try';

  @override
  String get poseStatusTried => 'Tried';

  @override
  String get poseStatusFavorite => 'Favourite';

  @override
  String get poseLocked => 'This collection is Premium';

  @override
  String get poseUnlock => 'Unlock with Premium';

  @override
  String get poseRate => 'Rate';

  @override
  String get poseNote => 'Private note';

  @override
  String get poseNoteHint => 'Just for you…';

  @override
  String get poseTriedOn => 'Tried on';

  @override
  String get poseMarkTriedToday => 'Mark \"tried today\"';

  @override
  String get poseSaved => 'Saved ✨';

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
