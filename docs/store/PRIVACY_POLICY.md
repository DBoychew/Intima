# Intima — Privacy Policy / Политика за поверителност

_Last updated / Последна актуализация: 2026-06-12_

> Този документ е двуезичен: български отгоре, English below.
> Преди публикуване: попълни **[КОНТАКТЕН ИМЕЙЛ]** и **[ИМЕ/ФИРМА НА РАЗРАБОТЧИКА]**
> и хоствай страницата на публичен URL (напр. GitHub Pages).

---

## 🇧🇬 Политика за поверителност

Intima е приложение за интимен календар и дневник. Този документ обяснява
честно какви данни остават на устройството ти и какви се изпращат на
нашите сървъри, когато ползваш функциите за партньор.

### Какво остава само на устройството ти

Твоят **дневник, календар, цикъл, настроения, симптоми, интимни моменти
и прикачените към тях снимки/видеа/аудио** се съхраняват **само локално**:

- Базата данни е криптирана с AES-256 (SQLCipher-съвместим формат).
- Ключът се пази в защитеното хранилище на устройството (Android Keystore).
- PIN кодът се съхранява само като необратим хеш.
- Това съдържание **не се изпраща никъде** и ние нямаме достъп до него.

### Какво се изпраща на нашите сървъри (функция „Партньор")

Когато се свържеш с партньор и използваш чата, **съобщенията, снимките
и видеата, които споделяш с него, се качват на нашите сървъри**
(Supabase, хостинг в ЕС), за да достигнат до устройството на партньора.

- Това съдържание **не е криптирано от край до край** и се пази на
  сървъра, докато ти или партньорът прекъснете връзката.
- Криптирано е при пренос (TLS) и при съхранение от хостинг доставчика.
- **Може да бъде преглеждано от нас** с цел сигурност, предотвратяване
  на злоупотреби и спазване на закона.
- За тази функция се създава **анонимен акаунт** — без имейл, без
  телефон, без име.
- Когато прекъснеш връзката с партньор („Прекъсни връзката"),
  споделеното с него съдържание се изтрива от сървъра.

Ако не използваш функцията „Партньор", нищо не напуска устройството ти.

### Разрешения, които приложението иска

| Разрешение | Защо |
|---|---|
| Биометрия | Отключване с пръстов отпечатък/лице — по избор |
| Нотификации | Нежни локални напомняния — по избор, без съдържание |
| Галерия / Камера | Само когато избереш да прикачиш снимка/видео |
| Микрофон | Само когато записваш аудио бележка |
| Интернет | Само за функцията „Партньор" (синхронизация на чата) |

### Трети страни

За функцията „Партньор" ползваме **Supabase** (бекенд и съхранение) с
хостинг в ЕС. Не продаваме данни и не използваме рекламни мрежи или
аналитика на трети страни.

### Твоите права (GDPR)

- **Достъп и преносимост:** експортирай криптиран архив на локалните си
  данни по всяко време (Настройки → Експортирай данните).
- **Изтриване:** „Изтрий всичко" премахва локалните данни от
  устройството; „Прекъсни връзката" изтрива споделеното с партньор
  съдържание от сървъра. За пълно изтриване на сървърни данни се свържи
  с нас на имейла по-долу.

### Деца

Приложението е предназначено за лица на 18 и повече години.

### Промени по тази политика

При промяна ще актуализираме датата най-горе.

### Контакт

**[ИМЕ/ФИРМА НА РАЗРАБОТЧИКА]** · **[КОНТАКТЕН ИМЕЙЛ]**

---

## 🇬🇧 Privacy Policy

Intima is an intimacy calendar and diary app. This document honestly
explains which data stays on your device and which data is sent to our
servers when you use the partner features.

### What stays on your device only

Your **diary, calendar, cycle, moods, symptoms, intimate moments and
the photos/videos/audio attached to them** are stored **locally only**:

- The database is encrypted with AES-256 (SQLCipher-compatible).
- The key lives in your device's secure storage (Android Keystore).
- Your PIN is stored only as an irreversible hash.
- This content **is never sent anywhere** and we cannot access it.

### What is sent to our servers (the "Partner" feature)

When you link with a partner and use the chat, **the messages, photos
and videos you share with them are uploaded to our servers** (Supabase,
EU hosting) so they can reach your partner's device.

- This content is **not end-to-end encrypted** and is stored on the
  server until you or your partner unlink.
- It is encrypted in transit (TLS) and at rest by the hosting provider.
- It **may be reviewed by us** for safety, abuse prevention and legal
  compliance.
- An **anonymous account** is created for this feature — no email, no
  phone number, no name.
- When you unlink from a partner, the content shared with them is
  deleted from the server.

If you don't use the "Partner" feature, nothing leaves your device.

### Permissions the app requests

| Permission | Why |
|---|---|
| Biometrics | Optional fingerprint/face unlock |
| Notifications | Optional gentle local reminders that never reveal content |
| Gallery / Camera | Only when you choose to attach a photo/video |
| Microphone | Only when you record an audio note |
| Internet | Only for the "Partner" feature (chat sync) |

### Third parties

The "Partner" feature uses **Supabase** (backend and storage) hosted in
the EU. We don't sell data and use no third-party ad networks or
analytics.

### Your rights (GDPR)

- **Access & portability:** export an encrypted archive of your local
  data anytime (Settings → Export your data).
- **Erasure:** "Delete everything" removes local data from the device;
  "Unlink" deletes the content shared with a partner from the server.
  For full erasure of server data, contact us at the email below.

### Children

The app is intended for users aged 18 and over.

### Changes to this policy

We will update the date above when this text changes.

### Contact

**[DEVELOPER NAME/COMPANY]** · **[CONTACT EMAIL]**
