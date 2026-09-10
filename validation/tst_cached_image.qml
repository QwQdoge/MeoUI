import QtQuick
import QtTest
import MeoUI 1.0

Item {
    width: 160
    height: 120

    MeoCachedImage {
        id: image
        width: 96
        height: 72
        source: "qrc:/qt/qml/MeoUI/assets/icons/meo-ai-f.svg"
        requestedSourceWidth: 48
        requestedSourceHeight: 36
    }

    TestCase {
        name: "MeoCachedImage"
        when: windowShown

        function init() {
            image.active = true
        }

        function test_asyncSizingAndCacheContract() {
            compare(image.cache, true)
            compare(image.requestedSourceWidth, 48)
            compare(image.requestedSourceHeight, 36)
            verify(image.loading || image.ready)
            tryCompare(image, "ready", true, 1000)
        }

        function test_inactiveClearsTheDecodeSource() {
            image.active = false
            tryCompare(image, "status", Image.Null, 1000)
            compare(image.loading, false)
            compare(image.ready, false)
        }

        function test_animatedArtworkIsOptIn() {
            compare(image.allowAnimation, false)
            image.allowAnimation = true
            compare(image.allowAnimation, true)
        }
    }
}
