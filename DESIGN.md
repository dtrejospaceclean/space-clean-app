---
name: Space Clean
description: Operations app for commercial cleaning companies; a clean white door in carried by the full-color logo, and the work inside stays quiet.
colors:
  brand-orange: "#C2410C"
  ember: "#431407"
  logo-navy: "#0A4781"
  accent-orange: "#F97316"
  logo-orange: "#F45302"
  danger-red: "#B91C1C"
  white: "#FFFFFF"
  stone-ink: "#1C1917"
  stone-muted: "#57534E"
  stone-hint: "#6B5E57"
  stone-outline: "#78716C"
  stone-track: "#E7E5E4"
  notice-error-tint: "#FEF2F2"
  notice-info-tint: "#EFF6FF"
  apricot-muted: "#FED7AA"
  ember-field: "#5A1F0B"
  ember-field-hint: "#E9B99A"
  kiln-border: "#EA580C"
  cream-notice: "#FFF7ED"
typography:
  headline:
    fontFamily: "Roboto (Android), San Francisco (iOS)"
    fontSize: "28sp"
    fontWeight: 700
    lineHeight: 1.29
    letterSpacing: "-0.5"
  intro:
    fontFamily: "Roboto (Android), San Francisco (iOS)"
    fontSize: "17sp"
    fontWeight: 400
    lineHeight: 1.45
  title:
    fontFamily: "Roboto (Android), San Francisco (iOS)"
    fontSize: "16sp"
    fontWeight: 600
    lineHeight: 1.5
  tagline:
    fontFamily: "Roboto (Android), San Francisco (iOS)"
    fontSize: "16sp"
    fontWeight: 500
    lineHeight: 1.35
  action:
    fontFamily: "Roboto (Android), San Francisco (iOS)"
    fontSize: "18sp"
    fontWeight: 600
  input:
    fontFamily: "Roboto (Android), San Francisco (iOS)"
    fontSize: "18sp"
    fontWeight: 400
  body:
    fontFamily: "Roboto (Android), San Francisco (iOS)"
    fontSize: "16sp"
    fontWeight: 500
    lineHeight: 1.35
  error:
    fontFamily: "Roboto (Android), San Francisco (iOS)"
    fontSize: "15sp"
    fontWeight: 700
    lineHeight: 1.35
  label:
    fontFamily: "Roboto (Android), San Francisco (iOS)"
    fontSize: "15sp"
    fontWeight: 700
    letterSpacing: "0.5"
  code-digit:
    fontFamily: "Roboto (Android), San Francisco (iOS)"
    fontSize: "30sp"
    fontWeight: 700
    fontFeature: "tnum"
rounded:
  box: "12dp"
  panel: "14dp"
spacing:
  xs: "8dp"
  sm: "12dp"
  md: "16dp"
  lg: "24dp"
  xl: "28dp"
  xxl: "32dp"
  tablet-gap: "48dp"
