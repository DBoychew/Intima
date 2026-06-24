# 🚀 Release чеклист — какво остава до Google Play

> Работен списък за публикуването (Фаза 5). Подробните текстове са в
> `docs/store/PLAY_STORE_LISTING.md` и `docs/store/PRIVACY_POLICY.md`.

## Решения от Димитър (за по-късно)

- [ ] **Заглавие в Play** — избор между:
  - „Intima — интимен календар" / "Intima — Private Cycle Diary" (препоръка)
  - „Intima: цикъл и дневник" / "Intima: Cycle & Diary"
- [ ] **Преглед на описанията** (BG/EN) в `docs/store/PLAY_STORE_LISTING.md`
- [ ] **Контактен имейл за потребители** — задължителен за Play Console;
      препоръка: отделен имейл (напр. нов Gmail), не служебният
- [x] **Име/фирма на разработчика** за privacy policy — Dimitar Boychev
- [x] **Контактен имейл в privacy policy** — dimitur.boychew@abv.bg
- [ ] **Хостинг на privacy policy** — `docs/privacy-policy.html` се качва
      на GitHub Pages (безплатен публичен URL) и URL-ът се попълва в Play
      Console
- [ ] **Google Play акаунт** — чака верификация на самоличността ✋

## Техническа подготовка (Claude)

- [ ] Release keystore + подписан App Bundle (`flutter build appbundle`)
- [ ] Feature graphic 1024×500 (в стила на иконата)
- [ ] Скрийншоти за листинга (4–8, с demo данни; FLAG_SECURE временно
      изключен за снимките) — заедно с Димитър
- [ ] Финален тест на реално Android устройство (биометрия, нотификации)
- [ ] Data Safety формуляр в Play Console (отговорите са готови в листинга)
- [ ] IARC въпросник за възрастова класификация

## Бележки

- Само Android за MVP — iOS се отлага (изисква Apple акаунт $99/г + Mac).
- Keystore файлът и паролите НЕ влизат в git — пазят се локално +
  задължителен бекъп (загубен keystore = невъзможни ъпдейти).
