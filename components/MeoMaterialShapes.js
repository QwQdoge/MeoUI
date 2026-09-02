.pragma library

// 🌟 Material 3 Expressive (M3E) 35 Geometry Generator & Morph Engine
// All shapes operate in normalized [0,1] x [0,1] space.

var shapeCache = {};
var morphTopologyCache = {};

// The authored Material 3 Expressive catalogue.  Keep this as data instead
// of a Showcase-only list: components, tests, and documentation all need the
// same 35 names and labels.  The legacy Hexagon and Octagon aliases below are
// intentionally not part of this catalogue.
var MATERIAL_SHAPE_CATALOG = [
    { name: "Circle", label: "Circle" },
    { name: "Square", label: "Square" },
    { name: "Slanted", label: "Slanted" },
    { name: "Arch", label: "Arch" },
    { name: "SemiCircle", label: "Semicircle" },
    { name: "Oval", label: "Oval" },
    { name: "Pill", label: "Pill" },
    { name: "Triangle", label: "Triangle" },
    { name: "Arrow", label: "Arrow" },
    { name: "Fan", label: "Fan" },
    { name: "Diamond", label: "Diamond" },
    { name: "ClamShell", label: "Clamshell" },
    { name: "Pentagon", label: "Pentagon" },
    { name: "Gem", label: "Gem" },
    { name: "VerySunny", label: "Very sunny" },
    { name: "Sunny", label: "Sunny" },
    { name: "Cookie4Sided", label: "4-sided cookie" },
    { name: "Cookie6Sided", label: "6-sided cookie" },
    { name: "Cookie7Sided", label: "7-sided cookie" },
    { name: "Cookie9Sided", label: "9-sided cookie" },
    { name: "Cookie12Sided", label: "12-sided cookie" },
    { name: "Clover4Leaf", label: "4-leaf clover" },
    { name: "Clover8Leaf", label: "8-leaf clover" },
    { name: "Burst", label: "Burst" },
    { name: "SoftBurst", label: "Soft burst" },
    { name: "Boom", label: "Boom" },
    { name: "SoftBoom", label: "Soft boom" },
    { name: "Flower", label: "Flower" },
    { name: "Puffy", label: "Puffy" },
    { name: "PuffyDiamond", label: "Puffy diamond" },
    { name: "Ghostish", label: "Ghost-ish" },
    { name: "PixelCircle", label: "Pixel circle" },
    { name: "PixelTriangle", label: "Pixel triangle" },
    { name: "Bun", label: "Bun" },
    { name: "Heart", label: "Heart" }
];

function materialShapeCatalog() {
    // Return copies so a QML consumer cannot accidentally mutate our
    // canonical data for later consumers in the same engine.
    return MATERIAL_SHAPE_CATALOG.map(function(shape) {
        return { name: shape.name, label: shape.label };
    });
}

function isMaterialShape(shapeName) {
    var canonical = canonicalShapeName(shapeName);
    return MATERIAL_SHAPE_CATALOG.some(function(shape) {
        return shape.name === canonical;
    });
}

// Public QML uses lower-case semantic names while the expressive geometry
// catalogue retains Material's authored names.  Canonicalise at the engine
// boundary so `hexagon`, `diamond`, and `octagon` do not silently fall back to
// a circle just because their case differs.
function canonicalShapeName(shapeName) {
    var key = String(shapeName || "").replace(/[ _-]/g, "").toLowerCase();
    var aliases = {
        "circle": "Circle",
        "square": "Square",
        "slanted": "Slanted",
        "arch": "Arch",
        "fan": "Fan",
        "arrow": "Arrow",
        "semicircle": "SemiCircle",
        "oval": "Oval",
        "pill": "Pill",
        "triangle": "Triangle",
        "diamond": "Diamond",
        "pentagon": "Pentagon",
        "hexagon": "Hexagon",
        "octagon": "Octagon",
        "gem": "Gem",
        "verysunny": "VerySunny",
        "sunny": "Sunny",
        "cookie4sided": "Cookie4Sided",
        "4sidedcookie": "Cookie4Sided",
        "cookie6sided": "Cookie6Sided",
        "6sidedcookie": "Cookie6Sided",
        "cookie7sided": "Cookie7Sided",
        "7sidedcookie": "Cookie7Sided",
        "cookie9sided": "Cookie9Sided",
        "9sidedcookie": "Cookie9Sided",
        "cookie12sided": "Cookie12Sided",
        "12sidedcookie": "Cookie12Sided",
        "clover4leaf": "Clover4Leaf",
        "4leafclover": "Clover4Leaf",
        "clover8leaf": "Clover8Leaf",
        "8leafclover": "Clover8Leaf",
        "burst": "Burst",
        "softburst": "SoftBurst",
        "boom": "Boom",
        "softboom": "SoftBoom",
        "flower": "Flower",
        "clamshell": "ClamShell",
        "ghostish": "Ghostish",
        "puffy": "Puffy",
        "puffydiamond": "PuffyDiamond",
        "pixelcircle": "PixelCircle",
        "pixeltriangle": "PixelTriangle",
        "bun": "Bun",
        "heart": "Heart"
    };
    return aliases[key] || shapeName;
}

// Helper: Normalize points to [0,1] box
function normalizePoints(points) {
    let minX = Infinity, maxX = -Infinity, minY = Infinity, maxY = -Infinity;
    for (let p of points) {
        if (p.x < minX) minX = p.x;
        if (p.x > maxX) maxX = p.x;
        if (p.y < minY) minY = p.y;
        if (p.y > maxY) maxY = p.y;
    }
    let rangeX = Math.max(0.0001, maxX - minX);
    let rangeY = Math.max(0.0001, maxY - minY);
    return points.map(p => ({
        x: (p.x - minX) / rangeX,
        y: (p.y - minY) / rangeY
    }));
}

