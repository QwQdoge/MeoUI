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
    static constexpr qreal buttonHeightM() { return 48.0; }
    static constexpr qreal buttonHeightL() { return 56.0; }
    static constexpr qreal buttonHeightXL() { return 72.0; }

    static constexpr qreal stateOpacityHover() { return 0.10; }
    static constexpr qreal stateOpacityFocus() { return 0.12; }
    static constexpr qreal stateOpacityPressed() { return 0.14; }
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
    qreal stateOpacityHover() const;
    qreal stateOpacityFocus() const;
    qreal stateOpacityPressed() const;
    qreal stateOpacityDragged() const;
};
