---
name: Space Clean
description: Operations app for commercial cleaning companies; blue-gray ground, white rounded cards, big bold Manrope titles, orange pill actions, navy information, every color taken from the Space Clean logo.
colors:
  primary: "#D14702"
  on-primary: "#FFFFFF"
  ground: "#EEF2F6"
  surface: "#FFFFFF"
  sunken: "#F4F7FA"
  line: "#DCE4EC"
  ink: "#0B1F33"
  ink-muted: "#56677B"
  ink-soft: "#66809C"
  ink-faint: "#A9B8C8"
  logo-navy: "#0A4781"
  navy-wash: "#E3EBF4"
  on-navy: "#FFFFFF"
  logo-orange: "#F45302"
  orange-wash: "#FEEDE3"
  orange-ink: "#A83A02"
  success: "#15803D"
  success-wash: "#DDF3E4"
  success-ink: "#166534"
  danger: "#B91C1C"
  danger-wash: "#FDE8E8"
typography:
  page-title:
    fontFamily: "Manrope"
    fontSize: "30px"
    fontWeight: 700
    lineHeight: 1.15
    letterSpacing: "-0.8px"
  hero:
    fontFamily: "Manrope"
    fontSize: "28px"
    fontWeight: 700
    lineHeight: 1.15
    letterSpacing: "-0.8px"
  figure:
    fontFamily: "Manrope"
    fontSize: "24px"
    fontWeight: 800
    letterSpacing: "-0.5px"
    fontFeature: "tnum"
  title:
    fontFamily: "Manrope"
    fontSize: "16px"
    fontWeight: 700
  body:
    fontFamily: "Manrope"
    fontSize: "16px"
    fontWeight: 400
    lineHeight: 1.45
  body-muted:
    fontFamily: "Manrope"
    fontSize: "14px"
    fontWeight: 400
  field-label:
    fontFamily: "Manrope"
    fontSize: "14px"
    fontWeight: 600
  field-value:
    fontFamily: "Manrope"
    fontSize: "17px"
    fontWeight: 500
  button:
    fontFamily: "Manrope"
    fontSize: "16px"
    fontWeight: 700
  pill:
    fontFamily: "Manrope"
    fontSize: "12.5px"
    fontWeight: 700
rounded:
  inner: "16px"
  card: "24px"
  sheet: "28px"
  pill: "999px"
spacing:
  gap: "12px"
  page: "20px"
  card: "20px"
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.button}"
    rounded: "{rounded.pill}"
    height: "56px"
  button-secondary:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink}"
    typography: "{typography.button}"
    rounded: "{rounded.pill}"
    height: "56px"
  button-secondary-destructive:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.danger}"
    rounded: "{rounded.pill}"
    height: "56px"
  button-link:
    textColor: "{colors.logo-navy}"
    height: "48px"
  circle-button-dark:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    rounded: "{rounded.pill}"
    size: "44px"
  circle-button-light:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink}"
    rounded: "{rounded.pill}"
    size: "44px"
  card:
    backgroundColor: "{colors.surface}"
    rounded: "{rounded.card}"
    padding: "{spacing.card}"
  accent-banner:
    backgroundColor: "{colors.logo-navy}"
    textColor: "{colors.on-navy}"
    padding: "12px 20px"
  input:
    backgroundColor: "{colors.sunken}"
    textColor: "{colors.ink}"
    typography: "{typography.field-value}"
    rounded: "{rounded.inner}"
    padding: "18px"
  pill-toggle-selected:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    rounded: "{rounded.pill}"
    height: "40px"
  pill-toggle-idle:
    textColor: "{colors.ink-muted}"
    rounded: "{rounded.pill}"
    height: "40px"
  choice-pill:
    backgroundColor: "{colors.sunken}"
    textColor: "{colors.ink}"
    rounded: "{rounded.pill}"
    height: "44px"
  choice-pill-selected:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    rounded: "{rounded.pill}"
    height: "44px"
  status-pill-scheduled:
    backgroundColor: "{colors.navy-wash}"
    textColor: "{colors.logo-navy}"
    typography: "{typography.pill}"
    rounded: "{rounded.pill}"
    padding: "5px 10px"
  status-pill-in-progress:
    backgroundColor: "{colors.orange-wash}"
    textColor: "{colors.orange-ink}"
    typography: "{typography.pill}"
    rounded: "{rounded.pill}"
    padding: "5px 10px"
  status-pill-completed:
    backgroundColor: "{colors.success-wash}"
    textColor: "{colors.success-ink}"
    typography: "{typography.pill}"
    rounded: "{rounded.pill}"
    padding: "5px 10px"
  notice-error:
    backgroundColor: "{colors.danger-wash}"
    textColor: "{colors.ink}"
    rounded: "{rounded.inner}"
    padding: "16px"
  bottom-bar:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink-muted}"
    height: "72px"
  bottom-bar-active:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.primary}"
    height: "72px"