// AndroidX MaterialShapes describes its basic expressive shapes as rounded
// polygons (Apache-2.0, MaterialShapes.kt).  Sample that geometry into the
// shared 144-point topology used by the Canvas renderer and morph engine.
// This avoids the earlier superellipse/pointy-polygon substitutes while
// keeping one stable topology for interpolation.
function roundedPolygonPoints(vertices, roundings, count) {
    let sampled = [];
    for (let index = 0; index < vertices.length; ++index) {
        let previous = vertices[(index - 1 + vertices.length) % vertices.length];
        let vertex = vertices[index];
        let next = vertices[(index + 1) % vertices.length];
        let rounding = Array.isArray(roundings) ? roundings[index] : roundings;
        rounding = Math.max(0, Math.min(1, rounding || 0));
        if (rounding === 0) {
            sampled.push({ x: vertex.x, y: vertex.y });
            continue;
        }

        let previousLength = Math.hypot(previous.x - vertex.x, previous.y - vertex.y);
        let nextLength = Math.hypot(next.x - vertex.x, next.y - vertex.y);
        // Material's rounding radius is bounded by both adjoining edges.
        let cut = Math.min(previousLength, nextLength) * Math.min(0.45, rounding);
        let before = {
            x: vertex.x + (previous.x - vertex.x) * cut / previousLength,
            y: vertex.y + (previous.y - vertex.y) * cut / previousLength
        };
        let after = {
            x: vertex.x + (next.x - vertex.x) * cut / nextLength,
            y: vertex.y + (next.y - vertex.y) * cut / nextLength
        };
        for (let step = 0; step <= 8; ++step) {
            let t = step / 8;
            let inverse = 1 - t;
            sampled.push({
                x: inverse * inverse * before.x + 2 * inverse * t * vertex.x + t * t * after.x,
                y: inverse * inverse * before.y + 2 * inverse * t * vertex.y + t * t * after.y
            });
        }
    }
    return resampleClosedPoints(sampled, count);
}

function resampleClosedPoints(points, count) {
    let distances = [0];
    let perimeter = 0;
    for (let index = 0; index < points.length; ++index) {
        let next = points[(index + 1) % points.length];
        perimeter += Math.hypot(next.x - points[index].x, next.y - points[index].y);
        distances.push(perimeter);
    }
    let result = [];
    for (let sample = 0; sample < count; ++sample) {
        let target = perimeter * sample / count;
        let segment = 0;
        while (segment < points.length - 1 && distances[segment + 1] < target)
            ++segment;
        let start = points[segment];
        let end = points[(segment + 1) % points.length];
        let length = distances[segment + 1] - distances[segment];
        let local = length > 0 ? (target - distances[segment]) / length : 0;
        result.push({ x: start.x + (end.x - start.x) * local,
                      y: start.y + (end.y - start.y) * local });
    }
    return result;
}

function regularPolygonVertices(sides, rotationRadians, scaleX, scaleY) {
    let vertices = [];
    for (let index = 0; index < sides; ++index) {
        let angle = rotationRadians + index * 2 * Math.PI / sides;
        vertices.push({ x: 0.5 + 0.5 * (scaleX || 1) * Math.cos(angle),
                        y: 0.5 + 0.5 * (scaleY || 1) * Math.sin(angle) });
    }
    return vertices;
}

// AndroidX graphics-shapes uses radius plus smoothing at every corner, rather
// than a generic bezier through the vertex.  The following is an independent
// JavaScript adaptation of that construction.  Provenance and the required
// Apache-2.0 notice are recorded in THIRD_PARTY_NOTICES.md.
var ANDROIDX_MATERIAL_SHAPES_REVISION = "9df4d001962d58aabca222967b8ceb1789acb960";

function point(x, y) { return { x: x, y: y }; }
function sub(a, b) { return point(a.x - b.x, a.y - b.y); }
function add(a, b) { return point(a.x + b.x, a.y + b.y); }
function mul(a, n) { return point(a.x * n, a.y * n); }
function length(a) { return Math.hypot(a.x, a.y); }
function unit(a) { var l = length(a); return l > 1e-6 ? mul(a, 1 / l) : point(0, 0); }
function dot(a, b) { return a.x * b.x + a.y * b.y; }
function cross(a, b) { return a.x * b.y - a.y * b.x; }
function rotate(a, radians) {
    var c = Math.cos(radians), s = Math.sin(radians);
    return point(a.x * c - a.y * s, a.x * s + a.y * c);
}
function lerp(a, b, t) { return point(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t); }
function rounding(radius, smoothing) { return { radius: radius || 0, smoothing: smoothing || 0 }; }

function sampleCubic(curve, steps, output, skipFirst) {
    for (var i = skipFirst ? 1 : 0; i <= steps; ++i) {
        var t = i / steps, u = 1 - t;
        output.push(point(
            u * u * u * curve.a.x + 3 * u * u * t * curve.c1.x + 3 * u * t * t * curve.c2.x + t * t * t * curve.b.x,
            u * u * u * curve.a.y + 3 * u * u * t * curve.c1.y + 3 * u * t * t * curve.c2.y + t * t * t * curve.b.y
        ));
    }
}

function lineIntersection(p0, d0, p1, d1) {
    var rotatedD1 = point(-d1.y, d1.x);
    var denominator = dot(d0, rotatedD1);
    var numerator = dot(sub(p1, p0), rotatedD1);
    if (Math.abs(denominator) < 1e-5 || Math.abs(denominator) < 1e-5 * Math.abs(numerator))
        return null;
    return add(p0, mul(d0, numerator / denominator));
}

