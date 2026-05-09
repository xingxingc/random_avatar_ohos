function randomFromInterval(min, max) {
    // min and max included
    return Math.random() * (max - min) + min;
}
function cubicBezier(P0, P1, P2, P3, t) {
    let x = (1 - t) ** 3 * P0[0] + 3 * (1 - t) ** 2 * t * P1[0] + 3 * (1 - t) * t ** 2 * P2[0] + t ** 3 * P3[0];
    let y = (1 - t) ** 3 * P0[1] + 3 * (1 - t) ** 2 * t * P1[1] + 3 * (1 - t) * t ** 2 * P2[1] + t ** 3 * P3[1];
    return [x, y];
}
function getEggShapePoints(a, b, k, segment_points) {
    // the function is x^2/a^2 * (1 + ky) + y^2/b^2 = 1
    let result = [];
    //   let pointString = "";
    for (let i = 0; i < segment_points; i++) {
        // x positive, y positive
        // first compute the degree
        let degree =
            (Math.PI / 2 / segment_points) * i +
            randomFromInterval(
                -Math.PI / 1.1 / segment_points,
                Math.PI / 1.1 / segment_points
            );
        let y = Math.sin(degree) * b;
        let x =
            Math.sqrt(((1 - (y * y) / (b * b)) / (1 + k * y)) * a * a) +
            randomFromInterval(-a / 200.0, a / 200.0);
        // pointString += x + "," + y + " ";
        result.push([x, y]);
    }
    for (let i = segment_points; i > 0; i--) {
        // x is negative, y is positive
        let degree =
            (Math.PI / 2 / segment_points) * i +
            randomFromInterval(
                -Math.PI / 1.1 / segment_points,
                Math.PI / 1.1 / segment_points
            );
        let y = Math.sin(degree) * b;
        let x =
            -Math.sqrt(((1 - (y * y) / (b * b)) / (1 + k * y)) * a * a) +
            randomFromInterval(-a / 200.0, a / 200.0);
        // pointString += x + "," + y + " ";
        result.push([x, y]);
    }
    for (let i = 0; i < segment_points; i++) {
        // x is negative, y is negative
        let degree =
            (Math.PI / 2 / segment_points) * i +
            randomFromInterval(
                -Math.PI / 1.1 / segment_points,
                Math.PI / 1.1 / segment_points
            );
        let y = -Math.sin(degree) * b;
        let x =
            -Math.sqrt(((1 - (y * y) / (b * b)) / (1 + k * y)) * a * a) +
            randomFromInterval(-a / 200.0, a / 200.0);
        // pointString += x + "," + y + " ";
        result.push([x, y]);
    }
    for (let i = segment_points; i > 0; i--) {
        // x is positive, y is negative
        let degree =
            (Math.PI / 2 / segment_points) * i +
            randomFromInterval(
                -Math.PI / 1.1 / segment_points,
                Math.PI / 1.1 / segment_points
            );
        let y = -Math.sin(degree) * b;
        let x =
            Math.sqrt(((1 - (y * y) / (b * b)) / (1 + k * y)) * a * a) +
            randomFromInterval(-a / 200.0, a / 200.0);
        // pointString += x + "," + y + " ";
        result.push([x, y]);
    }
    return result;
}

export function generateMouthShape0(faceCountour, faceHeight, faceWidth) {
    // the first one is a a big smile U shape
    let faceCountourCopy = faceCountour.slice(0, faceCountour.length - 2);
    // choose one point on face at bottom side
    let mouthRightY = randomFromInterval(faceHeight / 7, faceHeight / 3.5)
    let mouthLeftY = randomFromInterval(faceHeight / 7, faceHeight / 3.5)
    let mouthRightX = randomFromInterval(faceWidth / 10, faceWidth / 2)
    let mouthLeftX = -mouthRightX + randomFromInterval(-faceWidth / 20, faceWidth / 20)
    let mouthRight = [mouthRightX, mouthRightY]
    let mouthLeft = [mouthLeftX, mouthLeftY]

    let controlPoint0 = [randomFromInterval(0, mouthRightX), randomFromInterval(mouthLeftY + 5, faceHeight / 1.5)]
    let controlPoint1 = [randomFromInterval(mouthLeftX, 0), randomFromInterval(mouthLeftY + 5, faceHeight / 1.5)]

    let mouthPoints = []
    for (let i = 0; i < 1; i += 0.01) {
        mouthPoints.push(cubicBezier(mouthLeft, controlPoint1, controlPoint0, mouthRight, i))
    }
    if (Math.random() > 0.5) {
        for (let i = 0; i < 1; i += 0.01) {
            mouthPoints.push(cubicBezier(mouthRight, controlPoint0, controlPoint1, mouthLeft, i))
        }
    }else{
        let y_offset_portion = randomFromInterval(0, 0.8);
        for (let i = 0; i < 100; i += 1) {
            mouthPoints.push([mouthPoints[99][0] * (1 - i / 100.0) + mouthPoints[0][0] * i / 100.0, (mouthPoints[99][1] * (1 - i / 100.0) + mouthPoints[0][1] * i / 100.0) * (1 - y_offset_portion) + mouthPoints[99 - i][1] * y_offset_portion])
        }
    }
    return mouthPoints;
}

