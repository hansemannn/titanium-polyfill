# Titanium Polyfill

Various native utilities to fill some gaps in Titanium:

## APIs

### Android

- [x] `formattedCurrency({ value: 10, currency: 'USD' })` -> `$10`
- [x] `timezoneId()` -> `Europe/Berlin`
- [x] `showAlert({ title, message, buttonNames, callback })` -> Shows an alert dialog with properly arranged buttons
- [x] `installSource()` -> Returns the install source of the app, e.g. `play_store` or `amazon`
- [x] `showNotification({ title, duration })` -> Shows a snackbar instead of toast
- [x] `relativeDateString(new Date(2022, 0, 1))` ->  Returns the relative date compared to now (e.g. "just now" or "3 minutes ago")
- [x] `enablePiracyChecker()` -> Detects rooted devices
- [x] `isAppInstalled('com.facebook.app')` -> Whether or not a given app is installed (by package ID)
- [x] `getMediaStoreURL(url)` -> Returns the internal `MediaStore` URL from a given URL 

### iOS

- [x] `openFullscreenVideoPlayer({ url })` -> Shows a video fullscreen
- [x] `isDarkImage()` -> Boolean, indicating whether or not an image is primarily dark
- [x] `formattedDateRange(date1, date2)` -> Returns the formatted date range by two given dates
- [x] `relativeDateString(new Date(2022, 0, 1))` ->  Returns the relative date compared to now (e.g. "just now" or "3 minutes ago")
- [x] `isAppInstalled('com.facebook.app')` -> Whether or not a given app is installed (by package ID)

## License

MIT

## Author

Hans Knöchel