function materialFlanking(actualRoundCut, smoothing, corner, sideStart, circleStart, circleEnd, center, actualRadius) {
    var sideDirection = unit(sub(sideStart, corner));
    var curveStart = add(corner, mul(sideDirection, actualRoundCut * (1 + smoothing)));
    var midpoint = mul(add(circleStart, circleEnd), 0.5);
    var p = lerp(circleStart, midpoint, smoothing);
    var curveEnd = add(center, mul(unit(sub(p, center)), actualRadius));
    var tangent = rotate(sub(curveEnd, center), Math.PI / 2);
    var anchorEnd = lineIntersection(sideStart, sideDirection, curveEnd, tangent) || circleStart;
    return { a: curveStart, c1: mul(add(curveStart, mul(anchorEnd, 2)), 1 / 3), c2: anchorEnd, b: curveEnd };
}

function reverseCurve(curve) { return { a: curve.b, c1: curve.c2, c2: curve.c1, b: curve.a }; }

function materialRoundedPolygon(vertices, roundings, sampleCount) {
    var n = vertices.length;
    var corners = [];
    for (var i = 0; i < n; ++i) {
        var previous = vertices[(i + n - 1) % n];
        var vertex = vertices[i];
        var next = vertices[(i + 1) % n];
        var d1 = unit(sub(previous, vertex));
        var d2 = unit(sub(next, vertex));
        var cosine = dot(d1, d2);
        var sine = Math.sqrt(Math.max(0, 1 - cosine * cosine));
        var r = roundings[i] || rounding(0, 0);
        var roundCut = sine > 1e-3 ? r.radius * (cosine + 1) / sine : 0;
        corners.push({ previous: previous, vertex: vertex, next: next, d1: d1, d2: d2,
                       radius: r.radius, smoothing: r.smoothing, roundCut: roundCut,
                       cut: (1 + r.smoothing) * roundCut });
    }
    var adjustments = [];
    for (var side = 0; side < n; ++side) {
        var thisCorner = corners[side], nextCorner = corners[(side + 1) % n];
        var available = length(sub(vertices[(side + 1) % n], vertices[side]));
        var expectedRound = thisCorner.roundCut + nextCorner.roundCut;
        var expected = thisCorner.cut + nextCorner.cut;
        if (expectedRound > available && expectedRound > 0)
            adjustments.push([available / expectedRound, 0]);
        else if (expected > available && expected > expectedRound)
            adjustments.push([1, (available - expectedRound) / (expected - expectedRound)]);
        else
            adjustments.push([1, 1]);
    }
    var outline = [];
    for (var index = 0; index < n; ++index) {
        var corner = corners[index];
        var beforeAdjust = adjustments[(index + n - 1) % n];
        var afterAdjust = adjustments[index];
        var allowed0 = corner.roundCut * beforeAdjust[0] + (corner.cut - corner.roundCut) * beforeAdjust[1];
        var allowed1 = corner.roundCut * afterAdjust[0] + (corner.cut - corner.roundCut) * afterAdjust[1];
        var allowed = Math.min(allowed0, allowed1);
        if (corner.roundCut < 1e-5 || allowed < 1e-5 || corner.radius < 1e-5) {
            outline.push(corner.vertex);
            continue;
        }
        var actualRoundCut = Math.min(allowed, corner.roundCut);
        var smoothing0 = allowed0 > corner.cut ? corner.smoothing : (allowed0 > corner.roundCut && corner.cut > corner.roundCut ? corner.smoothing * (allowed0 - corner.roundCut) / (corner.cut - corner.roundCut) : 0);
        var smoothing1 = allowed1 > corner.cut ? corner.smoothing : (allowed1 > corner.roundCut && corner.cut > corner.roundCut ? corner.smoothing * (allowed1 - corner.roundCut) / (corner.cut - corner.roundCut) : 0);
        var actualRadius = corner.radius * actualRoundCut / corner.roundCut;
        var centerDistance = Math.sqrt(actualRadius * actualRadius + actualRoundCut * actualRoundCut);
        var center = add(corner.vertex, mul(unit(mul(add(corner.d1, corner.d2), 0.5)), centerDistance));
        var intersection0 = add(corner.vertex, mul(corner.d1, actualRoundCut));
        var intersection2 = add(corner.vertex, mul(corner.d2, actualRoundCut));
        var flank0 = materialFlanking(actualRoundCut, smoothing0, corner.vertex, corner.previous, intersection0, intersection2, center, actualRadius);
        var flank2 = reverseCurve(materialFlanking(actualRoundCut, smoothing1, corner.vertex, corner.next, intersection2, intersection0, center, actualRadius));
        sampleCubic(flank0, 4, outline, outline.length > 0);
        var startVector = sub(flank0.b, center), endVector = sub(flank2.a, center);
        var startAngle = Math.atan2(startVector.y, startVector.x);
        var endAngle = Math.atan2(endVector.y, endVector.x);
        var delta = endAngle - startAngle;
        if (cross(startVector, endVector) >= 0 && delta < 0) delta += 2 * Math.PI;
        if (cross(startVector, endVector) < 0 && delta > 0) delta -= 2 * Math.PI;
        for (var step = 1; step <= 4; ++step) {
            var angle = startAngle + delta * step / 4;
            outline.push(point(center.x + actualRadius * Math.cos(angle), center.y + actualRadius * Math.sin(angle)));
        }
        sampleCubic(flank2, 4, outline, true);
    }
    return resampleClosedPoints(outline, sampleCount);
}

function materialNormalize(points) {
    var minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity;
    for (var i = 0; i < points.length; ++i) {
        minX = Math.min(minX, points[i].x); minY = Math.min(minY, points[i].y);
        maxX = Math.max(maxX, points[i].x); maxY = Math.max(maxY, points[i].y);
    }
    var width = maxX - minX, height = maxY - minY, side = Math.max(width, height, 1e-5);
    var offsetX = (side - width) / 2 - minX, offsetY = (side - height) / 2 - minY;
    return points.map(function(p) { return point((p.x + offsetX) / side, (p.y + offsetY) / side); });
}

