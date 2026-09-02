import QtQuick
import QtTest
import "../components" as Components
import "../components/MeoMaterialShapes.js" as Shapes

Item {
    width: 200
    height: 200

    Components.MeoShapeMorph {
        id: morph
        width: 96
        height: 96
        fromShape: "soft burst"
        toShape: "cookie 9 sided"
        color: "#65558F"
        strokeColor: "#1D1B20"
        strokeWidth: 2
    }

    TestCase {
        name: "MeoShapeMorph"
        when: windowShown

        function init() {
            morph.morphProgress = 0
            morph.rawSpringProgress = 0
        }

        function test_topologyProgressAndSpringAreBounded() {
            morph.morphProgress = -3
            compare(morph.morphProgress, -3)
            // The drawing path clamps independently; callers retain their raw
            // progress value for a spring controller.
            const canvas = findChild(morph, "meoShapeMorphCanvas")
            verify(canvas !== null)
            morph.rawSpringProgress = -8
            compare(morph.clampedRawSpringProgress, -1)
            if (!morph.reduceMotion)
                compare(canvas.scale, 0.92)
            morph.rawSpringProgress = 8
            compare(morph.clampedRawSpringProgress, 2)
            if (!morph.reduceMotion)
                compare(canvas.scale, 1.12)
        }

        function test_shapeNamesAndStrokeContract() {
            // tst_material_shapes verifies shared geometry; this test keeps
            // the morph primitive's source/target and stroke inputs intact.
            compare(morph.fromShape, "soft burst")
            compare(morph.toShape, "cookie 9 sided")
            verify(morph.strokeWidth > 0)
        }

        function test_highDensityMorphKeepsEndpointsAndInterpolatesMidpoint() {
            const start = Shapes.interpolateShapes("SoftBurst", "Pill", 0)
            const midpoint = Shapes.interpolateShapes("SoftBurst", "Pill", 0.5)
            const end = Shapes.interpolateShapes("SoftBurst", "Pill", 1)
            compare(start.length, 144)
            compare(midpoint.length, start.length)
            compare(end.length, start.length)

            for (let index = 0; index < start.length; ++index) {
                verify(midpoint[index].x >= 0 && midpoint[index].x <= 1)
                verify(midpoint[index].y >= 0 && midpoint[index].y <= 1)
            }
        }

        function test_circleToSquareMidpointDoesNotCollapseFromMismatchedStarts() {
            const midpoint = Shapes.interpolateShapes("Circle", "Square", 0.5)
            let minX = 1
            let maxX = 0
            let minY = 1
            let maxY = 0
            for (let index = 0; index < midpoint.length; ++index) {
                minX = Math.min(minX, midpoint[index].x)
                maxX = Math.max(maxX, midpoint[index].x)
                minY = Math.min(minY, midpoint[index].y)
                maxY = Math.max(maxY, midpoint[index].y)
            }
            verify(maxX - minX > 0.8)
            verify(maxY - minY > 0.8)
        }
    }
}
