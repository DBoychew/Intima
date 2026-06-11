# 🛍️ Google Play — материали за листинга (чернова за преглед)

> Лимити на Google Play: заглавие ≤ 30 знака, кратко описание ≤ 80 знака,
> пълно описание ≤ 4000 знака. Тонът е wellness — без explicit съдържание
> (изискване на store политиките и на PLAN.md Фаза 8 бележката).

## Заглавие (избери едно)

| Вариант | Знаци |
|---|---|
| **Intima — интимен календар** (BG) / **Intima — Private Cycle Diary** (EN) | 26 / 28 |
| Intima: цикъл и дневник (BG) / Intima: Cycle & Diary (EN) | 23 / 21 |

## Кратко описание (≤ 80 знака)

**BG:** Интимен календар и дневник — криптиран, без акаунт, само на твоя телефон.
**EN:** Private cycle calendar & diary — encrypted, no account, on your phone only.

## Пълно описание

### BG

**Твоят интимен живот. Само твой.**

Intima е дискретен календар и дневник за цикъла, настроението и близостта — създаден с едно желязно правило: всичко остава на телефона ти.

🔒 **Истинска поверителност**
• Без акаунт, без облак, без реклами
• Всички данни са криптирани на устройството (AES-256)
• PIN и биометрично заключване
• Скрито съдържание в скорошни приложения и блокирани скрийншоти
• Нотификациите никога не издават съдържанието

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

Без абонамент за основните функции. Без продажба на данни — никога.

### EN

**Your intimate life. Yours alone.**

Intima is a discreet cycle, mood and intimacy companion built on one iron rule: everything stays on your phone.

🔒 **Real privacy**
• No account, no cloud, no ads
• All data encrypted on your device (AES-256)
• PIN and biometric lock
• Hidden in recent apps, screenshots blocked
• Notifications never reveal the content

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

No subscription for the essentials. Your data is never for sale.

## ASO ключови думи

**BG:** интимен календар, менструален календар, цикъл, овулация, дневник,
личен дневник, период тракер, фертилни дни, поверителност, криптиран дневник,
дневник за двойки, женско здраве

**EN:** period tracker, cycle tracker, intimacy diary, private journal,
encrypted diary, ovulation calendar, fertility window, couples journal,
offline period tracker, no account, discreet, women's health

## Категория и класификация

- **Категория:** Health & Fitness (алтернатива: Lifestyle)
- **Възрастова класификация (IARC):** очаквано Mature 17+ или Teen —
  попълва се честно във въпросника (теми: сексуално съдържание от
  потребителя, здравна тематика). Без графично съдържание в самото
  приложение → обикновено минава без проблем.

## Data Safety формуляр (черновите отговори)

| Въпрос | Отговор |
|---|---|
| Събира ли приложението данни? | **Не** — нищо не напуска устройството |
| Споделя ли данни с трети страни? | **Не** |
| Данните криптирани ли са при пренос? | Няма пренос (offline) |
| Може ли потребителят да поиска изтриване? | Да — пълно изтриване в приложението |
| Health policy декларация | Приложението обработва цикъл/здравни данни **само локално**; не се изискват акаунти; privacy policy URL задължителен |

## Какво остава да се подготви

- [ ] Скрийншоти за листинга (мин. 2, преп. 4–8; 16:9 или 9:16) — ще ги
      направим от емулатора с demo данни (FLAG_SECURE временно изключен)
- [ ] Feature graphic 1024×500 (мога да я генерирам като иконата)
- [ ] Хостнат privacy policy URL (виж PRIVACY_POLICY.md)
- [ ] Подписващ ключ за release билда (keystore) + `flutter build appbundle`