function materialRepeat(points, reps, mirrored, center) {
    center = center || point(0.5, 0.5);
    var result = [];
    if (!mirrored) {
        for (var i = 0; i < points.length * reps; ++i) {
            var source = points[i % points.length];
            var offset = rotate(sub(source.p, center), Math.PI * 2 * Math.floor(i / points.length) / reps);
            result.push({ p: add(offset, center), r: source.r });
        }
        return result;
    }
    var angles = points.map(function(v) { return Math.atan2(v.p.y - center.y, v.p.x - center.x); });
    var distances = points.map(function(v) { return length(sub(v.p, center)); });
    var actualReps = reps * 2, section = Math.PI * 2 / actualReps;
    for (var repeat = 0; repeat < actualReps; ++repeat) {
        for (var index = 0; index < points.length; ++index) {
            var sourceIndex = repeat % 2 === 0 ? index : points.length - 1 - index;
            if (sourceIndex === 0 && repeat % 2 !== 0) continue;
            var angle = section * repeat + (repeat % 2 === 0 ? angles[sourceIndex] : section - angles[sourceIndex] + 2 * angles[0]);
            result.push({ p: add(center, point(Math.cos(angle) * distances[sourceIndex], Math.sin(angle) * distances[sourceIndex])), r: points[sourceIndex].r });
        }
    }
    return result;
}

function materialPoint(x, y, radius, smoothing) { return { p: point(x, y), r: rounding(radius, smoothing) }; }
function materialRegular(sides, radius, vertexRounding) {
    var vertices = [], roundings = [];
    for (var i = 0; i < sides; ++i) {
        var angle = Math.PI * 2 * i / sides;
        vertices.push(point(Math.cos(angle) * radius, Math.sin(angle) * radius));
        roundings.push(vertexRounding instanceof Array ? vertexRounding[i] : vertexRounding);
    }
    return { vertices: vertices, roundings: roundings };
}
function materialStar(verticesPerRadius, innerRadius, vertexRounding) {
    var vertices = [], roundings = [];
    for (var i = 0; i < verticesPerRadius * 2; ++i) {
        var angle = Math.PI * i / verticesPerRadius;
        var radius = i % 2 === 0 ? 1 : innerRadius;
        vertices.push(point(Math.cos(angle) * radius, Math.sin(angle) * radius));
        roundings.push(vertexRounding);
    }
    return { vertices: vertices, roundings: roundings };
}
function transformMaterialPoints(points, transform) {
    if (!transform) return points;
    var sx = transform.sx === undefined ? 1 : transform.sx;
    var sy = transform.sy === undefined ? 1 : transform.sy;
    var rotation = transform.rotation || 0;
    return points.map(function(p) { return rotate(point(p.x * sx, p.y * sy), rotation); });
}