---

# Design System: Space Clean

## Overview

**Creative North Star: "The Pocket Ledger"**

Every screen is a stack of white rounded cards on a light blue-gray ground, headed by a big bold Manrope title. The system follows the user's reference (`docs/example_app.png`) in structure: a pale ground, white cards with no shadows, two-tone hero headlines, round header buttons, full-width pill actions, and a custom white tab bar. Every color comes from the Space Clean logo. Primary orange (the logo orange deepened just enough to carry white text) is the action color. Logo navy is the secondary color that informs: links, progress, banners, badges, info. The logo's blue-grays tint the ground, the text grays, and the outlines.

One custom design runs on both Android and iOS. What stays native is behavior, not look: back gestures and page transitions (go_router pages), adaptive dialogs (`lib/core/widgets/adaptive.dart`), native date and choice pickers (`lib/core/design/widgets/pickers.dart`), the adaptive pull-to-refresh, and haptics. The app has a light and a dark theme. Appearance (Me → Settings) is System, Light or Dark, and defaults to System. The native launch screen matches either one: the ground #EEF2F6 with the color logo, or the night ground #0B1420 with the white logo, so launch never flashes.

Density is calm and thumb-first. Cards are generous (20px padding, 24px corners). Numbers crew scan for (time ranges, counts, checklist fractions) are the biggest thing in their card. Primary actions are full-width 56px orange pills.

**Retired:** the earlier "threshold" system is gone. It had an orange/white sign-in door, an ember dark mode, per-OS Material/Cupertino widgets, and the `app_theme`/`threshold_*` widget files. Do not revive those. The old orange/ember constants file (`brand_colors.dart`) was deleted. Two interim palettes were also replaced: a neutral-gray one with black actions, then a logo palette with navy actions.

**Key Characteristics:**
- Blue-gray ground, white 24px cards, no shadows. Fields are the only elements with an outline at rest.
- Manrope everywhere, bold and tightly tracked at display sizes.
- Primary orange acts: primary pills, the round "+" button, selected toggles and pills, the active tab, focus rings, the cursor, and spinners.
- Logo navy informs: links, progress bars, accent banners, strong badges and avatars, info notices, the "Scheduled" pill, and the active-tab dot.
- Orange text on tints always uses the darker Orange Ink. Primary orange never appears as small text on the ground.
- One custom look on both platforms, with native behaviors kept.

## Colors

Navy-black ink on white cards and a light blue-gray ground, all from the logo. Orange acts, and navy informs.

### Primary
- **Primary Orange** (primary): the action color. It fills FilledButton/PrimaryButton, the dark circle button (`CircleButton.dark`), selected pill-toggle options, and selected choice pills. It also colors the active tab's icon and label, input and search focus borders, the cursor, the active code box, spinners and the refresh indicator, and the Cupertino primary. White on it measures 4.55:1, and it measures 4.55:1 on white, 4.23:1 on sunken, and 4.05:1 on ground. Use it on white or as a fill, never as small text on the ground or sunken.
- **On Primary** (on-primary): white text and icons on Primary Orange.

### Secondary
- **Logo Navy** (logo-navy): the informing color. It colors text links, the progress bar, the accent banner along a card's bottom edge, strong icon badges and avatars, empty-state icons, info notices, the "Scheduled" status pill, navy account badges, and the 5px dot under the active tab. White on navy and navy on white both measure 9.41:1.
- **Navy Wash** (navy-wash): progress track, soft icon badges, navy account badges, the "Scheduled" status pill, role pills, and info notice fill.

### Tertiary
- **Logo Orange** (logo-orange): the logo orange as drawn. It is reserved for graphic marks and is the scheme's tertiary color, but no shipped widget paints with it today. It measures 3.45:1 on white, so it is never text.
- **Orange Wash** (orange-wash): the tint behind orange marks: the "In progress" pill, the emergency-contact badge, and alternating account badges.
- **Orange Ink** (orange-ink): all orange text and icons on Orange Wash (5.64:1), including the "In progress" pill, the emergency-contact badge icon, and orange account-badge initials.