components:
  button-primary:
    backgroundColor: "{colors.logo-navy}"
    textColor: "{colors.white}"
    typography: "{typography.action}"
    rounded: "{rounded.panel}"
    height: "60dp"
    width: "100%"
  button-primary-dark:
    backgroundColor: "{colors.accent-orange}"
    textColor: "{colors.ember}"
    typography: "{typography.action}"
    rounded: "{rounded.panel}"
    height: "60dp"
    width: "100%"
  button-link:
    textColor: "{colors.brand-orange}"
    typography: "{typography.title}"
    padding: "0 12dp"
    height: "48dp"
  button-link-dark:
    textColor: "{colors.white}"
    typography: "{typography.title}"
    padding: "0 12dp"
    height: "48dp"
  text-field:
    backgroundColor: "{colors.white}"
    textColor: "{colors.stone-ink}"
    typography: "{typography.input}"
    rounded: "{rounded.panel}"
    padding: "21dp 18dp"
    height: "64dp"
  text-field-dark:
    backgroundColor: "{colors.ember-field}"
    textColor: "{colors.white}"
    typography: "{typography.input}"
    rounded: "{rounded.panel}"
    padding: "21dp 18dp"
    height: "64dp"
  notice-error:
    backgroundColor: "{colors.notice-error-tint}"
    textColor: "{colors.stone-ink}"
    typography: "{typography.body}"
    rounded: "{rounded.panel}"
    padding: "16dp"
  notice-info:
    backgroundColor: "{colors.notice-info-tint}"
    textColor: "{colors.stone-ink}"
    typography: "{typography.body}"
    rounded: "{rounded.panel}"
    padding: "16dp"
  notice-dark:
    backgroundColor: "{colors.cream-notice}"
    textColor: "{colors.stone-ink}"
    typography: "{typography.body}"
    rounded: "{rounded.panel}"
    padding: "16dp"
  code-box:
    backgroundColor: "{colors.white}"
    textColor: "{colors.stone-ink}"
    typography: "{typography.code-digit}"
    rounded: "{rounded.box}"
    height: "68dp"
  language-switch-selected:
    backgroundColor: "{colors.stone-ink}"
    textColor: "{colors.white}"
    typography: "{typography.label}"
    height: "48dp"
  language-switch-unselected:
    textColor: "{colors.stone-ink}"
    typography: "{typography.label}"
    height: "48dp"
  language-switch-selected-dark:
    backgroundColor: "{colors.white}"
    textColor: "{colors.ember}"
    typography: "{typography.label}"
    height: "48dp"
  language-switch-unselected-dark:
    textColor: "{colors.white}"
    typography: "{typography.label}"
    height: "48dp"
---

# Design System: Space Clean

## Overview

**Creative North Star: "The Brand Threshold"**

Space Clean has two registers. The **threshold** is everything before sign-in (native launch, splash, sign-in, the three password-reset steps). In light mode it is a clean white door: a full-bleed white ground, the full-color planet mark and wordmark in the upper free space, and an oversized, plain form low in the thumb zone. The brand is carried by the logo, one logo-navy action, and brand-orange text links. The form sits directly on the ground with no card. Fields are white with a stone outline, not gray fills. In dark mode the threshold keeps its ember ground with the white knockout logo and a bright-orange action.

The **interior** is the working app after sign-in: restrained neutral surfaces with the brand orange as the only accent, built from a Material scheme seeded on the brand orange. This register is the intended rule but is **not yet exercised**. Only a placeholder home screen exists, so treat interior guidance as provisional until real screens are built.

Both registers speak each OS's native language: Material components on Android, Cupertino on iOS, platform system fonts, platform icons. The brand comes from the logo, the colors of spacecleanllc.com, and the proportions of the threshold, not from custom chrome. Accessibility is part of the look: big targets, rows that grow with text size, errors that never depend on color alone.

**Key Characteristics:**
- White threshold with the full-color logo in light mode; ember with the white logo in dark mode; quiet neutrals after sign-in.
- One primary action per screen, full width, 60 dp, logo navy, in the thumb zone on phones.
- Outlined white fields on white; brand orange appears only as underlined text links.
- Red errors on white (never red on ember, never orange on orange in dark mode), tinted notice panels.
- Native controls per OS (Material / Cupertino), system type.
- Flat: no shadows anywhere; depth comes from outlines and fill contrast.

**Theme mode (current):** the app is light-only (`themeMode: ThemeMode.light`); the user wants a white background even when the phone is in dark mode. The dark (ember) values below are kept for when dark mode is re-enabled, and the native launch screen is white in both system modes.

## Colors

A white ground with logo navy for action, brand orange for links, and stone neutrals for text and outlines; dark mode swaps to an ember ground with bright orange for action.

### Primary
- **Brand Orange** (brand-orange): the website's button fill. On the light threshold it is the text-link color ("Forgot password?", "Not you?"), 5.2:1 on white. It seeds the interior Material scheme and is the interior primary in light mode. It is not a threshold fill in light mode.
- **Ember** (ember): the threshold ground in dark mode, the dark native launch color, and the label color on the bright-orange dark-mode action.