// These descriptors are the MaterialShapes.kt catalogue data, represented in
// MeoUI's own vector model.  They intentionally remain geometry, not copied
// bitmap assets.  See THIRD_PARTY_NOTICES.md for source and license.
function materialShapePoints(shapeName, count) {
    var definition;
    var R15 = rounding(.15), R20 = rounding(.2), R30 = rounding(.3), R50 = rounding(.5), R100 = rounding(1);
    switch (shapeName) {
    case "Circle":
        var circle = [];
        for (var ci = 0; ci < count; ++ci) circle.push(point(.5 + .5 * Math.cos(Math.PI * 2 * ci / count), .5 + .5 * Math.sin(Math.PI * 2 * ci / count)));
        return circle;
    case "Square": definition = { points: [materialPoint(-.5,-.5,.3), materialPoint(.5,-.5,.3), materialPoint(.5,.5,.3), materialPoint(-.5,.5,.3)] }; break;
    case "Slanted": definition = { points: [materialPoint(.926,.970,.189,.811), materialPoint(-.021,.967,.187,.057)], reps: 2 }; break;
    case "Arch":
        var arch = materialRegular(4, 1, [R100, R100, R20, R20]);
        definition = { vertices: arch.vertices, roundings: arch.roundings, transform: { rotation: -3 * Math.PI / 4 } }; break;
    case "Fan": definition = { points: [materialPoint(1.004,1,.148,.417), materialPoint(0,1,.151), materialPoint(0,-.003,.148), materialPoint(.978,.020,.803)] }; break;
    case "Arrow": definition = { points: [materialPoint(.5,.892,.313), materialPoint(-.216,1.05,.207), materialPoint(.499,-.160,.215,1), materialPoint(1.225,1.06,.211)] }; break;
    case "SemiCircle": definition = { points: [materialPoint(-.8,-.5,.2), materialPoint(.8,-.5,.2), materialPoint(.8,.5,1), materialPoint(-.8,.5,1)] }; break;
    case "Oval":
        var oval = materialRegular(10, 1, R100);
        definition = { vertices: oval.vertices, roundings: oval.roundings, transform: { sx: 1, sy: .64, rotation: -Math.PI / 4 } }; break;
    case "Pill": definition = { points: [materialPoint(.961,.039,.426), materialPoint(1.001,.428), materialPoint(1,.609,1)], reps: 2, mirrored: true }; break;
    case "Triangle":
        var triangle = materialRegular(3, 1, R20);
        definition = { vertices: triangle.vertices, roundings: triangle.roundings, transform: { rotation: -Math.PI / 2 } }; break;
    case "Diamond": definition = { points: [materialPoint(.5,1.096,.151,.524), materialPoint(.04,.5,.159)], reps: 2 }; break;
    case "ClamShell": definition = { points: [materialPoint(.171,.841,.159), materialPoint(-.02,.5,.140), materialPoint(.17,.159,.159)], reps: 2 }; break;
    case "Pentagon": definition = { points: [materialPoint(.5,-.009,.172), materialPoint(1.03,.365,.164), materialPoint(.828,.97,.169)], reps: 1, mirrored: true }; break;
    case "Gem": definition = { points: [materialPoint(.499,1.023,.241,.778), materialPoint(-.005,.792,.208), materialPoint(.073,.258,.228), materialPoint(.433,0,.491)], reps: 1, mirrored: true }; break;
    case "Sunny":
        var sunny = materialStar(8, .8, R15);
        definition = { vertices: sunny.vertices, roundings: sunny.roundings }; break;
    case "VerySunny": definition = { points: [materialPoint(.5,1.08,.085), materialPoint(.358,.843,.085)], reps: 8 }; break;
    case "Cookie4Sided": definition = { points: [materialPoint(1.237,1.236,.258), materialPoint(.5,.918,.233)], reps: 4 }; break;
    case "Cookie6Sided": definition = { points: [materialPoint(.723,.884,.394), materialPoint(.5,1.099,.398)], reps: 6 }; break;
    case "Cookie7Sided":
        var cookie7 = materialStar(7, .75, R50);
        definition = { vertices: cookie7.vertices, roundings: cookie7.roundings, transform: { rotation: -Math.PI / 2 } }; break;
    case "Cookie9Sided":
        var cookie9 = materialStar(9, .8, R50);
        definition = { vertices: cookie9.vertices, roundings: cookie9.roundings, transform: { rotation: -Math.PI / 2 } }; break;
    case "Cookie12Sided":
        var cookie12 = materialStar(12, .8, R50);
        definition = { vertices: cookie12.vertices, roundings: cookie12.roundings, transform: { rotation: -Math.PI / 2 } }; break;
    case "Ghostish": definition = { points: [materialPoint(.5,0,1), materialPoint(1,0,1), materialPoint(1,1.14,.254,.106), materialPoint(.575,.906,.253)], reps: 1, mirrored: true }; break;
    case "Clover4Leaf": definition = { points: [materialPoint(.5,.074), materialPoint(.725,-.099,.476)], reps: 4, mirrored: true }; break;
    case "Clover8Leaf": definition = { points: [materialPoint(.5,.036), materialPoint(.758,-.101,.209)], reps: 8 }; break;
    case "Burst": definition = { points: [materialPoint(.5,-.006,.006), materialPoint(.592,.158,.006)], reps: 12 }; break;
    case "SoftBurst": definition = { points: [materialPoint(.193,.277,.053), materialPoint(.176,.055,.053)], reps: 10 }; break;
    case "Boom": definition = { points: [materialPoint(.457,.296,.007), materialPoint(.5,-.051,.007)], reps: 15 }; break;
    case "SoftBoom": definition = { points: [materialPoint(.733,.454), materialPoint(.839,.437,.532), materialPoint(.949,.449,.439,1), materialPoint(.998,.478,.174)], reps: 16, mirrored: true }; break;
    case "Flower": definition = { points: [materialPoint(.370,.187), materialPoint(.416,.049,.381), materialPoint(.479,.001,.095)], reps: 8, mirrored: true }; break;
    case "Puffy": definition = { points: [materialPoint(.5,.053), materialPoint(.545,-.04,.405), materialPoint(.67,-.035,.426), materialPoint(.717,.066,.574), materialPoint(.722,.128), materialPoint(.777,.002,.360), materialPoint(.914,.149,.660), materialPoint(.926,.289,.660), materialPoint(.881,.346), materialPoint(.94,.344,.126), materialPoint(1.003,.437,.255)], reps: 2, mirrored: true, transform: { sx: 1, sy: .742 } }; break;
    case "PuffyDiamond": definition = { points: [materialPoint(.87,.13,.146), materialPoint(.818,.357), materialPoint(1,.332,.853)], reps: 4, mirrored: true }; break;
    case "PixelCircle": definition = { points: [materialPoint(.5,0), materialPoint(.704,0), materialPoint(.704,.065), materialPoint(.843,.065), materialPoint(.843,.148), materialPoint(.926,.148), materialPoint(.926,.296), materialPoint(1,.296)], reps: 2, mirrored: true }; break;
    case "PixelTriangle": definition = { points: [materialPoint(.11,.5), materialPoint(.113,0), materialPoint(.287,0), materialPoint(.287,.087), materialPoint(.421,.087), materialPoint(.421,.17), materialPoint(.56,.17), materialPoint(.56,.265), materialPoint(.674,.265), materialPoint(.675,.344), materialPoint(.789,.344), materialPoint(.789,.439), materialPoint(.888,.439)], reps: 1, mirrored: true }; break;
    case "Bun": definition = { points: [materialPoint(.796,.5), materialPoint(.853,.518,1), materialPoint(.992,.631,1), materialPoint(.968,1,1)], reps: 2, mirrored: true }; break;
    case "Heart": definition = { points: [materialPoint(.5,.268,.016), materialPoint(.792,-.066,.958), materialPoint(1.064,.276,1), materialPoint(.501,.946,.129)], reps: 1, mirrored: true }; break;
    default: return null;
    }
    var vertices, roundings;
    if (definition.points) {
        var repeated = materialRepeat(definition.points, definition.reps || 1, !!definition.mirrored, point(.5, .5));
        vertices = repeated.map(function(v) { return v.p; });
        roundings = repeated.map(function(v) { return v.r; });
    } else {
        vertices = definition.vertices;
        roundings = definition.roundings;
    }
    var generated = materialRoundedPolygon(vertices, roundings, count);
    return materialNormalize(transformMaterialPoints(generated, definition.transform));
}

