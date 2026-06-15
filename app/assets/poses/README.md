# Илюстрации за позите (CC0 SVG)

Сложи тук по един **SVG файл на поза**, кръстен точно с **id-то на позата**:
`<pose-id>.svg` (напр. `spooning.svg`, `on_top.svg`).

- Ако файл за дадена поза има → приложението го показва (бяло, върху
  брандирания градиент).
- Ако липсва → ползва се генерираният вектор арт (fallback). Нищо не гърми.

## id-та на позите (имена на файловете)

starter: `spooning`, `face_to_face`, `seated_embrace`, `on_top`,
`reclining`, `kneeling`, `back_to_chest`, `legs_entwined`

romance: `candlelight`, `slow_dance`, `morning_light`, `bath`, `sunset`,
`fireplace`, `window`

adventure: `standing`, `new_room`, `mirror`, `chair`, `sofa`, `edge_of_bed`

## Откъде CC0 (без авторски права, без атрибуция)

- **SVG Repo** → филтър по лиценз **CC0**: https://www.svgrepo.com/  (в браузър работи; ботът ни е блокиран от Cloudflare)
- Изтегляш SVG, преименуваш на `<pose-id>.svg`, слагаш тук.

⚠️ **Google Play**: явни изображения на сексуални пози (дори икони) може
да нарушат политиката за сексуално съдържание. По-безопасни са дискретни,
неексплицитни силуети/линии. Изборът на съдържание е твой.

След като добавиш файлове: `flutter pub get` (ако е нов път) и пребилд.
