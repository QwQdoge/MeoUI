import QtQuick
import QtTest
import "../components" as Components

Item {
    Components.MeoRatingBar { id: ratingBar; maxRating: 5 }

    TestCase {
        name: "MeoRatingBar"
        when: windowShown

        function test_externalRatingAndMaximumAreBounded() {
            ratingBar.rating = 7
            compare(ratingBar.rating, 5)
            ratingBar.rating = -1
            compare(ratingBar.rating, 0)
            ratingBar.maxRating = 0
            compare(ratingBar.maxRating, 1)
        }

        function test_productRatingContractSupportsHalfStepsAndKeyboardBounds() {
            ratingBar.maxRating = 5
            ratingBar.rating = 2
            compare(ratingBar.ratingForPosition(2, 8, 32), 2.5)
            compare(ratingBar.ratingForPosition(2, 24, 32), 3)
            ratingBar.setRatingFromUser(2.5)
            compare(ratingBar.rating, 2.5)
            ratingBar.adjustRating(1)
            compare(ratingBar.rating, 3)
            ratingBar.adjustRating(-9)
            compare(ratingBar.rating, 0)
            verify(ratingBar.Accessible.description.indexOf("5") !== -1)
        }
    }
}