### Secondary
- **Logo Navy** (logo-navy): the logo wordmark's color. On the threshold it fills the light-mode primary action (white label 9.4:1), marks the focused field (3 dp border and cursor, 9.4:1 on white), and colors the info-notice icon (8.7:1 on its tint).
- **Site Accent Orange** (accent-orange): the website's accent. In dark mode it is the threshold action fill (ember label 5.6:1) and the field focus color (4.6:1 on the ember field). It is also the interior primary in dark mode.

### Tertiary
- **Logo Orange** (logo-orange): the planet mark in the logo only. It is not used as a UI color.
- **Danger Red** (danger-red): light-mode field and code-box error text (bold, 6.5:1 on white) and error borders (3 dp), and the error icon in notice panels (5.9:1 on the error tint, 6.1:1 on cream).

### Neutral
- **White** (white): the light threshold ground, light fields and code boxes, the native launch in light mode, the primary-action label, and in dark mode text on ember, the white knockout logo, and dark field errors.
- **Stone Ink** (stone-ink): headlines, labels, and body text on white (17.5:1), typed text in fields, and all notice text. It is also the light-mode language-switch selection fill.
- **Stone Muted** (stone-muted): secondary text on white (tagline, intros, unmet password rules, disabled links), 7.6:1.
- **Stone Hint** (stone-hint): placeholder text and suffix icons in white fields (6.2:1).
- **Stone Outline** (stone-outline): the 1.5 dp resting outline of light fields and code boxes, 4.8:1 on white, so outlines survive bright light.
- **Stone Track** (stone-track): the iOS language-switch track in light mode; unselected labels on it read 13.9:1.
- **Notice Error Tint** (notice-error-tint) and **Notice Info Tint** (notice-info-tint): light-mode notice panel fills. They sit only 1.09:1 off the white ground; the icon and the text identify the panel, not its edge.
- **Apricot Muted** (apricot-muted): secondary text on ember (11.6:1).
- **Ember Field** (ember-field): dark-mode field fill; **Ember Field Hint** (ember-field-hint) is its placeholder (7.3:1).
- **Kiln Border** (kiln-border): the resting border of dark-mode fields, 4.4:1 against ember and 3.6:1 against the field fill, so empty fields still read as fields.
- **Cream Notice** (cream-notice): notice panel fill in dark mode, for both errors and information.

### Named Rules
**The Orange Link Rule.** On the white threshold, brand orange appears as underlined text links and inside the logo, nowhere else. It is never a fill, a border, or an error color there.

**The No Orange-on-Orange Rule.** In dark mode nothing that signals trouble is orange or red on the ember ground. Field errors are bold white text below the field. Form-level errors and information use cream panels with a red or navy icon.

**The Two Registers Rule.** The threshold owns the full-screen identity (white with the full-color logo, or ember with the white logo). Interior screens use neutral surfaces with orange as the single accent (brand orange in light mode, site accent orange in dark mode). Do not drench interior screens in orange or ember.

**The Logo Colors Rule.** Navy and orange come from the logo and the website. Do not invent new brand hues. Logo orange stays inside the logo.

## Typography

**Display Font:** none yet. The brand has no display face. The website uses a system/Inter stack, and choosing a brand display face is an open decision.
**Body Font:** platform system font: Roboto on Android, San Francisco on iOS.

**Character:** Native, heavy, and large. Hierarchy comes from weight (500/600/700) and size, never from a decorative face. Sizes are in sp and scale with the OS text setting.

### Hierarchy
- **Headline** (700, 28sp, -0.5 tracking): screen titles on the threshold ("Sign in", "Enter the code"), in stone ink (white on ember), marked as a semantic header.
- **Intro** (400, 17sp, 1.45 line height): the one-paragraph explanation under a task-screen headline, in the muted text color.
- **Title** (600, 16sp): field labels, on a row with a minimum height of 48 dp.
- **Tagline** (500, 16sp, 1.35): the real brand tagline under the logo, muted color, centered.
- **Action** (600, 18sp): primary button labels.
- **Input** (400, 18sp): typed text and placeholders in fields.
- **Body** (500, 16sp, 1.35): notice text and password rule rows (met rules at 700).
- **Error** (700, 15sp, 1.35): field errors, danger red in light mode and white in dark mode, up to three lines.
- **Label** (700, 15sp, 0.5 tracking): the EN/ES language switch segments.
- **Code Digit** (700, 30sp, tabular figures): one-time-code boxes.

