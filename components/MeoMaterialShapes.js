.pragma library

// 🌟 Material 3 Expressive (M3E) 35 Geometry Generator & Morph Engine
// All shapes operate in normalized [0,1] x [0,1] space.

var shapeCache = {};
var morphTopologyCache = {};

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

// 🌟 Generate normalized control points (36 sampling points) for any of the 35 M3E shapes
function getNormalizedPathPoints(shapeName) {
    if (shapeCache[shapeName]) {
        return shapeCache[shapeName];
    }

    let count = 36; // Uniform topology count for seamless morphing
    let points = [];

    switch (shapeName) {
        case "Circle":
            for (let i = 0; i < count; i++) {
                let a = (i / count) * 2 * Math.PI;
                points.push({ x: 0.5 + 0.5 * Math.cos(a), y: 0.5 + 0.5 * Math.sin(a) });
            }
            break;

        case "Square":
            // Rounded Square (radius = 0.30)
            for (let i = 0; i < count; i++) {
                let a = (i / count) * 2 * Math.PI;
                let n = 3.2; // Smooth superellipse exponent
                let cx = Math.sign(Math.cos(a)) * Math.pow(Math.abs(Math.cos(a)), 2 / n);
                let cy = Math.sign(Math.sin(a)) * Math.pow(Math.abs(Math.sin(a)), 2 / n);
                points.push({ x: 0.5 + 0.5 * cx, y: 0.5 + 0.5 * cy });
            }
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
            // Arch: Two top corners rounded, two bottom corners tight
            for (let i = 0; i < count; i++) {
                let a = (i / count) * 2 * Math.PI - (3 * Math.PI / 4);
                let r = a < 0 || a > Math.PI ? 0.5 : 0.25;
                points.push({ x: 0.5 + r * Math.cos(a), y: 0.5 + r * Math.sin(a) });
            }
            points = normalizePoints(points);
            break;

        case "Fan":
            // Fan: One dominant corner rounded (radius = 1.00)
            for (let i = 0; i < count; i++) {
                let a = (i / count) * 2 * Math.PI - Math.PI / 4;
                let r = (a >= 0 && a <= Math.PI / 2) ? 0.5 : 0.2;
                points.push({ x: 0.5 + r * Math.cos(a), y: 0.5 + r * Math.sin(a) });
            }
            points = normalizePoints(points);
            break;

        case "Arrow":
            // Rounded Arrow with 3 outer vertices and 1 inner concave vertex
            for (let i = 0; i < count; i++) {
                let a = (i / count) * 2 * Math.PI - Math.PI / 2;
                let idx = Math.floor((i / count) * 4);
                let r = (idx === 2) ? 0.18 : 0.5;
                points.push({ x: 0.5 + r * Math.cos(a), y: 0.5 + r * Math.sin(a) });
            }
            points = normalizePoints(points);
            break;

        case "SemiCircle":
            // SemiCircle: One side flat/tight, one side fully rounded
            for (let i = 0; i < count; i++) {
                let a = (i / count) * 2 * Math.PI;
                let rX = Math.cos(a) > 0 ? 0.5 : 0.15;
                points.push({ x: 0.5 + rX * Math.cos(a), y: 0.5 + 0.5 * Math.sin(a) });
            }
            points = normalizePoints(points);
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

        case "Pill":
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

        case "Triangle":
            for (let i = 0; i < count; i++) {
                let a = (i / count) * 2 * Math.PI - Math.PI / 2;
                let phase = (a + Math.PI / 2) % (2 * Math.PI / 3);
                let r = 0.45 / Math.cos(phase - Math.PI / 3);
                r = Math.min(0.5, r);
                points.push({ x: 0.5 + r * Math.cos(a), y: 0.5 + r * Math.sin(a) });
            }
            points = normalizePoints(points);
            break;

        case "Diamond":
            for (let i = 0; i < count; i++) {
                let a = (i / count) * 2 * Math.PI;
                let r = 0.4 / (Math.abs(Math.cos(a)) + Math.abs(Math.sin(a)));
                points.push({ x: 0.5 + r * Math.cos(a), y: 0.5 + 1.2 * r * Math.sin(a) });
            }
            points = normalizePoints(points);
            break;

        case "Pentagon":
            for (let i = 0; i < count; i++) {
                let a = (i / count) * 2 * Math.PI - (Math.PI / 10);
                let phase = (a + Math.PI / 10) % (2 * Math.PI / 5);
                let r = 0.45 / Math.cos(phase - Math.PI / 5);
                points.push({ x: 0.5 + r * Math.cos(a), y: 0.5 + r * Math.sin(a) });
            }
            points = normalizePoints(points);
            break;

        case "Gem":
            for (let i = 0; i < count; i++) {
                let a = (i / count) * 2 * Math.PI - Math.PI / 2;
                let phase = (a + Math.PI / 2) % (2 * Math.PI / 6);
                let r = 0.45 / Math.cos(phase - Math.PI / 6);
                if (i % 6 === 1 || i % 6 === 4) r *= 0.90; // inset 0.10
                points.push({ x: 0.5 + r * Math.cos(a), y: 0.5 + r * Math.sin(a) });
            }
            points = normalizePoints(points);
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
            for (let i = 0; i < count; i++) {
                let a = (i / count) * 2 * Math.PI;
                let r = 0.4 + 0.1 * Math.cos(5 * a);
                points.push({ x: 0.5 + r * Math.cos(a), y: 0.5 + 0.7 * r * Math.sin(a) });
            }
            points = normalizePoints(points);
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
            for (let i = 0; i < count; i++) {
                let a = (i / count) * 2 * Math.PI;
                let r = 0.4 + 0.08 * Math.cos(2 * a);
                points.push({ x: 0.5 + r * Math.cos(a), y: 0.5 + 0.8 * r * Math.sin(a) });
            }
            points = normalizePoints(points);
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

// 🌟 Perform Topology-Matched Morph Interpolation between Shape A and Shape B
// Clamps morph progress to [0, 1] to prevent self-intersection/folding; raw overshoot goes to scale.
function interpolateShapes(shapeA, shapeB, progress) {
    let clampedT = Math.max(0.0, Math.min(1.0, progress));
    let ptsA = getNormalizedPathPoints(shapeA);
    let ptsB = getNormalizedPathPoints(shapeB);

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
