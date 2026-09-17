# Print Label Layout Fixes

**Date:** 2026-09-10

---

## 1. `សេវាដឹក` wrapping caused `សេវា` to appear twice on the label

**File:** `lib/src/widgets/print_template_card.dart`

The shipping section label `'សេវាដឹក'` was wrapping onto two lines because it did not have enough horizontal space. The price text was taking its natural width first, leaving the label with only the leftover space. Since Khmer breaks at syllable boundaries, `'សេវា'` appeared on one line and `'ដឹក'` on the next. The chip `'សេវាខាងភ្ញៀវ'` sitting directly below made `'សេវា'` appear twice on the printed label.

**Fix:** Gave the label its natural width so it always renders on one line, and moved the flexible space to the price text (right-aligned) instead.

---

## 2. No visible gap between the shipping section and the chips row (macOS native)

**File:** `macos/Runner/AppDelegate.swift`

In the macOS native print renderer, the chips row was placed only 3pt below the shipping section box. On a 58mm thermal label that gap is practically invisible. The Flutter card path was fine — it already had adequate spacing through `SizedBox` and container padding.

**Fix:** Increased the gap between the shipping section bottom and the chips row top from 3pt to 9pt.

---

## 3. No visible gap between the chips row and the thank-you footer (macOS native)

**File:** `macos/Runner/AppDelegate.swift`

Same issue as above. After the chips row, only 3pt of space was given before the `'សូមអរគុណសម្រាប់ការគាំទ្រ'` footer text. The Flutter card already handled this correctly with a `SizedBox`.

**Fix:** Increased the gap between the chips row bottom and the footer text top from 3pt to 9pt.