### Named Rules
**The Native Type Rule.** Use the platform system font (Roboto or San Francisco) for all UI text until a brand display face is chosen. Never bundle a substitute to fake one.

**The Scale-Don't-Clip Rule.** Text grows with the OS setting. Rows that hold text get minimum heights, never fixed heights.

## Layout

The threshold is a single column with a maximum width of 480 dp, 24 dp side padding and 24 dp bottom padding, inside the safe area. It scrolls when the keyboard or large text leaves too little room. The system status bar is transparent with dark icons on white (light icons on ember), and the navigation bar takes the ground color.

- **Top bar:** a minimum height of 64 dp that grows with text. It holds the platform back button (pulled 12 dp left to align optically) and a trailing slot (the language switch).
- **Phones (shortest side < 600 dp):** the thumb-zone rule applies. On brand screens (splash, sign-in) the header is centered in the upper free space. On task screens the headline sits 8 dp under the bar. Flexible space then pushes the form toward the bottom, with a 32 dp minimum clearance above it.
- **Tablets (shortest side >= 600 dp):** the thumb-zone rule does not apply. Header and body form one vertically centered group separated by a fixed 48 + 32 dp gap, still capped at 480 dp.
- **Rhythm:** 8 dp (label to field, button to link), 12 dp (headline to intro, heading to first field), 16 dp (notice gaps, notice padding), 24 dp (page padding, notice to action), 28 dp (last field to primary action), 32 dp (header clearance).
- **Brand block yielding:** the logo is 17% of screen height (104-160 dp) at rest, 12% (80-104 dp) when a notice needs room, and 64 dp with no tagline when the keyboard is open or when large text (>= 130%) meets a short screen (< 700 dp).

### Named Rules
**The Thumb Zone Rule.** On phones the primary action sits low, within thumb reach, and stays in the first viewport. The brand gives up space before the action does.

## Elevation & Depth

Fully flat. No component casts a shadow, and the Material filled button and Cupertino button are used without elevation. Depth is outline and fill only: on white, fields and code boxes are defined by their stone outline; on ember, by the ember-field fill and kiln border. Focus and error are shown with border weight (1.5 dp at rest, 3 dp when focused or in error), not by lifting.

### Named Rules
**The Sign-on-a-Wall Rule.** Surfaces on the threshold are flat planes on the ground. Separate them with color and border, never with shadow.

## Shapes

Softly rounded rectangles in one family: 14 dp for the primary button, fields, and notice panels, and 12 dp for the smaller one-time-code boxes. Borders are solid, 1.5 dp at rest and 3 dp when active. The only curved silhouettes are the platform's own (segmented controls, circular rule icons, activity indicators), the round planet mark in the logo, and the 96 dp solid circle behind the check on the reset-done screen.

## Components

### Buttons
Big, solid, and alone: one per screen.
- **Shape:** 14 dp corners, full width, 60 dp tall.
- **Primary:** logo navy with a white label in light mode; site accent orange with an ember label in dark mode. A Material FilledButton on Android and a filled CupertinoButton on iOS.
- **Busy:** keeps its fill and shows a 24 dp platform spinner (CircularProgressIndicator 2.5 stroke / CupertinoActivityIndicator) in the label color, and ignores taps. It never greys out while working.
- **Link (secondary):** 16sp/600 text with a 1.5-thickness underline in brand orange (white in dark mode), 12 dp horizontal padding, 48 × 48 dp minimum target. A 15sp compact variant sits in label rows ("Not you?"). Disabled links take the muted text color. TextButton on Android, CupertinoButton on iOS.

