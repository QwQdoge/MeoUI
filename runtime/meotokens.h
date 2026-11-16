#pragma once

#include <QtCore/QObject>
#include <QtCore/QtGlobal>
#include <QtQml/qqml.h>

#include "meodesigntokens.h"

// Not `final`: QML registration derives QQmlElement<MeoTokens> from this class, which MSVC rejects (C3246) for a final type.
class MeoTokens : public QObject
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
    Q_PROPERTY(qreal sliderTrackHeightXS READ sliderTrackHeightXS CONSTANT)
    Q_PROPERTY(qreal sliderTrackHeightS READ sliderTrackHeightS CONSTANT)
    Q_PROPERTY(qreal sliderTrackHeightM READ sliderTrackHeightM CONSTANT)
    Q_PROPERTY(qreal sliderTrackHeightL READ sliderTrackHeightL CONSTANT)
    Q_PROPERTY(qreal sliderTrackHeightXL READ sliderTrackHeightXL CONSTANT)
    Q_PROPERTY(qreal sliderTrackCornerRadiusXS READ sliderTrackCornerRadiusXS CONSTANT)
    Q_PROPERTY(qreal sliderTrackCornerRadiusS READ sliderTrackCornerRadiusS CONSTANT)
    Q_PROPERTY(qreal sliderTrackCornerRadiusM READ sliderTrackCornerRadiusM CONSTANT)
    Q_PROPERTY(qreal sliderTrackCornerRadiusL READ sliderTrackCornerRadiusL CONSTANT)
    Q_PROPERTY(qreal sliderTrackCornerRadiusXL READ sliderTrackCornerRadiusXL CONSTANT)
    Q_PROPERTY(qreal sliderTrackInsideCornerRadius READ sliderTrackInsideCornerRadius CONSTANT)
    Q_PROPERTY(qreal sliderThumbWidth READ sliderThumbWidth CONSTANT)
    Q_PROPERTY(qreal sliderThumbPressedWidth READ sliderThumbPressedWidth CONSTANT)
    Q_PROPERTY(qreal sliderThumbHeightXS READ sliderThumbHeightXS CONSTANT)
    Q_PROPERTY(qreal sliderThumbHeightS READ sliderThumbHeightS CONSTANT)
    Q_PROPERTY(qreal sliderThumbHeightM READ sliderThumbHeightM CONSTANT)
    Q_PROPERTY(qreal sliderThumbHeightL READ sliderThumbHeightL CONSTANT)
    Q_PROPERTY(qreal sliderThumbHeightXL READ sliderThumbHeightXL CONSTANT)
    Q_PROPERTY(qreal sliderThumbGap READ sliderThumbGap CONSTANT)
    Q_PROPERTY(qreal sliderStopSize READ sliderStopSize CONSTANT)
    Q_PROPERTY(qreal progressTrackThickness READ progressTrackThickness CONSTANT)
    Q_PROPERTY(qreal progressThickStrokeThickness READ progressThickStrokeThickness CONSTANT)
    Q_PROPERTY(qreal progressTrackActiveGap READ progressTrackActiveGap CONSTANT)
    Q_PROPERTY(qreal progressStopSize READ progressStopSize CONSTANT)
    Q_PROPERTY(qreal stateOpacityHover READ stateOpacityHover CONSTANT)
    Q_PROPERTY(qreal stateOpacityFocus READ stateOpacityFocus CONSTANT)
    Q_PROPERTY(qreal stateOpacityPressed READ stateOpacityPressed CONSTANT)
    Q_PROPERTY(qreal stateOpacityDragged READ stateOpacityDragged CONSTANT)
    Q_PROPERTY(qreal motionEffectsDamping READ motionEffectsDamping CONSTANT)
    Q_PROPERTY(qreal motionEffectsStiffness READ motionEffectsStiffness CONSTANT)
    Q_PROPERTY(qreal motionFastSpatialDamping READ motionFastSpatialDamping CONSTANT)
    Q_PROPERTY(qreal motionFastSpatialStiffness READ motionFastSpatialStiffness CONSTANT)
    Q_PROPERTY(qreal motionFastMaximumDuration READ motionFastMaximumDuration CONSTANT)

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
    qreal sliderTrackHeightXS() const;
    qreal sliderTrackHeightS() const;
    qreal sliderTrackHeightM() const;
    qreal sliderTrackHeightL() const;
    qreal sliderTrackHeightXL() const;
    qreal sliderTrackCornerRadiusXS() const;
    qreal sliderTrackCornerRadiusS() const;
    qreal sliderTrackCornerRadiusM() const;
    qreal sliderTrackCornerRadiusL() const;
    qreal sliderTrackCornerRadiusXL() const;
    qreal sliderTrackInsideCornerRadius() const;
    qreal sliderThumbWidth() const;
    qreal sliderThumbPressedWidth() const;
    qreal sliderThumbHeightXS() const;
    qreal sliderThumbHeightS() const;
    qreal sliderThumbHeightM() const;
    qreal sliderThumbHeightL() const;
    qreal sliderThumbHeightXL() const;
    qreal sliderThumbGap() const;
    qreal sliderStopSize() const;
    qreal progressTrackThickness() const;
    qreal progressThickStrokeThickness() const;
    qreal progressTrackActiveGap() const;
    qreal progressStopSize() const;
    qreal stateOpacityHover() const;
    qreal stateOpacityFocus() const;
    qreal stateOpacityPressed() const;
    qreal stateOpacityDragged() const;
    qreal motionEffectsDamping() const;
    qreal motionEffectsStiffness() const;
    qreal motionFastSpatialDamping() const;
    qreal motionFastSpatialStiffness() const;
    qreal motionFastMaximumDuration() const;
};