// 🌟 Generate normalized control points for any of the 35 M3E shapes.
// A high, shared topology keeps the organic M3E silhouettes smooth while
// retaining one-to-one points for deterministic morph interpolation.
function getNormalizedPathPoints(shapeName) {
    shapeName = canonicalShapeName(shapeName);
    if (shapeCache[shapeName]) {
        return shapeCache[shapeName];
    }

    let count = 144; // Uniform high-density topology for seamless smooth morphing
    let points = [];

    // Prefer the AndroidX MaterialShapes-derived vector descriptors for every
    // public M3 Expressive shape.  The legacy switch below remains only for
    // non-catalog semantic aliases such as rect, squircle, hexagon, and
    // octagon, preserving source compatibility without presenting them as M3E.
    let materialPoints = materialShapePoints(shapeName, count);
    if (materialPoints) {
        shapeCache[shapeName] = materialPoints;
        return materialPoints;
    }

    switch (shapeName) {
        case "Circle":
            for (let i = 0; i < count; i++) {
                let a = (i / count) * 2 * Math.PI;
                points.push({ x: 0.5 + 0.5 * Math.cos(a), y: 0.5 + 0.5 * Math.sin(a) });
            }
            break;

        case "Square":
            points = roundedPolygonPoints([
                { x: 0, y: 0 }, { x: 1, y: 0 }, { x: 1, y: 1 }, { x: 0, y: 1 }
            ], 0.30, count);
            break;

        case "Slanted":
            // Rotated -45° and skewed rounded square
            for (let i = 0; i < count; i++) {
                let a = (i / count) * 2 * Math.PI - Math.PI / 4;
                let n = 3.0;
                let rx = Math.sign(Math.cos(a)) * Math.pow(Math.abs(Math.cos(a)), 2 / n);
                let ry = Math.sign(Math.sin(a)) * Math.pow(Math.abs(Math.sin(a)), 2 / n);
                let skewX = rx - 0.1 * ry;
                points.push({ x: skewX, y: ry });
            }
            points = normalizePoints(points);
            break;

        case "Arch":
            // Door-like arch with a flat base and a single semicircular crown.
            for (let i = 0; i < count; i++) {
                let progress = i / count;
                if (progress < 0.16)
                    points.push({ x: 0.10 + 0.80 * progress / 0.16, y: 0.92 });
                else if (progress < 0.29)
                    points.push({ x: 0.90, y: 0.92 - 0.44 * (progress - 0.16) / 0.13 });
                else if (progress < 0.84) {
                    let angle = (progress - 0.29) / 0.55 * Math.PI;
                    points.push({ x: 0.50 + 0.40 * Math.cos(angle), y: 0.48 - 0.40 * Math.sin(angle) });
                } else
                    points.push({ x: 0.10, y: 0.48 + 0.44 * (progress - 0.84) / 0.16 });
            }
            break;

        case "Fan":
            // A quarter-circle container with two straight edges.
            for (let i = 0; i < count; i++) {
                let progress = i / count;
                if (progress < 0.16)
                    points.push({ x: 0.10 + 0.80 * progress / 0.16, y: 0.90 });
                else if (progress < 0.84) {
                    let angle = (progress - 0.16) / 0.68 * Math.PI / 2;
                    points.push({ x: 0.10 + 0.80 * Math.cos(angle), y: 0.90 - 0.80 * Math.sin(angle) });
                } else
                    points.push({ x: 0.10, y: 0.10 + 0.80 * (progress - 0.84) / 0.16 });
            }
            break;

        case "Arrow":
            generateSmoothClosedPath(points, count, [
                { x: 0.50, y: 0.08 }, { x: 0.86, y: 0.66 },
                { x: 0.70, y: 0.87 }, { x: 0.50, y: 0.80 },
                { x: 0.30, y: 0.87 }, { x: 0.14, y: 0.66 }
            ], 0.65);
            break;

        case "SemiCircle":
            // A literal semicircle with a flat baseline.
            for (let i = 0; i < count; i++) {
                let progress = i / count;
                if (progress < 0.20)
                    points.push({ x: 0.08 + 0.84 * progress / 0.20, y: 0.78 });
                else {
                    let angle = (progress - 0.20) / 0.80 * Math.PI;
                    points.push({ x: 0.50 + 0.42 * Math.cos(angle), y: 0.78 - 0.42 * Math.sin(angle) });
                }
            }
            break;

        case "Oval":
            // Slanted Oval (scaleY = 0.70, rotation = -45°)
            for (let i = 0; i < count; i++) {
                let a = (i / count) * 2 * Math.PI - Math.PI / 4;
                let px = 0.5 * Math.cos(a);
                let py = 0.35 * Math.sin(a);
                let rotX = px * Math.cos(-Math.PI / 4) - py * Math.sin(-Math.PI / 4);
                let rotY = px * Math.sin(-Math.PI / 4) + py * Math.cos(-Math.PI / 4);
                points.push({ x: 0.5 + rotX, y: 0.5 + rotY });
            }
            points = normalizePoints(points);
            break;

        case "rect":
        case "squircle":
            for (let i = 0; i < count; i++) {
                let a = (i / count) * 2 * Math.PI;
                let n = 2.4;
                let cx = Math.sign(Math.cos(a)) * Math.pow(Math.abs(Math.cos(a)), 2 / n);
                let cy = Math.sign(Math.sin(a)) * Math.pow(Math.abs(Math.sin(a)), 2 / n);
                points.push({ x: 0.5 + 0.5 * cx, y: 0.5 + 0.4 * cy });
            }
            points = normalizePoints(points);
            break;

        case "Pill":
            // M3E Pill is an authored diagonal organic capsule, not the
            // generic fully-rounded Rectangle used by the QML `pill` helper.
            // The superellipse preserves its soft, almost circular ends while
            // the rotation gives it the distinct catalogue silhouette.
            for (let i = 0; i < count; i++) {
                let a = (i / count) * 2 * Math.PI;
                let n = 3.5;
                let px = 0.46 * Math.sign(Math.cos(a)) * Math.pow(Math.abs(Math.cos(a)), 2 / n);
                let py = 0.35 * Math.sign(Math.sin(a)) * Math.pow(Math.abs(Math.sin(a)), 2 / n);
                let rotation = -Math.PI / 4;
                points.push({
                    x: 0.5 + px * Math.cos(rotation) - py * Math.sin(rotation),
                    y: 0.5 + px * Math.sin(rotation) + py * Math.cos(rotation)
                });
            }
            points = normalizePoints(points);
            break;

        case "Triangle":
            points = roundedPolygonPoints(regularPolygonVertices(3, -Math.PI / 2), 0.20, count);
            break;

        case "Diamond":
            points = roundedPolygonPoints(regularPolygonVertices(4, 0, 1, 1.2), 0.30, count);
            points = normalizePoints(points);
            break;

        case "Pentagon":
            points = roundedPolygonPoints(regularPolygonVertices(5, -Math.PI / 10), 0.30, count);
            break;

        case "Hexagon":
            generateRegularPolygon(points, count, 6, -Math.PI / 2);
            break;

        case "Octagon":
            generateRegularPolygon(points, count, 8, -Math.PI / 2);
            break;

        case "Gem":
            generateRoundedLobes(points, count, 7, 0.41, 0.055, -Math.PI / 2);
            break;

        // RoundedStar / Cookie Shapes
        case "VerySunny": generateStar(points, count, 8, 0.50, 0.325, 0); break;
        case "Sunny": generateStar(points, count, 8, 0.50, 0.415, 0); break;
        case "Cookie4Sided": generateStar(points, count, 4, 0.50, 0.25, -Math.PI / 4); break;
        case "Cookie6Sided": generateStar(points, count, 6, 0.50, 0.375, -Math.PI / 2); break;
        case "Cookie7Sided": generateStar(points, count, 7, 0.50, 0.375, -Math.PI / 2); break;
        case "Cookie9Sided": generateStar(points, count, 9, 0.50, 0.40, -Math.PI / 2); break;
        case "Cookie12Sided": generateStar(points, count, 12, 0.50, 0.40, -Math.PI / 2); break;

        // Clover / Burst / Boom
        case "Clover4Leaf": generateStar(points, count, 4, 0.50, 0.10, Math.PI / 4); break;
        case "Clover8Leaf": generateStar(points, count, 8, 0.50, 0.325, Math.PI / 8); break;
        case "Burst": generateStar(points, count, 12, 0.50, 0.35, 0); break;
        case "SoftBurst": generateStar(points, count, 10, 0.50, 0.325, 0); break;
        case "Boom": generateStar(points, count, 15, 0.50, 0.21, 0); break;
        case "SoftBoom": generateStar(points, count, 16, 0.50, 0.30, 0); break;
        case "Flower": generateStar(points, count, 8, 0.50, 0.2875, 0); break;

        // Organic / Complex Shapes
        case "ClamShell":
            // Low, wide rounded hexagon. Its silhouette must retain the
            // authored horizontal aspect rather than be normalized to square.
            generateSmoothClosedPath(points, count, [
                { x: 0.20, y: 0.22 }, { x: 0.80, y: 0.22 },
                { x: 0.94, y: 0.50 }, { x: 0.80, y: 0.78 },
                { x: 0.20, y: 0.78 }, { x: 0.06, y: 0.50 }
            ], 0.40);
            break;

        case "Ghostish":
            for (let i = 0; i < count; i++) {
                let a = (i / count) * 2 * Math.PI - Math.PI / 2;
                let r = 0.4 + 0.08 * Math.sin(3 * a);
                points.push({ x: 0.5 + r * Math.cos(a), y: 0.5 + 0.88 * r * Math.sin(a) });
            }
            points = normalizePoints(points);
            break;

        case "Puffy":
            for (let i = 0; i < count; i++) {
                let a = (i / count) * 2 * Math.PI;
                let r = 0.42 + 0.06 * Math.sin(4 * a);
                points.push({ x: 0.5 + r * Math.cos(a), y: 0.5 + r * Math.sin(a) });
            }
            points = normalizePoints(points);
            break;

        case "PuffyDiamond":
            for (let i = 0; i < count; i++) {
                let a = (i / count) * 2 * Math.PI;
                let r = 0.4 / (Math.abs(Math.cos(a)) + Math.abs(Math.sin(a))) + 0.05 * Math.cos(4 * a);
                points.push({ x: 0.5 + r * Math.cos(a), y: 0.5 + r * Math.sin(a) });
            }
            points = normalizePoints(points);
            break;

        case "PixelCircle":
            for (let i = 0; i < count; i++) {
                let a = (i / count) * 2 * Math.PI;
                let px = Math.round(Math.cos(a) * 5) / 5;
                let py = Math.round(Math.sin(a) * 5) / 5;
                points.push({ x: 0.5 + 0.45 * px, y: 0.5 + 0.45 * py });
            }
            points = normalizePoints(points);
            break;

        case "PixelTriangle":
            for (let i = 0; i < count; i++) {
                let a = (i / count) * 2 * Math.PI - Math.PI / 2;
                let px = Math.round(Math.cos(a) * 4) / 4;
                let py = Math.round(Math.sin(a) * 4) / 4;
                points.push({ x: 0.5 + 0.45 * px, y: 0.5 + 0.45 * py });
            }
            points = normalizePoints(points);
            break;

        case "Bun":
            generateStar(points, count, 2, 0.45, 0.30, Math.PI / 2);
            break;

        case "Heart":
            for (let i = 0; i < count; i++) {
                let t = (i / count) * 2 * Math.PI;
                let x = 16 * Math.pow(Math.sin(t), 3);
                let y = -(13 * Math.cos(t) - 5 * Math.cos(2 * t) - 2 * Math.cos(3 * t) - Math.cos(4 * t));
                points.push({ x: x, y: y });
            }
            points = normalizePoints(points);
            break;

        default:
            // Fallback Circle
            for (let i = 0; i < count; i++) {
                let a = (i / count) * 2 * Math.PI;
                points.push({ x: 0.5 + 0.5 * Math.cos(a), y: 0.5 + 0.5 * Math.sin(a) });
            }
            break;
    }

    shapeCache[shapeName] = points;
    return points;
}