### Inputs / Fields
- **Style:** label row above (title type in stone ink, white in dark mode, 48 dp minimum height, optional trailing link action), then a filled field with 64 dp visual height, 14 dp corners, and 18dp/21dp padding. Light mode: white fill, stone-outline 1.5 dp border. Dark mode: ember-field fill, kiln 1.5 dp border.
- **Focus:** 3 dp border and cursor in navy (light) or site accent orange (dark).
- **Error:** 3 dp border and a bold message below, both in the error color: danger red on white (6.5:1), white on ember (12.8:1 on the ember field). Red is never drawn on ember, where it measures under 3:1.
- **Suffix:** platform eye icon (visibility_outlined / CupertinoIcons.eye) for show/hide password, in the hint color.

### One-Time-Code Input
Six boxes 68 dp tall, gapped 8 dp, with 12 dp corners and 30sp tabular digits, styled like fields (white with a stone outline, ember-field with a kiln border in dark mode). They sit over one invisible text field so paste and OS one-time-code autofill fill every box. The active box takes the focus border, and every box takes the red border on error (legible on white; see the dark-mode note under Inputs). Border changes animate over 160 ms with easeOutCubic.

### Notice Panel
A tinted panel with 14 dp corners and 16 dp padding: pale red for errors and pale blue for information in light mode, cream for both in dark mode. It has a 24 dp platform icon (error: red filled circle; info: navy filled info) and body text in stone ink. It is a live region for screen readers. Used for form-level errors, session expiry, and splash load failures.

### Language Switch
EN/ES codes in label type, placed at the top right of the threshold. On Android it is a Material SegmentedButton with a 1.5 dp outline in the text color and 56 × 48 dp segments; the selected segment is filled with the text color (stone ink on white, white on ember) and its label takes the ground color. On iOS it is a CupertinoSlidingSegmentedControl with a stone-track background (white 20% on ember) and a thumb in the text color. Each segment announces the full language name.

### Password Rule Rows
One rule per row with 4 dp vertical padding: a 24 dp platform icon, then 16sp text. Met rules show a filled check in 700 text in the main text color. Unmet rules show an empty circle in 500 text in the muted color. Met and unmet differ by icon shape and weight, not only by color. The icon swaps with a 180 ms crossfade.

### Brand Block
The full-color logo in light mode, or the white knockout logo on ember (the inked shapes become white and the logo's own white highlights become holes), with the brand tagline beneath it in the muted color. Height changes animate over 280 ms with easeOutCubic (see Layout for the yielding states).

### Launch and Splash
The native launch fills with white and the full-color logo raster (ember with the white logo in dark mode), so a cold start matches the first Flutter frame. The Flutter splash continues the same ground with the brand block and a centered platform activity indicator in the main text color.

### Motion and Feedback
280 ms easeOutCubic for brand-block compaction; 160-180 ms for small state swaps (code box borders, rule icons). A medium haptic impact accompanies every submit error.

## Do's and Don'ts

### Do:
- **Do** fill the whole screen with white and the full-color logo (ember and the white logo in dark mode) on every pre-sign-in screen, native launch included.
- **Do** keep one primary action per screen: full width, 60 dp, logo navy (site accent orange in dark mode), in the thumb zone on phones.
- **Do** keep every tappable target at least 48 × 48 dp and fields at 64 dp.
- **Do** use minimum heights, not fixed heights, on any row that holds text, so 200% text grows instead of clipping.
- **Do** show field errors as bold danger-red text plus a red 3 dp border on white (bold white text on ember), and form-level errors as a tinted panel with a red icon.
- **Do** tell states apart by shape or weight as well as color (check vs empty circle, 700 vs 500).
- **Do** use Material components on Android and Cupertino components on iOS for buttons, segmented controls, spinners, and icons.
- **Do** cap threshold content at 480 dp and center it as one group on tablets.

### Don't:
- **Don't** put error or warning signals in orange, or anything red or orange on the ember ground.
- **Don't** put the threshold form in a card or give fields gray fills; the form sits on the full-bleed ground and fields are outlined white.
- **Don't** use brand orange as a fill or border on the white threshold; it is the link color there.
- **Don't** drench interior screens in orange or ember; inside the app, orange is an accent on neutral surfaces.
- **Don't** add shadows or elevation to threshold surfaces.
- **Don't** use logo orange as a UI color; it belongs to the logo.