### Neutral
- **Blue-Gray Ground** (ground): every page background, bottom sheets, native splash, and the Android window background.
- **White Surface** (surface): cards, the bottom bar, dialogs, secondary pills, and light circle buttons.
- **Sunken** (sunken): input fills, picker fields, code boxes, idle choice pills, initials avatars, and the cancelled/unknown status fill.
- **Hairline** (line): dividers between rows inside a list card and the outline of disabled fields.
- **Navy Ink** (ink): all headline and body text, secondary-button labels, light circle-button icons, and field values (16.69:1 on white, 14.84:1 on ground).
- **Muted Ink** (ink-muted): secondary text, captions, helper text, hints, "Not set", idle toggle labels, idle tab icons and labels, and trailing values. It measures 5.80:1 on white, 5.15:1 on ground, and 5.39:1 on sunken.
- **Soft Ink** (ink-soft): large text and UI parts only. It sets the second line of hero headlines, the time on finished job cards, the 1px outline on enabled fields, picker fields, and idle code boxes, row chevrons, and unmet password-rule icons. It measures 4.09:1 on white, 3.64:1 on ground, and 3.81:1 on sunken.
- **Faint Ink** (ink-faint): disabled controls only. At 2.02:1 on white it never carries meaning.

### Status
- **Success** (success / success-wash): met password-rule icons (5.02:1 on white) and the success notice icon (4.30:1 on its wash, an icon).
- **Success Ink** (success-ink): text on Success Wash (6.12:1), used by the "Completed" status pill.
- **Danger** (danger / danger-wash): field errors, error notices, destructive list rows, and destructive secondary buttons such as "Sign out" (6.47:1 on white, 5.51:1 on its wash).

### Dark Palette

Dark mode keeps the same roles, with its own values (`SpaceColors.dark` in `lib/core/design/tokens.dart`). Every text pair meets the same minimums as in light mode.

- **Ground** #0B1420 (night navy), **Surface** #152232, **Sunken** #0F1A27, **Line** #26384C.
- **Ink** #E9EFF5 (13.9:1 on surface). **Muted Ink** #A6B6C7 (7.8:1). **Soft Ink** #7E97B1 (5.3:1). **Faint Ink** #4B5E73 (disabled only).
- **Primary Orange** stays #D14702 with white on it (4.55:1). On the surface it measures 3.5:1, so it is used for fills and UI parts only.
- **Accent** becomes the navy's light tint #8FBCEB (8.1:1 on surface), with navy #0B1F33 text and icons on accent fills. The logo navy is too dark to read on a dark ground. **Accent Soft** is #1A3450.
- **Orange Ink** #FFA474 on **Orange Soft** #3B2013. **Success** #4ADE80, **Success Ink** #86EFAC on #12301F. **Danger** #F87171 on #3A1719.
- The logo switches to the white knockout (`SpaceLogo`), and the status bar icons turn light.

### Named Rules
**The Orange Acts, Navy Informs Rule.** Anything you press to act, and any control's selected or focused state, is Primary Orange: primary pills, the "+" circle, selected toggles and pills, the active tab, focus rings, the cursor, and spinners. Anything that informs is navy: links, progress, banners, badges, avatars, info notices, and the "Scheduled" status. Never make a primary action navy or black, and never draw progress or a link in orange.