function generateStar(points, count, lobes, outerR, innerR, offsetAngle) {
    for (let i = 0; i < count; i++) {
        let a = (i / count) * 2 * Math.PI + offsetAngle;
        let angleStep = (2 * Math.PI) / lobes;
        let mod = (a % angleStep) / angleStep;
        let wave = Math.cos(mod * 2 * Math.PI);
        let r = innerR + (outerR - innerR) * (0.5 + 0.5 * wave);
        points.push({ x: 0.5 + r * Math.cos(a), y: 0.5 + r * Math.sin(a) });
    }
}

function generateRoundedLobes(points, count, lobes, radius, amplitude, offsetAngle) {
    for (let i = 0; i < count; i++) {
        let angle = (i / count) * 2 * Math.PI + offsetAngle;
        let localRadius = radius + amplitude * Math.cos(lobes * angle);
        points.push({
            x: 0.5 + localRadius * Math.cos(angle),
            y: 0.5 + localRadius * Math.sin(angle)
        });
    }
}

function generateSmoothClosedPath(points, count, vertices, tension) {
    let vertexCount = vertices.length;
    let scale = 0.5 * tension;
    for (let index = 0; index < count; index++) {
        let position = index / count * vertexCount;
        let segment = Math.floor(position);
        let local = position - segment;
        let previous = vertices[(segment - 1 + vertexCount) % vertexCount];
        let start = vertices[segment % vertexCount];
        let end = vertices[(segment + 1) % vertexCount];
        let next = vertices[(segment + 2) % vertexCount];
        let squared = local * local;
        let cubed = squared * local;
        points.push({
            x: 0.5 * ((2 * start.x) + (-previous.x + end.x) * local
                    + (2 * previous.x - 5 * start.x + 4 * end.x - next.x) * squared
                    + (-previous.x + 3 * start.x - 3 * end.x + next.x) * cubed) * tension
                    + (1 - tension) * (start.x + (end.x - start.x) * local),
            y: 0.5 * ((2 * start.y) + (-previous.y + end.y) * local
                    + (2 * previous.y - 5 * start.y + 4 * end.y - next.y) * squared
                    + (-previous.y + 3 * start.y - 3 * end.y + next.y) * cubed) * tension
                    + (1 - tension) * (start.y + (end.y - start.y) * local)
        });
    }
}