export function generateMouthShape1(faceCountour, faceHeight, faceWidth) {
    // the first one is a a big smile U shape
    let faceCountourCopy = faceCountour.slice(0, faceCountour.length - 2);
    // choose one point on face at bottom side
    let mouthRightY = randomFromInterval(faceHeight / 7, faceHeight / 4)
    let mouthLeftY = randomFromInterval(faceHeight / 7, faceHeight / 4)
    let mouthRightX = randomFromInterval(faceWidth / 10, faceWidth / 2)
    let mouthLeftX = -mouthRightX + randomFromInterval(-faceWidth / 20, faceWidth / 20)
    let mouthRight = [mouthRightX, mouthRightY]
    let mouthLeft = [mouthLeftX, mouthLeftY]

    let controlPoint0 = [randomFromInterval(0, mouthRightX), randomFromInterval(mouthLeftY + 5, faceHeight / 1.5)]
    let controlPoint1 = [randomFromInterval(mouthLeftX, 0), randomFromInterval(mouthLeftY + 5, faceHeight / 1.5)]

    let mouthPoints = []
    for (let i = 0; i < 1; i += 0.01) {
        mouthPoints.push(cubicBezier(mouthLeft, controlPoint1, controlPoint0, mouthRight, i))
    }

    let center = [(mouthRight[0] + mouthLeft[0]) / 2, mouthPoints[25][1] / 2 + mouthPoints[75][1] / 2];
    if (Math.random() > 0.5) {
        for (let i = 0; i < 1; i += 0.01) {
            mouthPoints.push(cubicBezier(mouthRight, controlPoint0, controlPoint1, mouthLeft, i))
        }
    }else{
        let y_offset_portion = randomFromInterval(0, 0.8);
        for (let i = 0; i < 100; i += 1) {
            mouthPoints.push([mouthPoints[99][0] * (1 - i / 100.0) + mouthPoints[0][0] * i / 100.0, (mouthPoints[99][1] * (1 - i / 100.0) + mouthPoints[0][1] * i / 100.0) * (1 - y_offset_portion) + mouthPoints[99 - i][1] * y_offset_portion])
        }
    }
    // translate to center
    for (let i = 0; i < mouthPoints.length; i++) {
        mouthPoints[i][0] -= center[0]
        mouthPoints[i][1] -= center[1]
        // rotate 180 degree
        mouthPoints[i][1] = -mouthPoints[i][1]
        // scale smaller
        mouthPoints[i][0] = mouthPoints[i][0] * 0.6
        mouthPoints[i][1] = mouthPoints[i][1] * 0.6
        // translate back
        mouthPoints[i][0] += center[0]
        mouthPoints[i][1] += center[1] * 0.8
    }
    return mouthPoints;
}

export function generateMouthShape2(faceCountour, faceHeight, faceWidth) {
    // generate a random center
    let center = [randomFromInterval(-faceWidth / 8, faceWidth / 8), randomFromInterval(faceHeight / 4, faceHeight / 2.5)]

    let mouthPoints = getEggShapePoints(randomFromInterval(faceWidth / 4, faceWidth / 10), randomFromInterval(faceHeight / 10, faceHeight / 20), 0.001, 50);
    let randomRotationDegree = randomFromInterval(-Math.PI / 9.5, Math.PI / 9.5)
    for (let i = 0; i < mouthPoints.length; i++) {
        // rotate the point
        let x = mouthPoints[i][0]
        let y = mouthPoints[i][1]
        mouthPoints[i][0] = x * Math.cos(randomRotationDegree) - y * Math.sin(randomRotationDegree)
        mouthPoints[i][1] = x * Math.sin(randomRotationDegree) + y * Math.cos(randomRotationDegree)
        mouthPoints[i][0] += center[0]
        mouthPoints[i][1] += center[1]
    }
    return mouthPoints;
}