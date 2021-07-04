# Titanium Polyfill

Various native utilities to fill some gaps in Titanium:

- [x] `formattedCurrency({ value: 10, currency: 'USD' })` -> `$10`
- [x] `timezoneId()` -> `Europe/Berlin`
- [x] `showAlert({ title, message })` -> Shows an alert dialog with properly arranged buttons
- [x] `installSource()` -> Returns the install source of the app, e.g. `play_store` or `amazon`
- [x] `showNotification({ title })` -> Shows a snackbar instead of toast
- [x] `downloadLanguage('de')` -> Downloads a language via Play Services (if not available) - used when distributing apps via .aab

## License

MIT

## Author

Hans Knöchel
