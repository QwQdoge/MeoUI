#pragma once

#include <QtCore/QObject>
#include <QtCore/QtGlobal>
#include <QtQml/qqml.h>

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
    // https://android.googlesource.com/platform/frameworks/support/+/64212d2a7941fd734599a75b73fc3750e8bb1cb3/compose/material3/material3/src/commonMain/kotlin/androidx/compose/material3/tokens/StateTokens.kt
    // Keep the native singleton and QML fallback on the same state-layer
    // values. Only token values were transcribed; no upstream code was copied.
    static constexpr qreal stateOpacityHover() { return 0.08; }
    static constexpr qreal stateOpacityFocus() { return 0.10; }
    static constexpr qreal stateOpacityPressed() { return 0.10; }
    static constexpr qreal stateOpacityDragged() { return 0.16; }
};

} // namespace Meo

class MeoTokens final : public QObject
{
    Q_OBJECT
    QML_NAMED_ELEMENT(MeoTokens)
    QML_SINGLETON

    Q_PROPERTY(qreal shapeExtraSmall READ shapeExtraSmall CONSTANT)
    Q_PROPERTY(qreal shapeSmall READ shapeSmall CONSTANT)
    Q_PROPERTY(qreal shapeMedium READ shapeMedium CONSTANT)
    Q_PROPERTY(qreal shapeLarge READ shapeLarge CONSTANT)
    Q_PROPERTY(qreal shapeLargeIncreased READ shapeLargeIncreased CONSTANT)
    Q_PROPERTY(qreal shapeExtraLarge READ shapeExtraLarge CONSTANT)
    Q_PROPERTY(qreal shapeExtraLargeIncreased READ shapeExtraLargeIncreased CONSTANT)
    Q_PROPERTY(qreal shapeExtraExtraLarge READ shapeExtraExtraLarge CONSTANT)
    Q_PROPERTY(qreal space2 READ space2 CONSTANT)
    Q_PROPERTY(qreal space4 READ space4 CONSTANT)
    Q_PROPERTY(qreal space8 READ space8 CONSTANT)
    Q_PROPERTY(qreal space12 READ space12 CONSTANT)
    Q_PROPERTY(qreal space16 READ space16 CONSTANT)
    Q_PROPERTY(qreal space24 READ space24 CONSTANT)
    Q_PROPERTY(qreal space32 READ space32 CONSTANT)
    Q_PROPERTY(qreal space40 READ space40 CONSTANT)
    Q_PROPERTY(qreal space48 READ space48 CONSTANT)
    Q_PROPERTY(qreal iconSizeXS READ iconSizeXS CONSTANT)
    Q_PROPERTY(qreal iconSizeS READ iconSizeS CONSTANT)
    Q_PROPERTY(qreal iconSizeM READ iconSizeM CONSTANT)
    Q_PROPERTY(qreal iconSizeL READ iconSizeL CONSTANT)
    Q_PROPERTY(qreal iconSizeXL READ iconSizeXL CONSTANT)
    Q_PROPERTY(qreal buttonHeightXS READ buttonHeightXS CONSTANT)
    Q_PROPERTY(qreal buttonHeightS READ buttonHeightS CONSTANT)
    Q_PROPERTY(qreal buttonHeightM READ buttonHeightM CONSTANT)
    Q_PROPERTY(qreal buttonHeightL READ buttonHeightL CONSTANT)
    Q_PROPERTY(qreal buttonHeightXL READ buttonHeightXL CONSTANT)
    Q_PROPERTY(qreal controlHeight READ controlHeight CONSTANT)
    Q_PROPERTY(qreal controlRadius READ controlRadius CONSTANT)
    Q_PROPERTY(qreal controlPressedRadius READ controlPressedRadius CONSTANT)
    Q_PROPERTY(qreal cardRadius READ cardRadius CONSTANT)
    Q_PROPERTY(qreal dialogRadius READ dialogRadius CONSTANT)
    Q_PROPERTY(qreal windowRadius READ windowRadius CONSTANT)
    Q_PROPERTY(qreal focusRingWidth READ focusRingWidth CONSTANT)
    Q_PROPERTY(qreal iconButtonSizeXS READ iconButtonSizeXS CONSTANT)
    Q_PROPERTY(qreal iconButtonSizeS READ iconButtonSizeS CONSTANT)
    Q_PROPERTY(qreal iconButtonSizeM READ iconButtonSizeM CONSTANT)
    Q_PROPERTY(qreal iconButtonSizeL READ iconButtonSizeL CONSTANT)
    Q_PROPERTY(qreal iconButtonSizeXL READ iconButtonSizeXL CONSTANT)
    Q_PROPERTY(qreal stateOpacityHover READ stateOpacityHover CONSTANT)
    Q_PROPERTY(qreal stateOpacityFocus READ stateOpacityFocus CONSTANT)
    Q_PROPERTY(qreal stateOpacityPressed READ stateOpacityPressed CONSTANT)
    Q_PROPERTY(qreal stateOpacityDragged READ stateOpacityDragged CONSTANT)

public:
    explicit MeoTokens(QObject *parent = nullptr);
    static MeoTokens *create(QQmlEngine *engine, QJSEngine *scriptEngine);

    qreal shapeExtraSmall() const;
    qreal shapeSmall() const;
    qreal shapeMedium() const;
    qreal shapeLarge() const;
    qreal shapeLargeIncreased() const;
    qreal shapeExtraLarge() const;
    qreal shapeExtraLargeIncreased() const;
    qreal shapeExtraExtraLarge() const;
    qreal space2() const;
    qreal space4() const;
    qreal space8() const;
    qreal space12() const;
    qreal space16() const;
    qreal space24() const;
    qreal space32() const;
    qreal space40() const;
    qreal space48() const;
    qreal iconSizeXS() const;
    qreal iconSizeS() const;
    qreal iconSizeM() const;
    qreal iconSizeL() const;
    qreal iconSizeXL() const;
    qreal buttonHeightXS() const;
    qreal buttonHeightS() const;
    qreal buttonHeightM() const;
    qreal buttonHeightL() const;
    qreal buttonHeightXL() const;
    qreal controlHeight() const;
    qreal controlRadius() const;
    qreal controlPressedRadius() const;
    qreal cardRadius() const;
    qreal dialogRadius() const;
    qreal windowRadius() const;
    qreal focusRingWidth() const;
    qreal iconButtonSizeXS() const;
    qreal iconButtonSizeS() const;
    qreal iconButtonSizeM() const;
    qreal iconButtonSizeL() const;
    qreal iconButtonSizeXL() const;
    qreal stateOpacityHover() const;
    qreal stateOpacityFocus() const;
    qreal stateOpacityPressed() const;
    qreal stateOpacityDragged() const;
};
