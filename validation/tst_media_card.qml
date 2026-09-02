import QtQuick
import QtTest
import "../components" as Components

Item {
    Components.MeoMediaCard {
        id: mediaCard
        title: "Selected card"
        supportingText: "Container foreground"
    }

    TestCase {
        name: "MeoMediaCard"
        when: windowShown

        function test_selectedUsesPrimaryContainerForeground() {
            mediaCard.selected = true
            compare(mediaCard.contentColor, MeoTheme.contentOnPrimaryContainer)
            compare(mediaCard.supportingContentColor, MeoTheme.contentOnPrimaryContainer)
            mediaCard.selected = false
            compare(mediaCard.contentColor, MeoTheme.contentOnSurface)
        }

        function test_horizontalMediaHasHorizontalIntrinsicSize() {
            mediaCard.mediaPosition = "top"
            var verticalWidth = mediaCard.implicitWidth
            mediaCard.mediaPosition = "left"
            verify(mediaCard.implicitWidth > verticalWidth)
        }

        function test_zeroAspectRatioDoesNotProduceInvalidHeight() {
            mediaCard.mediaPosition = "top"
            mediaCard.aspectRatio = 0
            verify(isFinite(mediaCard.implicitHeight))
            mediaCard.aspectRatio = 16 / 9
        }

        function test_mediaSourceLoadsForEveryPlacement() {
            mediaCard.mediaSource = "qrc:/qt/qml/MeoUI/assets/icons/meo-ai-f.svg"

            mediaCard.mediaPosition = "top"
            wait(0)
            var topImage = findChild(mediaCard, "meoMediaCardTopImage")
            verify(topImage !== null)
            compare(topImage.status, Image.Ready)

            mediaCard.mediaPosition = "bottom"
            wait(0)
            var bottomImage = findChild(mediaCard, "meoMediaCardBottomImage")
            verify(bottomImage !== null)
            compare(bottomImage.status, Image.Ready)

            mediaCard.mediaPosition = "left"
            wait(0)
            var leftImage = findChild(mediaCard, "meoMediaCardLeftImage")
            verify(leftImage !== null)
            compare(leftImage.status, Image.Ready)

            mediaCard.mediaPosition = "right"
            wait(0)
            var rightImage = findChild(mediaCard, "meoMediaCardRightImage")
            verify(rightImage !== null)
            compare(rightImage.status, Image.Ready)
            mediaCard.mediaSource = ""
        }
    }
}
