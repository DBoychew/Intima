# 🛍️ Google Play — материали за листинга (чернова за преглед)

> Лимити на Google Play: заглавие ≤ 30 знака, кратко описание ≤ 80 знака,
> пълно описание ≤ 4000 знака. Тонът е wellness — без explicit съдържание
> (изискване на store политиките и на PLAN.md Фаза 8 бележката).

## Заглавие (избери едно)

| Вариант | Знаци |
|---|---|
| **Intima — интимен календар** (BG) / **Intima — Cycle & Diary** (EN) | 26 / 22 |
| Intima: цикъл и дневник (BG) / Intima: Cycle & Diary (EN) | 23 / 21 |

## Кратко описание (≤ 80 знака)

**BG:** Интимен календар, дневник и чат за двойки — на едно дискретно място.
**EN:** Intimacy calendar, diary and partner chat — all in one discreet place.

## Пълно описание

### BG

**Твоят интимен живот. Само твой.**

Intima е дискретен календар и дневник за цикъла, настроението и близостта — а с режима за двойки можете да си пишете насаме.

🔒 **Дискретно и заключено**
• Текстът в дневника и календарът се пазят на устройството, заключени с PIN
• Локалните данни са криптирани (AES-256)
• PIN и биометрично заключване
• Скрито съдържание в скорошни приложения и блокирани скрийншоти
• Нотификациите никога не издават съдържанието
• Снимките от дневника имат частно сървърно копие само за твоя профил

💞 **Режим за двойки**
• Свържи се с партньор (или повече) с код
• Чат със снимки и видео
• Споделеното съдържание се синхронизира през нашите сървъри

📅 **Интимен календар**
• Цикъл, настроение, симптоми, либидо и енергия — запис под 10 секунди
• Умно отбелязване: маркираш първия ден, Intima попълва останалите
• Прогнози за следващ цикъл и фертилни дни според твоята дължина на цикъла
• Интимни моменти — толкова, колкото са били, с всички детайли, които искаш да запомниш

📔 **Личен дневник**
• Свободен текст, шаблони с журналинг промптове, настроения
• Снимки в защитено пространство — никога в общата галерия
• Тагове и търсене; „Спомен от преди време" те връща към хубавите дни

⏰ **Нежни напомняния**
• Вечерно напомняне в избран от теб час
• Дискретен сигнал преди очакваната менструация и в деня на овулация

🗑️ **Твоите данни, твоите правила**
• Експорт на криптиран архив по всяко време
• Пълно изтриване с едно докосване — без следа

Без абонамент за основните функции. Без продажба на данни.

### EN

**Your intimate life. Yours alone.**

Intima is a discreet cycle, mood and intimacy companion — and with partner mode you can chat privately together.

🔒 **Discreet and locked**
• Your diary text and calendar stay on your device, locked with a PIN
• Local data is encrypted (AES-256)
• PIN and biometric lock
• Hidden in recent apps, screenshots blocked
• Notifications never reveal the content
• Diary photos have a private server copy for your account only

💞 **Partner mode**
• Link with a partner (or more) using a code
• Chat with photos and video
• Shared content syncs through our servers

📅 **Intimacy calendar**
• Cycle, mood, symptoms, libido and energy — logged in under 10 seconds
• Smart marking: log day one and Intima fills in the rest
• Next-cycle and fertile-window predictions tuned to your cycle length
• Intimate moments — as many as there were, with every detail you want to remember

📔 **Personal diary**
• Free writing, journaling templates and prompts, moods
• Photos in a protected space — never in your shared gallery
• Tags and search; "A memory from a while ago" brings back the good days

⏰ **Gentle reminders**
• An evening nudge at the time you choose
• A discreet heads-up before your expected period and on ovulation day

🗑️ **Your data, your rules**
• Export an encrypted archive anytime
• Delete everything with one tap — no trace left

No subscription for the essentials. Your data is not for sale.

## ASO ключови думи

**BG:** интимен календар, менструален календар, цикъл, овулация, дневник,
личен дневник, период тракер, чат за двойки, дневник за двойки, близост,
женско здраве, дискретен дневник

**EN:** period tracker, cycle tracker, intimacy diary, couples chat,
couples journal, ovulation calendar, fertility window, partner chat,
intimacy app, discreet, women's health

## Категория и класификация

- **Категория:** Health & Fitness (алтернатива: Lifestyle)
- **Възрастова класификация (IARC):** очаквано Mature 17+ или Teen —
  попълва се честно във въпросника (теми: сексуално съдържание от
  потребителя, здравна тематика). Без графично съдържание в самото
  приложение → обикновено минава без проблем.

## Data Safety формуляр (черновите отговори)

> ⚠️ Промяна (2026-06-12): след добавянето на чата за двойки приложението
> ВЕЧЕ събира данни (само за тази функция). Отговорите по-долу го отразяват.

| Въпрос | Отговор |
|---|---|
| Събира ли приложението данни? | **Да** — за Partner Mode, снимките и видеата от дневника и optional account функции |
| Какви данни | Съобщения, снимки и видео, споделени с партньор; **снимки и видеа от дневника (лично копие на сървъра, видимо само за потребителя и за модерацията)**; Couple Match pose-interest записи; анонимен account identifier; pairing/couple identifiers; technical metadata. При optional Google/Facebook вход: provider id, имейл/display name/profile photo metadata според доставчика. Останалите данни от дневника, календарът и цикълът остават само на устройството. |
| Цел | Функционалност на приложението: сдвояване, чат, media delivery, Couple Match, account/auth |
| Споделя ли данни с трети страни? | Не за реклама/продажба; ползва се Supabase като backend/storage/auth processor. При optional вход участват Google/Facebook като auth providers. |
| Данните криптирани ли са при пренос? | **Да** (TLS) |
| End-to-end криптиране? | **Не** за Partner Mode — съдържанието може да бъде достъпно за сигурност, злоупотреби, troubleshooting и законови задължения |
| Може ли потребителят да поиска изтриване? | Да — „Изтрий всичко" трие локалните данни и иска изтриване на сървърните копия на снимките и видеата от дневника; премахването на снимка/видео/запис също трие сървърното копие; „Прекъсни връзката" премахва активната partner връзка и chat records от active backend DB. За пълно server-side/account deletion: contact email в privacy policy. |
| Health policy декларация | Цикъл/здравни данни се обработват **само локално**; приложението не е медицинско изделие; privacy policy URL задължителен |

## Какво остава да се подготви

- [ ] Скрийншоти за листинга (мин. 2, преп. 4–8; 16:9 или 9:16) — ще ги
      направим от емулатора с demo данни (FLAG_SECURE временно изключен)
- [ ] Feature graphic 1024×500 (мога да я генерирам като иконата)
- [ ] Хостнат privacy policy URL (виж PRIVACY_POLICY.md)
- [ ] Подписващ ключ за release билда (keystore) + `flutter build appbundle`
