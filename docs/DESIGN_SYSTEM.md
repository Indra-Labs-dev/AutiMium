# 🎨 AutoMium Design System - Futuristic Tech Theme

## Color Palette

### Primary Colors
```dart
// Main Blue - Electric Blue
Primary:     #0066FF
Cyan Glow:   #00D4FF
Neon Cyan:   #00FFFF

// Dark Backgrounds
Deep Space:  #050818
Dark Void:   #0A0E27
Nebula:      #0F1535
Cosmic:      #1A2345
```

### Accent Colors
```dart
// Success/Active
Green:       #00FF00

// Error/Danger
Red:         #FF3366

// Neutral
White:       #FFFFFF
Gray Blue:   #6B7B9F
```

## Gradient Combinations

### Title Gradient
```dart
LinearGradient(
  colors: [Color(0xFF00D4FF), Color(0xFF00FFFF)],
)
```

### Button Gradient
```dart
LinearGradient(
  colors: [Color(0xFF0066FF), Color(0xFF00D4FF)],
)
```

### Card Background
```dart
LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF0F1535).withOpacity(0.9),
    Color(0xFF1A2345).withOpacity(0.7),
  ],
)
```

## Typography

### App Title
- **Font Size:** 28-36px
- **Weight:** Bold
- **Letter Spacing:** 1.2-2.0
- **Effect:** Gradient shader (Cyan to Light Blue)

### Section Titles
- **Font Size:** 24-28px
- **Weight:** Bold
- **Letter Spacing:** 1.5
- **Color:** #00D4FF with gradient

### Body Text
- **Font Size:** 14-16px
- **Letter Spacing:** 0.3-0.5
- **Color:** White or #6B7B9F for secondary

### Terminal Output
- **Font:** Monospace
- **Size:** 13-14px
- **Color:** #00FF00 (Matrix Green)

## UI Components

### Cards
- **Border Radius:** 16-20px
- **Background:** Glassmorphism with opacity
- **Border:** #0066FF with 20-30% opacity
- **Shadow:** Blue glow effect
- **Elevation:** 8

### Buttons
- **Border Radius:** 12px
- **Height:** 56px
- **Gradient:** Blue to Cyan
- **Shadow:** Blue glow with 40% opacity
- **Text:** Bold, uppercase, letter-spacing 1.2

### Input Fields
- **Border Radius:** 12px
- **Background:** #0F1535 with 50% opacity
- **Border:** #0066FF (1px)
- **Focus Border:** #00D4FF (2px)
- **Label Color:** #00D4FF
- **Text Color:** White

### Status Indicators
- **Connected:** Green (#00FF00) with glow
- **Disconnected:** Red (#FF3366) with glow
- **Size:** 10-12px diameter
- **Effect:** Pulsing animation

## Effects & Animations

### Glow Effects
```dart
BoxShadow(
  color: Color(0xFF0066FF).withOpacity(0.3),
  blurRadius: 20,
  spreadRadius: 5,
)
```

### Pulse Animation
For status indicators:
- Duration: 500ms
- Scale: 1.0 to 1.2
- Opacity: 0.6 to 1.0

### Gradient Borders
Use `ShaderMask` with `LinearGradient` for text and icons

## Terminal Design

### Background
- **Color:** #0A0E27 or Black87
- **Border:** #00D4FF with 30% opacity
- **Border Width:** 2px
- **Corner Radius:** 20px

### Header
- **Gradient Background:** #0F1535 to #1A2345
- **Icon:** Terminal icon in #00D4FF
- **Title:** "TERMINAL OUTPUT" in bold cyan
- **Status Light:** Green pulsing dot

### Text
- **Color:** #00FF00 (Matrix Green)
- **Font:** Monospace
- **Letter Spacing:** 0.3

## Navigation

### Rail Background
- **Color:** #0A0E27
- **Indicator:** #0066FF
- **Selected Icon:** #00D4FF, size 28
- **Unselected Icon:** #6B7B9F, size 24

### Divider
- **Color:** #0066FF
- **Width:** 1px
- **Opacity:** 50%

## Usage Guidelines

1. **Always use gradients** for primary elements (titles, buttons)
2. **Maintain dark theme** - never use light backgrounds
3. **Blue glow effects** on interactive elements
4. **Monospace font** for all technical output
5. **High contrast** between text and background
6. **Smooth animations** (300-500ms duration)
7. **Glassmorphism** for cards and overlays

## Inspiration

- Cyberpunk 2077 UI
- Tron Legacy aesthetics
- Sci-fi HUD interfaces
- Neon-lit futuristic designs
- Matrix digital rain

---

**Version:** 1.0  
**Theme:** Futuristic Tech  
**Last Updated:** 2026
