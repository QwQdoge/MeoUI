import QtQuick
import QtTest
import "../components/MeoMaterialShapes.js" as Shapes

Item {
    TestCase {
        name: "MeoMaterialShapes"
        when: windowShown

        function verifyNormalized(points) {
            compare(points.length, 144)
            for (let index = 0; index < points.length; ++index) {
                verify(isFinite(points[index].x))
                verify(isFinite(points[index].y))
                verify(points[index].x >= 0 && points[index].x <= 1)
                verify(points[index].y >= 0 && points[index].y <= 1)
            }
        }

        function bounds(points) {
            let minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity
            for (let index = 0; index < points.length; ++index) {
                minX = Math.min(minX, points[index].x)
                minY = Math.min(minY, points[index].y)
                maxX = Math.max(maxX, points[index].x)
                maxY = Math.max(maxY, points[index].y)
            }
            return { width: maxX - minX, height: maxY - minY }
        }

        function test_completeMaterialCatalogResolvesToNormalizedGeometry() {
            const catalog = Shapes.materialShapeCatalog()
            compare(catalog.length, 35)

            const names = new Set()
            for (let index = 0; index < catalog.length; ++index) {
                const shape = catalog[index]
                verify(shape.name.length > 0)
                verify(shape.label.length > 0)
                verify(!names.has(shape.name))
                names.add(shape.name)
                compare(Shapes.canonicalShapeName(shape.label), shape.name)
                verify(Shapes.isMaterialShape(shape.name))
                verifyNormalized(Shapes.getNormalizedPathPoints(shape.name))
            }

            verify(!Shapes.isMaterialShape("hexagon"))
            verify(!Shapes.isMaterialShape("octagon"))
        }

        function test_authoredAndSemanticNamesShareTheSamePath() {
            const aliases = [
                ["soft burst", "SoftBurst"],
                ["4-sided cookie", "Cookie4Sided"],
                ["8 leaf clover", "Clover8Leaf"],
                ["ghost-ish", "Ghostish"],
                ["semi circle", "SemiCircle"]
            ]

            for (let aliasIndex = 0; aliasIndex < aliases.length; ++aliasIndex) {
                const semantic = Shapes.getNormalizedPathPoints(aliases[aliasIndex][0])
                const authored = Shapes.getNormalizedPathPoints(aliases[aliasIndex][1])
                compare(semantic.length, authored.length)
                for (let index = 0; index < semantic.length; ++index) {
                    compare(semantic[index].x, authored[index].x)
                    compare(semantic[index].y, authored[index].y)
                }
            }
        }

        function test_androidxGeometryProvenanceAndAspectPreservation() {
            compare(Shapes.ANDROIDX_MATERIAL_SHAPES_REVISION,
                    "bf48f4c018c001f2b10baab00a2710ab283fed0f")

            // AndroidX normalizes against the longer side and centers the
            // shorter side; it does not stretch authored geometry to fill the
            // square as the earlier approximation did.
            const semiCircleBounds = bounds(Shapes.getNormalizedPathPoints("SemiCircle"))
            verify(semiCircleBounds.width > semiCircleBounds.height)
            verify(semiCircleBounds.height > 0.55)

            const clamShellBounds = bounds(Shapes.getNormalizedPathPoints("ClamShell"))
            verify(clamShellBounds.width > clamShellBounds.height)

            // Smooth roundings and hard pixel steps both remain representable
            // in the shared 144-point topology.
            const softBurst = Shapes.getNormalizedPathPoints("SoftBurst")
            const pixelCircle = Shapes.getNormalizedPathPoints("PixelCircle")
            verify(softBurst.some(point => point.x > 0.99 || point.y > 0.99))
            verify(pixelCircle.some(point => Math.abs(point.x - 0.5) < 0.001))
        }
    }
}
