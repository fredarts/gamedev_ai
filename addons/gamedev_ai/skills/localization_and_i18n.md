# Godot 4.x Localization and i18n Guide

This skill defines the standard workflow for implementing Internationalization (i18n) and Localization in Godot 4.

## 1. The Core Principle
Never hardcode user-facing text strings in your UI or scripts. Always use **Translation Keys** (e.g., `UI_BUTTON_START`, `DIALOGUE_KING_GREETING`). Godot's `TranslationServer` will automatically swap the key for the correct language string at runtime.

## 2. Setting Up Translations (CSV Method)
The most common and developer-friendly way to handle translations in Godot 4 is using a `.csv` file.

1. Create a spreadsheet (Excel, Google Sheets) with the following structure:
   - **Column A**: `keys`
   - **Column B**: `en` (English)
   - **Column C**: `pt_BR` (Portuguese - Brazil)
   - **Column D**: `es` (Spanish)

| keys | en | pt_BR | es |
| :--- | :--- | :--- | :--- |
| UI_PLAY | Play | Jogar | Jugar |
| UI_QUIT | Quit | Sair | Salir |

2. Export as a UTF-8 CSV file (e.g., `translations.csv`).
3. Place `translations.csv` in your Godot project (e.g., `res://translations/`).
4. Godot will automatically import it and generate `.translation` files for each language (e.g., `translations.en.translation`).
5. Go to **Project -> Project Settings -> Localization -> Translations** and add these generated `.translation` files.

## 3. Using Translations in the Engine

### In the UI (Automatic)
For any `Label`, `Button`, or Control node that displays text, simply type the Translation Key into its `text` property in the Inspector.
- Set a Button's text to `UI_PLAY`.
- At runtime, Godot automatically translates it to "Jogar" if the OS language is Portuguese.

### In Scripts (Dynamic)
If you need to construct strings in code, use the global `tr()` function.
```gdscript
func _ready():
    # Translates the key based on the current locale
    var greeting = tr("DIALOGUE_KING_GREETING")
    
    # If using formatted text with placeholders (e.g., "Hello %s"):
    var player_name = "Fred"
    var formatted_greeting = tr("DIALOGUE_HELLO_PLAYER") % player_name
    print(formatted_greeting)
```

## 4. Changing the Language at Runtime
Players usually want an options menu to change the language manually. You can hook up a dropdown menu to the `TranslationServer`:

```gdscript
# LanguageSettings.gd
func set_game_language(locale_code: String) -> void:
    # locale_code should be "en", "pt_BR", "es", etc.
    TranslationServer.set_locale(locale_code)
```

## 5. Localizing Assets (Images/Audio)
Sometimes a texture has words on it (like a "STOP" sign).
1. Go to **Project -> Project Settings -> Localization -> Remaps**.
2. Add the English `stop_sign.png` as the original resource.
3. Add `stop_sign_pt_BR.png` as a remap for the `pt_BR` locale.
4. When you `preload("res://stop_sign.png")`, Godot will automatically load the localized remap!
