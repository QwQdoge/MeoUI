#pragma once

#include <QtCore/QObject>
#include <QtCore/QtGlobal>
#include <QtQml/qqml.h>

#include "meodesigntokens.h"

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
