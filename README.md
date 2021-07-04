# Titanium Polyfill

Various native utilities to fill some gaps in Titanium:

- [x] `formattedCurrency({ value: 10, currency: 'USD' })` -> `$10`
- [x] `timezoneId` -> `Europe/Berlin`
- [x] `showNotification({ title: 'Test' })` -> Shows a snackbar instead of toast
- [x] `downloadLanguage('de')` -> Downloads a language via Play Services (if not available) - used when distributing apps via .aab

## License

MIT

## Author

Hans Knöchel
