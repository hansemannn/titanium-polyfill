# Titanium Polyfill

Various native utilities to fill some gaps in Titanium:

## APIs

### Android

#### General APIs

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

#### General APIs

- [x] `openFullscreenVideoPlayer({ url })` -> Shows a video fullscreen
- [x] `isDarkImage()` -> Boolean, indicating whether or not an image is primarily dark
- [x] `formattedDateRange(date1, date2)` -> Returns the formatted date range by two given dates
- [x] `relativeDateString(new Date(2022, 0, 1))` ->  Returns the relative date compared to now (e.g. "just now" or "3 minutes ago")
- [x] `isAppInstalled('com.facebook.app')` -> Whether or not a given app is installed (by package ID)
- [x] `convertTiffToPDF('appdata://path/to/file.tiff', 'converted-document')` -> Converts a multi-page TIFF into a PDF written to the temporary directory and returns the generated file URL

#### Action Button (iOS)

The module ships an animated, haptics-enabled action button view that you can drop into any Titanium layout:

```js
const actionButton = TiPolyfill.createActionButton({
  title: 'Continue',
  buttonBackgroundColor: '#007aff',
  buttonTextColor: '#ffffff',
  font: { fontSize: 16, fontWeight: 'semibold' },
  padding: { left: 18, right: 18 },
  borderRadius: 14
});

actionButton.addEventListener('click', () => {
  // Handle primary button tap
});
```

### Configuration

- `title` – label shown on the button
- `buttonBackgroundColor` / `buttonTextColor` – Titanium color values used for the background and label
- `font` – standard Titanium font dictionary applied to the label
- `borderRadius`, `borderColor`, `borderWidth` – customize the button outline
- `padding` – either a single number (uniform left/right padding) or `{ left, right }` for per-side control; defaults to `10`
- `menu` (iOS 14+) – array of menu actions, e.g. `[{ title: 'Edit' }, { title: 'Delete', destructive: true }]`; fires a `menuclick` event with the selected index

The view emits a `click` event when the primary button is pressed and provides subtle scale + selection feedback so it feels native without extra work.

## License

MIT

## Author

Hans Knöchel