**The Deep Orange Rule.** Only Primary Orange (#D14702) carries white text, at 4.55:1. The raw logo orange (#F45302) never sits behind text and never is text. Primary Orange as text belongs on white only (4.55:1), never on the ground (4.05:1) or sunken (4.23:1). Orange text on tints uses Orange Ink.

**The Wash Ink Rule.** Text on a wash uses that hue's ink tone, not its brand tone: Orange Ink on Orange Wash (5.64:1), Success Ink on Success Wash (6.12:1), Logo Navy on Navy Wash (7.82:1), Danger on Danger Wash (5.51:1). Logo orange on its wash (3.03:1) is for graphics only, and success on its wash (4.30:1) is for icons only.

**The Muted Floor Rule.** Text below large size never goes lighter than Muted Ink (5.80:1 on white, 5.15:1 on ground, 5.39:1 on sunken). That includes hints, placeholders, and idle tab labels. Soft Ink is only for large text (18.66px bold or 24px regular and up) and for UI boundaries and icons, where it clears 3:1 on every ground. Faint Ink is only for disabled controls.

## Typography

**Display Font:** Manrope (bundled, OFL, weights 400/500/600/700/800 in `assets/fonts`)
**Body Font:** Manrope
**Label Font:** Manrope

**Character:** A single geometric sans. It is bold and tightly tracked at title sizes, then plain and roomy in body copy, and it respects OS text scaling at every size.

### Hierarchy
- **Page title** (700, 30px, 1.15, -0.8 tracking): the big header title on every SpacePage ("Today", "Accounts").
- **Hero** (700, 28px, 1.15, -0.8): two-tone headlines. The first line is ink and the second is Soft Ink ("Hi, Ana / 3 jobs today", "Sign in / One Partner. Every Facility Solution.").
- **Figure** (800, 24px, -0.5, tabular figures): big numbers in stat cards (26px compact, three across), 22px job-card time ranges, and 32px on job detail (time and checklist fraction).
- **Title** (700, 16px): card and tile titles, section headers, and list-row titles (600).
- **Body** (400, 16px, 1.45): intros and prose. Reset step intros use Muted Ink.
- **Body muted** (400, 14px, Muted Ink): labels above numbers, subtitles, and captions.
- **Field label** (600, 14px, ink) over **field value** (500, 17px).
- **Button** (700, 16px). Text links use 700 at 15px in navy.
- **Pill** (700, 12.5px): status pills and tab labels.

### Dark Palette

Dark mode keeps the same roles, with its own values (`SpaceColors.dark` in `lib/core/design/tokens.dart`). Every text pair meets the same minimums as in light mode.

- **Ground** #0B1420 (night navy), **Surface** #152232, **Sunken** #0F1A27, **Line** #26384C.
- **Ink** #E9EFF5 (13.9:1 on surface). **Muted Ink** #A6B6C7 (7.8:1). **Soft Ink** #7E97B1 (5.3:1). **Faint Ink** #4B5E73 (disabled only).
- **Primary Orange** stays #D14702 with white on it (4.55:1). On the surface it measures 3.5:1, so it is used for fills and UI parts only.
- **Accent** becomes the navy's light tint #8FBCEB (8.1:1 on surface), with navy #0B1F33 text and icons on accent fills. The logo navy is too dark to read on a dark ground. **Accent Soft** is #1A3450.
- **Orange Ink** #FFA474 on **Orange Soft** #3B2013. **Success** #4ADE80, **Success Ink** #86EFAC on #12301F. **Danger** #F87171 on #3A1719.
- The logo switches to the white knockout (`SpaceLogo`), and the status bar icons turn light.

### Named Rules
**The Tabular Numbers Rule.** Every count, time range, and fraction uses tabular figures, so digits don't jitter when values change.

**The Sentence Case Rule.** Titles, labels, and buttons are sentence case. The only uppercase text is initials in avatars and the compact "EN/ES" language codes.

## Layout

Single column with a 20px side margin (`page`). Content is capped at 640px (`maxContentWidth`) and centered on wider screens, so on tablets the side margin grows to `(width − 640) / 2`. Every page sliver and pinned bottom action uses the same `pageSide()` margin. The header sits 12px below the safe area. Top-level screens put the title and round action buttons on one row at least 56px tall. Pushed screens get a white round back button first, then the title 16px below it. Content blocks start 16px apart by default, and cards stack with a 12px gap (`gap`). Sibling cards pair up in two-column grids (CardGrid) or equal-width rows (CardRow, e.g. three compact stats) with equal heights. Inside cards, padding is 20px and fields stack 12px apart, with 24px before the primary button. Every scroll view ends with safe-area bottom padding plus 24px. Pinned bottom actions (Save) sit in the Scaffold's bottom slot above the keyboard.

**The 640 Column Rule.** No content column is wider than 640px. Wider screens center it on the ground rather than stretching cards or fields.

## Elevation & Depth

The system is flat. No BoxShadow and no Material elevation appear anywhere in the design layer. Depth comes from tone alone: white surfaces on the ground (1.12:1), sunken fills inside white cards (1.08:1), and full-bleed navy banners at the base of a card. These tonal steps are too faint to mark an input, so fields carry a 1px Soft Ink outline. The only lift is ink ripples (InkSparkle) on press and the native sheet and dialog presentation.

### Dark Palette

Dark mode keeps the same roles, with its own values (`SpaceColors.dark` in `lib/core/design/tokens.dart`). Every text pair meets the same minimums as in light mode.

- **Ground** #0B1420 (night navy), **Surface** #152232, **Sunken** #0F1A27, **Line** #26384C.
- **Ink** #E9EFF5 (13.9:1 on surface). **Muted Ink** #A6B6C7 (7.8:1). **Soft Ink** #7E97B1 (5.3:1). **Faint Ink** #4B5E73 (disabled only).
- **Primary Orange** stays #D14702 with white on it (4.55:1). On the surface it measures 3.5:1, so it is used for fills and UI parts only.
- **Accent** becomes the navy's light tint #8FBCEB (8.1:1 on surface), with navy #0B1F33 text and icons on accent fills. The logo navy is too dark to read on a dark ground. **Accent Soft** is #1A3450.
- **Orange Ink** #FFA474 on **Orange Soft** #3B2013. **Success** #4ADE80, **Success Ink** #86EFAC on #12301F. **Danger** #F87171 on #3A1719.
- The logo switches to the white knockout (`SpaceLogo`), and the status bar icons turn light.

### Named Rules
**The No-Shadow Rule.** Cards, buttons, bars, and sheets carry no shadow and no border. If something needs to separate, change its tone, not its elevation. The one exception is the field outline (see Shapes), which exists for input legibility, not depth.

## Shapes

The shapes are rounded throughout, in four steps. Cards and dialogs use 24px corners. Inner elements use 16px: fields, picker fields, code boxes, and notices. Bottom sheets use 28px top corners and show a drag handle. Buttons, toggles, choice pills, status pills, and progress bars are full pills (999). Circles are reserved for header buttons (44px visible, 48px target), icon badges (40px), initials avatars (44px, 48px on account tiles), and the 5px active-tab dot. Borders are reserved for inputs. At rest, enabled fields, picker fields, and idle code boxes have a 1px Soft Ink outline (Hairline when disabled). Focus replaces it with a 2px Primary Orange ring (4.23:1 against the fill), and errors with a 2px danger ring. Hairline dividers inside list cards are inset 20px from each side.

## Components

### Buttons
- **Primary:** a full-width Primary Orange pill, 56px tall, with white 16px/700 text (4.55:1) and an optional 20px leading icon. While busy it keeps its orange fill and shows a white 22px spinner, and disabled keeps the fill too. Use one per screen.
- **Secondary:** a white pill with the same geometry and ink text. The destructive variant uses danger text ("Sign out"). Disabled text is Faint Ink.
- **Link:** a navy text button, 15px/700, 48px minimum target ("Forgot password?", "Not you?").
- **Circle buttons:** 44px circles inside a 48px target, with 22px rounded icons. Primary Orange with a white icon (4.55:1) is for the screen's main add or edit action (the class is still `CircleButton.dark`). Its fill measures 4.05:1 against the ground. White with an ink icon is for back and secondary actions. Every one has a tooltip and a semantic label.

### Chips / Pills
- **Pill toggle** (single choice): a white or sunken track with 4px padding. The selected option is a Primary Orange pill with white 14px/700 text (4.55:1), and idle options are transparent with Muted Ink text. Used for the language toggle and the users list filter (Active / Inactive / All).
- **Choice pills** (multi-select): pills at least 44px tall, sunken with ink text when idle, and Primary Orange with a white check when selected. Used to pick roles.
- **Status pill:** a wash fill with a matching icon and 12.5px/700 label in that hue's ink tone. The pairs are Logo Navy on Navy Wash for Scheduled (7.82:1), Orange Ink on Orange Wash for In progress (5.64:1), Success Ink on Success Wash for Completed (6.12:1), and Muted Ink on Sunken for Cancelled (5.39:1). The icon is always present, so status never depends on color alone.

### Cards / Containers
- **SpaceCard:** white, 24px corners, 20px padding, no border or shadow, and a whole-card ink ripple when tappable. It is the only container.
- **StatCard:** a muted label over a big 800-weight tabular number, with an optional icon badge, corner arrow, and caption. Compact uses 16px padding and a 26px number.
- **TileCard:** an icon badge, 28px space, a 700 title, and a muted subtitle, placed in a two-column CardGrid. Account tiles use a 48px initials badge that alternates between navy on Navy Wash (7.82:1) and Orange Ink on Orange Wash (5.64:1).
- **ListCard / ListRow:** rows inside one card, separated by inset hairlines. Rows are at least 60px tall, with a leading badge or avatar, a title and muted subtitle, a trailing muted value, and a Soft Ink chevron when tappable (4.09:1).
- **AccentBanner:** a full-bleed navy strip in a card's footer with white 14px/600 text (9.41:1) and an optional white icon ("3 of 8 done").

### Inputs / Fields
- **Text field:** a 14px/600 ink label in a row at least 36px tall (it can hold a trailing link), over a sunken fill with 16px corners, 18px padding, and 17px/500 ink text. At rest the field has a 1px Soft Ink outline (3.81:1 against the fill, 4.09:1 against the white card), and the hint is Muted Ink. Focus shows a 2px Primary Orange border and an orange cursor, errors show a 2px danger border, and error text is 13px/600 danger. Fields sit inside a white card.
- **Picker field:** looks like a text field, with the same 1px Soft Ink outline and a trailing Muted Ink expand icon. "Not set" appears in Muted Ink. It opens the platform's native picker.
- **Code input:** six sunken 64px-tall boxes, 8px apart, over one invisible field (supports paste and OS one-time-code autofill). Digits are 28px/800 tabular. Idle boxes have a 1px Soft Ink outline, and the active box gets a 2px Primary Orange border with a 160ms ease-out-cubic transition.
- **Notice:** a wash-tinted 16px-corner block (danger, navy info, or success) with a 22px icon in the strong tone and 15px/500 ink text. It is announced as a live region.

### Navigation
- **Bottom bar:** white, 72px plus safe area, and the same on both platforms. The active tab is Primary Orange (4.55:1 on white), with a filled 26px icon, a 12.5px/700 label, and a 5px navy dot under the label that grows in over 180ms. Idle tabs use outlined icons and 500-weight labels in Muted Ink (5.80:1). Active and idle differ in weight, icon fill, and the dot as well as color. Tabs are Today, Accounts, and Me.
- **Search field** (users list): a white pill on the ground with a 1px Soft Ink outline (3.64:1 against the ground), a Muted Ink search icon and hint, and a 2px Primary Orange border on focus.
- **Header:** the page title plus round action buttons. Pushed screens start with a white back circle, and the native back gesture still works.

### Signature: Two-Tone Hero
The HeroHeadline is a 28px/700 headline whose second line drops to Soft Ink (3.64:1 on the ground, as large text). It opens sign-in, Today, account, and job detail screens, and it may replace the page title when the hero says it all.

## Do's and Don'ts

### Do:
- **Do** build every screen from SpacePage, with the blue-gray ground, a 20px margin, and white 24px cards spaced 12px apart.
- **Do** use one Primary Orange full-width 56px pill per screen for the main action. Make secondary actions white pills or navy links.
- **Do** take every new color from the logo palette in `tokens.dart`: navy, orange, and their blue-gray tints.
- **Do** use Primary Orange for acting, selected, and focused states, and navy for links, progress, banners, badges, and info.
- **Do** set orange text on tints in Orange Ink, and put white text only on Primary Orange, never on the raw logo orange.
- **Do** pair every status color with an icon.
- **Do** keep native behaviors: adaptive dialogs, native pickers, back gestures, and adaptive refresh.
- **Do** keep dialog action text navy (`adaptiveAction`); on the translucent iOS alert, orange text would fall under 4.5:1. Destructive actions keep system red.
- **Do** use tabular figures for times, counts, and fractions.
- **Do** keep text below large size at Muted Ink or darker, on white, ground, and sunken alike.
- **Do** put text on a wash in that hue's ink tone (Orange Ink, Success Ink, Logo Navy, Danger).
- **Do** give every enabled input a 1px Soft Ink outline.
- **Do** cap content at 640px and center it on wide screens.

### Don't:
- **Don't** add shadows, borders, or Material elevation to cards, bars, or buttons.
- **Don't** fill a primary action with navy or black. Actions are Primary Orange.
- **Don't** set text in the raw logo orange (3.45:1 on white), in Primary Orange on the ground or sunken, or in success green on its own wash.
- **Don't** reintroduce the retired threshold system: no orange sign-in ground, no ember dark mode, and no per-OS Material/Cupertino widget sets.
- **Don't** hard-code a color or read a palette directly (`SpaceColors.light`). Widgets take colors from the theme (`context.colors`) so they work in both modes.
- **Don't** use Soft Ink for body-size text, hints, placeholders, or navigation labels, or use Faint Ink for anything but disabled controls.
- **Don't** add uppercase eyebrows or kickers above titles.
- **Don't** use a font other than Manrope.