function generateRegularPolygon(points, count, sides, offsetAngle) {
    var sideAngle = (2 * Math.PI) / sides;
    for (var i = 0; i < count; i++) {
        var angle = (i / count) * 2 * Math.PI + offsetAngle;
        var phase = (angle - offsetAngle + Math.PI) % sideAngle;
        var radius = 0.5 * Math.cos(Math.PI / sides)
                / Math.cos(phase - sideAngle / 2);
        points.push({ x: 0.5 + radius * Math.cos(angle), y: 0.5 + radius * Math.sin(angle) });
    }
    var normalized = normalizePoints(points);
    points.length = 0;
    for (var pointIndex = 0; pointIndex < normalized.length; pointIndex++)
        points.push(normalized[pointIndex]);
}

function alignClosedPathStart(reference, candidate) {
    // A Canvas path has no semantic first vertex. Match the cyclic start of
    // the target path to the source before interpolation, otherwise equally
    // valid paths (for example Circle and Square) can collapse at mid-morph.
    let bestOffset = 0;
    let bestDistance = Infinity;
    for (let offset = 0; offset < candidate.length; ++offset) {
        let distance = 0;
        for (let index = 0; index < reference.length; ++index) {
            let target = candidate[(index + offset) % candidate.length];
            let dx = reference[index].x - target.x;
            let dy = reference[index].y - target.y;
            distance += dx * dx + dy * dy;
        }
        if (distance < bestDistance) {
            bestDistance = distance;
            bestOffset = offset;
        }
    }
    let aligned = [];
    for (let index = 0; index < candidate.length; ++index)
        aligned.push(candidate[(index + bestOffset) % candidate.length]);
    return aligned;
}

// 🌟 Perform Topology-Matched Morph Interpolation between Shape A and Shape B
// Clamps morph progress to [0, 1] to prevent self-intersection/folding; raw overshoot goes to scale.
function interpolateShapes(shapeA, shapeB, progress) {
    let clampedT = Math.max(0.0, Math.min(1.0, progress));
    let ptsA = getNormalizedPathPoints(shapeA);
    let ptsB = getNormalizedPathPoints(shapeB);

    if (clampedT === 0)
        return ptsA;
    if (clampedT === 1)
        return ptsB;
    ptsB = alignClosedPathStart(ptsA, ptsB);

    let result = [];
    for (let i = 0; i < ptsA.length; i++) {
        let ax = ptsA[i].x;
        let ay = ptsA[i].y;
        let bx = ptsB[i].x;
        let by = ptsB[i].y;
        result.push({
            x: ax + (bx - ax) * clampedT,
            y: ay + (by - ay) * clampedT
        });
    }
    return result;
}
