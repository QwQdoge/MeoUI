#include "meotokens.h"

#include <QtQml/QQmlEngine>

MeoTokens::MeoTokens(QObject *parent)
    : QObject(parent)
{
}

MeoTokens *MeoTokens::create(QQmlEngine *engine, QJSEngine *)
{
    return new MeoTokens(engine);
}

#define MEO_TOKEN_ACCESSOR(name) \
    qreal MeoTokens::name() const { return Meo::DesignTokens::name(); }

MEO_TOKEN_ACCESSOR(shapeExtraSmall)
MEO_TOKEN_ACCESSOR(shapeSmall)
MEO_TOKEN_ACCESSOR(shapeMedium)
MEO_TOKEN_ACCESSOR(shapeLarge)
MEO_TOKEN_ACCESSOR(shapeLargeIncreased)
MEO_TOKEN_ACCESSOR(shapeExtraLarge)
MEO_TOKEN_ACCESSOR(shapeExtraLargeIncreased)
MEO_TOKEN_ACCESSOR(shapeExtraExtraLarge)
MEO_TOKEN_ACCESSOR(space2)
MEO_TOKEN_ACCESSOR(space4)
MEO_TOKEN_ACCESSOR(space8)
MEO_TOKEN_ACCESSOR(space12)
MEO_TOKEN_ACCESSOR(space16)
MEO_TOKEN_ACCESSOR(space24)
MEO_TOKEN_ACCESSOR(space32)
MEO_TOKEN_ACCESSOR(space40)
MEO_TOKEN_ACCESSOR(space48)
MEO_TOKEN_ACCESSOR(iconSizeXS)
MEO_TOKEN_ACCESSOR(iconSizeS)
MEO_TOKEN_ACCESSOR(iconSizeM)
MEO_TOKEN_ACCESSOR(iconSizeL)
MEO_TOKEN_ACCESSOR(iconSizeXL)
MEO_TOKEN_ACCESSOR(buttonHeightXS)
MEO_TOKEN_ACCESSOR(buttonHeightS)
MEO_TOKEN_ACCESSOR(buttonHeightM)
MEO_TOKEN_ACCESSOR(buttonHeightL)
MEO_TOKEN_ACCESSOR(buttonHeightXL)
MEO_TOKEN_ACCESSOR(stateOpacityHover)
MEO_TOKEN_ACCESSOR(stateOpacityFocus)
MEO_TOKEN_ACCESSOR(stateOpacityPressed)
MEO_TOKEN_ACCESSOR(stateOpacityDragged)

#undef MEO_TOKEN_ACCESSOR
