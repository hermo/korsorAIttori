# korsorAIttori

AI-pohjainen korsoraattori – väännä mikä tahansa teksti, uutinen, web-sivu, PDF, tekno-uutinen tai email kunnon suominuorison slangiksi. Todellinen OG, powered by OpenRouter ja Claude!

## Korsoraattori?

Aito ja alkuperäinen [Korsoraattori](https://korsoraattori.evvk.com/) muutti nettisivuja nuorison ymmärtämään muotoon 2000-luvun alussa.

## Asennus

1. Lataa [korsorai.sh](./korsorai.sh)–skripti ja anna sille suoritusoikeudet:
   ```
   chmod +x korsorai.sh
   sudo mv korsorai.sh /usr/local/bin/
   ```

2. Lisää API-avain ympäristöön:
   ```
   export OPENROUTER_API_KEY="sk-or-v1-..."
   ```

## Käyttö

```
korsorai.sh [OPTIOT] [TEKSTI]
```

### Esimerkit

- Pelkkää klassista kiroilua:
  ```
  korsorai.sh -s classic "Hei, haluaisin tavata sinut huomenna kahville"
  ```

- Gen Z -slangilla:
  ```
  korsorai.sh -s modern "Toi tapaaminen oli hyvä"
  ```

- Äärettömän korsomainen:
  ```
  korsorai.sh -s extreme -i 10 "Tän pitää onnistua!"
  ```

- Listaa tyylit ja esimerkit:
  ```
  korsorai.sh -l
  ```

## Vivut ja ominaisuudet

- `-s, --style`    Valitse tyyli (classic|modern|mixed|extreme|subtle)
- `-i, --intensity` Kuinka paljon slangia/kiroilua (1-10)
- `-m, --model`    OpenRouter-mallin nimi, oletuksena Claude 4.5 Sonnet
- `-l, --list-styles` Näytä tyylit ja esimerkit
- `-h, --help`     Näytä apu

## Hauskoja hetkiä korsoroinnissa – vittu saatana, nyt slangi lentää!
