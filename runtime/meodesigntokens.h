#pragma once

#include <QtCore/QtGlobal>

namespace Meo {

// Canonical, density-independent Meo design metrics. Colour is intentionally
// derived from the active QPalette by each renderer so accent/light/dark
// changes remain live instead of being frozen into a second palette.
class DesignTokens final
{
public:
    static constexpr qreal shapeExtraSmall() { return 4.0; }
    static constexpr qreal shapeSmall() { return 8.0; }
    static constexpr qreal shapeMedium() { return 12.0; }
    static constexpr qreal shapeLarge() { return 16.0; }
    static constexpr qreal shapeLargeIncreased() { return 20.0; }
    static constexpr qreal shapeExtraLarge() { return 28.0; }
    static constexpr qreal shapeExtraLargeIncreased() { return 32.0; }
    static constexpr qreal shapeExtraExtraLarge() { return 48.0; }

    static constexpr qreal space2() { return 2.0; }
    static constexpr qreal space4() { return 4.0; }
    static constexpr qreal space8() { return 8.0; }
    static constexpr qreal space12() { return 12.0; }
    static constexpr qreal space16() { return 16.0; }
    static constexpr qreal space24() { return 24.0; }
    static constexpr qreal space32() { return 32.0; }
    static constexpr qreal space40() { return 40.0; }
    static constexpr qreal space48() { return 48.0; }

    static constexpr qreal iconSizeXS() { return 16.0; }
    static constexpr qreal iconSizeS() { return 18.0; }
    static constexpr qreal iconSizeM() { return 24.0; }
    static constexpr qreal iconSizeL() { return 32.0; }
    static constexpr qreal iconSizeXL() { return 48.0; }

    static constexpr qreal buttonHeightXS() { return 32.0; }
    static constexpr qreal buttonHeightS() { return 40.0; }
    // Material 3 Expressive button size tokens (AndroidX Material 3,
    // Button{XSmall,Small,Medium,Large,XLarge}Tokens).  These are shared
    // across QML controls so the same named size never means different
    // geometry in a button, group, or split button.
    static constexpr qreal buttonHeightM() { return 56.0; }
    static constexpr qreal buttonHeightL() { return 96.0; }
    static constexpr qreal buttonHeightXL() { return 136.0; }

    // Cross-toolkit control semantics.  QML controls, the Plasma shell and
    // the native Qt style consume these aliases instead of independently
    // choosing a value from the raw shape scale.
    static constexpr qreal controlHeight() { return buttonHeightS(); }
    static constexpr qreal controlRadius() { return shapeMedium(); }
    static constexpr qreal controlPressedRadius() { return shapeSmall(); }
    static constexpr qreal cardRadius() { return shapeLargeIncreased(); }
    static constexpr qreal dialogRadius() { return shapeExtraLarge(); }
    static constexpr qreal windowRadius() { return shapeLarge(); }
    static constexpr qreal focusRingWidth() { return space2(); }

    // Material 3 Expressive icon-button container heights (AndroidX Material
    // 3, {XSmall,Small,Medium,Large,XLarge}IconButtonTokens). The visual
    // container remains separate from the 48dp minimum interactive target in
    // MeoIconButton.
    static constexpr qreal iconButtonSizeXS() { return 32.0; }
    static constexpr qreal iconButtonSizeS() { return 40.0; }
    static constexpr qreal iconButtonSizeM() { return 56.0; }
    static constexpr qreal iconButtonSizeL() { return 96.0; }
    static constexpr qreal iconButtonSizeXL() { return 136.0; }

    // AndroidX Material 3 StateTokens (v0_210, Apache-2.0):
    // Cross-renderer Material motion contract, matching MeoMotion's existing
    // default effects and expressive fast spatial springs (unit mass).
    static constexpr qreal motionEffectsDamping() { return 1.0; }
    static constexpr qreal motionEffectsStiffness() { return 1600.0; }
    static constexpr qreal motionFastSpatialDamping() { return 0.6; }
    static constexpr qreal motionFastSpatialStiffness() { return 800.0; }
    static constexpr qreal motionFastMaximumDuration() { return 500.0; }

    // https://android.googlesource.com/platform/frameworks/support/+/64212d2a7941fd734599a75b73fc3750e8bb1cb3/compose/material3/material3/src/commonMain/kotlin/androidx/compose/material3/tokens/StateTokens.kt
    // Keep the native singleton and QML fallback on the same state-layer
    // values. Only token values were transcribed; no upstream code was copied.
    static constexpr qreal stateOpacityHover() { return 0.08; }
    static constexpr qreal stateOpacityFocus() { return 0.10; }
    static constexpr qreal stateOpacityPressed() { return 0.10; }
    static constexpr qreal stateOpacityDragged() { return 0.16; }
};

} // namespace Meo
