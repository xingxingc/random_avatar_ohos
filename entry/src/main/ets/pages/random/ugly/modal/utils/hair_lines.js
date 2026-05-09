function randomFromInterval(min, max) {
  // min and max included
  return Math.random() * (max - min) + min;
}
function factorial(n) {
  if (n <= 1) return 1;
  return n * factorial(n - 1);
}

function binomialCoefficient(n, k) {
  return factorial(n) / (factorial(k) * factorial(n - k));
}

// function calculateBezierPoint(t, controlPoints) {
//   let x = 0, y = 0;
//   const n = controlPoints.length - 1;
//
//   for (let i = 0; i <= n; i++) {
//     let binCoeff = binomialCoefficient(n, i);
//     let a = Math.pow(1 - t, n - i);
//     let b = Math.pow(t, i);
//     x += binCoeff * a * b * controlPoints[i].x;
//     y += binCoeff * a * b * controlPoints[i].y;
//   }
//
//   return [x, y];
// }
function calculateBezierPointFast(t, controlPoints, coeffs) {
  let x = 0, y = 0;
  const n = controlPoints.length - 1;

  for (let i = 0; i <= n; i++) {
    let a = Math.pow(1 - t, n - i);
    let b = Math.pow(t, i);
    let w = coeffs[i] * a * b;

    x += w * controlPoints[i].x;
    y += w * controlPoints[i].y;
  }

  return [x, y];
}
function getBinomialCoefficients(n) {
  const coeffs = new Array(n + 1).fill(0);
  coeffs[0] = 1;
  for (let i = 1; i <= n; i++) {
    coeffs[i] = coeffs[i - 1] * (n - i + 1) / i;
  }
  return coeffs;
}

// function computeBezierCurve(controlPoints, numberOfPoints) {
//   let curve = [];
//   for (let i = 0; i <= numberOfPoints; i++) {
//     let t = i / numberOfPoints;
//     let point = calculateBezierPoint(t, controlPoints);
//     curve.push(point);
//   }
//   return curve;
// }
function computeBezierCurve(controlPoints, numberOfPoints) {
  const coeffs = getBinomialCoefficients(controlPoints.length - 1);

  let curve = [];
  for (let i = 0; i <= numberOfPoints; i++) {
    let t = i / numberOfPoints;
    curve.push(calculateBezierPointFast(t, controlPoints, coeffs));
  }
  return curve;
}

export function generateHairLines0(faceCountour, numHairLines = 100) {
  let faceCountourCopy = faceCountour.slice(0, faceCountour.length - 2);
  let results = [];
  for (let i = 0; i < numHairLines; i++){
    let numHairPoints = 20 + Math.floor(randomFromInterval(-5, 5));
    // we generate some hair lines
    let hair_line = [];
    let index_offset = Math.floor(randomFromInterval(30, 140));
    for (let j = 0; j < numHairPoints; j++){
      let idx = (faceCountourCopy.length - (j + index_offset)) % faceCountourCopy.length
      hair_line.push({x: faceCountourCopy[idx][0], y:faceCountourCopy[idx][1]});
    }
    let d0 = computeBezierCurve(hair_line, numHairPoints);
    hair_line = []
    index_offset = Math.floor(randomFromInterval(30, 140));
    for (let j = 0; j < numHairPoints; j++){
      let idx = (faceCountourCopy.length - (-j + index_offset)) % faceCountourCopy.length
      hair_line.push({x: faceCountourCopy[idx][0], y:faceCountourCopy[idx][1]});
    }
    let d1 = computeBezierCurve(hair_line, numHairPoints);
    let d = [];
    for (let j = 0; j < numHairPoints; j++){
      d.push([d0[j][0] * (j * (1 / numHairPoints)) ** 2 + d1[j][0] * (1 - (j * (1 / numHairPoints)) ** 2), d0[j][1] * (j * (1 / numHairPoints)) ** 2 + d1[j][1] * (1 - (j * (1 / numHairPoints)) ** 2)]);
    }

    results.push(d);
  }
  return results;
}
export function generateHairLines1(faceCountour, numHairLines = 100) {
  let faceCountourCopy = faceCountour.slice(0, faceCountour.length - 2);
  let results = [];
  for (let i = 0; i < numHairLines; i++){
    let numHairPoints = 20 + Math.floor(randomFromInterval(-5, 5));
    let hair_line = [];
    let index_start = Math.floor(randomFromInterval(20, 160));
    let idx = (faceCountourCopy.length - index_start) % faceCountourCopy.length
    hair_line.push({x: faceCountourCopy[idx][0], y:faceCountourCopy[idx][1]});

    for (let j = 1; j < numHairPoints + 1; j++){
      index_start = Math.floor(randomFromInterval(20, 160));
      hair_line.push({x: faceCountourCopy[idx][0], y:faceCountourCopy[idx][1]});
    }
    let d = computeBezierCurve(hair_line, numHairPoints);

    results.push(d);
  }
  return results;
}


export function generateHairLines2(faceCountour, numHairLines = 100) {
  let faceCountourCopy = faceCountour.slice(0, faceCountour.length - 2);
  let results = [];
  let pickedIndices = [];
  for (let i = 0; i < numHairLines; i++){
    pickedIndices.push(Math.floor(randomFromInterval(10, 180)));
  }
  pickedIndices.sort();
  for (let i = 0; i < numHairLines; i++){
    let numHairPoints = 20 + Math.floor(randomFromInterval(-5, 5));
    // we generate some hair lines
    let hair_line = [];
    let index_offset = pickedIndices[i];
    let lower = randomFromInterval(0.8 , 1.4);
    let reverse = Math.random() > 0.5 ? 1 : -1;
    for (let j = 0; j < numHairPoints; j++){
      let powerscale = randomFromInterval(0.1, 3);
      let portion = (1 - (j / numHairPoints) ** powerscale) * (1 - lower) + lower;
      let idx = (faceCountourCopy.length - (reverse * j + index_offset)) % faceCountourCopy.length
      hair_line.push({x: faceCountourCopy[idx][0] * portion, y:faceCountourCopy[idx][1] * portion});
    }
    let d = computeBezierCurve(hair_line, numHairPoints);
    if (Math.random() > 0.7) d = d.reverse();
    if (results.length == 0){
      results.push(d);
      continue;
    }
    let lastHairPoint = results[results.length - 1][results[results.length - 1].length - 1];
    let lastPointsDistance = Math.sqrt((d[0][0] - lastHairPoint[0]) ** 2 + (d[0][1] - lastHairPoint[1]) ** 2);
    if (Math.random() > 0.5 && lastPointsDistance < 100){
      results[results.length - 1] = results[results.length - 1].concat(d);
    }else{
      results.push(d);
    }
  }
  return results;
}

export function generateHairLines3(faceCountour, numHairLines = 100) {
  let faceCountourCopy = faceCountour.slice(0, faceCountour.length - 2);
  let results = [];
  let pickedIndices = [];
  for (let i = 0; i < numHairLines; i++){
    pickedIndices.push(Math.floor(randomFromInterval(10, 180)));
  }
  pickedIndices.sort();
  let splitPoint = Math.floor(randomFromInterval(0, 200));
  for (let i = 0; i < numHairLines; i++){
    let numHairPoints = 30 + Math.floor(randomFromInterval(-8, 8));
    // we generate some hair lines
    let hair_line = [];
    let index_offset = pickedIndices[i];
    let lower = randomFromInterval(1 , 2.3);
    if (Math.random() > 0.9) lower = randomFromInterval(0 , 1.);
    let reverse = index_offset > splitPoint ? 1 : -1;
    for (let j = 0; j < numHairPoints; j++){
      let powerscale = randomFromInterval(0.1, 3);
      let portion = (1 - (j / (numHairPoints)) ** powerscale) * (1 - lower) + lower;
      hair_line.push({x: faceCountourCopy[(faceCountourCopy.length - (reverse * j * 2 + index_offset)) % faceCountourCopy.length][0] * portion, y:faceCountourCopy[(faceCountourCopy.length - (reverse * j * 2 + index_offset)) % faceCountourCopy.length][1]});
    }
    let d = computeBezierCurve(hair_line, numHairPoints);
    results.push(d);
  }
  return results;
}



// // ================= 工具函数 =================
//
// function randomFromInterval(min, max) {
//     return Math.random() * (max - min) + min;
// }
//
// // 👉 组合数缓存
// const coeffCache = new Map();
//
// function getBinomialCoefficients(n) {
//     if (coeffCache.has(n)) {
//         return coeffCache.get(n);
//     }
//
//     const coeffs = new Array(n + 1);
//     coeffs[0] = 1;
//
//     for (let i = 1; i <= n; i++) {
//         coeffs[i] = coeffs[i - 1] * (n - i + 1) / i;
//     }
//
//     coeffCache.set(n, coeffs);
//     return coeffs;
// }
//
// // 👉 安全 index（避免负数 %）
// function fastIndex(i, len) {
//     if (i >= 0) {
//         return i < len ? i : i % len;
//     }
//     return (i % len + len) % len;
// }
//
// // ================= Bezier 核心优化 =================
//
// function calculateBezierPointFast(t, controlPoints, coeffs) {
//     const n = controlPoints.length - 1;
//
//     let x = 0, y = 0;
//     const oneMinusT = 1 - t;
//
//     // (1 - t)^n
//     let a = 1;
//     for (let i = 0; i < n; i++) a *= oneMinusT;
//
//     // t^0
//     let b = 1;
//
//     for (let i = 0; i <= n; i++) {
//         const w = coeffs[i] * a * b;
//
//         x += w * controlPoints[i].x;
//         y += w * controlPoints[i].y;
//
//         if (i < n) {
//             a /= oneMinusT;
//             b *= t;
//         }
//     }
//
//     return [x, y];
// }
//
// function computeBezierCurve(controlPoints, numberOfPoints) {
//     const coeffs = getBinomialCoefficients(controlPoints.length - 1);
//     const curve = new Array(numberOfPoints + 1);
//
//     for (let i = 0; i <= numberOfPoints; i++) {
//         const t = i / numberOfPoints;
//         curve[i] = calculateBezierPointFast(t, controlPoints, coeffs);
//     }
//
//     return curve;
// }
//
// // ================= Hair 生成 =================
//
// export function generateHairLines0(faceCountour, numHairLines = 10) {
//     const len = faceCountour.length - 2;
//     const results = new Array(numHairLines);
//
//     for (let i = 0; i < numHairLines; i++) {
//         const numHairPoints = 20 + ((Math.random() * 10) | 0) - 5;
//
//         let hair_line = new Array(numHairPoints);
//
//         // ---- 第一条曲线 ----
//         let index_offset = (Math.random() * 110 + 30) | 0;
//
//         for (let j = 0; j < numHairPoints; j++) {
//             const idx = fastIndex(len - (j + index_offset), len);
//             const p = faceCountour[idx];
//             hair_line[j] = { x: p[0], y: p[1] };
//         }
//
//         const d0 = computeBezierCurve(hair_line, numHairPoints);
//
//         // ---- 第二条曲线 ----
//         index_offset = (Math.random() * 110 + 30) | 0;
//         hair_line = new Array(numHairPoints);
//
//         for (let j = 0; j < numHairPoints; j++) {
//             const idx = fastIndex(len - (-j + index_offset), len);
//             const p = faceCountour[idx];
//             hair_line[j] = { x: p[0], y: p[1] };
//         }
//
//         const d1 = computeBezierCurve(hair_line, numHairPoints);
//
//         // ---- 混合 ----
//         const d = new Array(numHairPoints);
//
//         for (let j = 0; j < numHairPoints; j++) {
//             const t = j / numHairPoints;
//             const w = t * t;
//
//             d[j] = [
//                 d0[j][0] * w + d1[j][0] * (1 - w),
//                 d0[j][1] * w + d1[j][1] * (1 - w)
//             ];
//         }
//
//         results[i] = d;
//     }
//
//     return results;
// }
//
// // ================= 修复版本 =================
//
// export function generateHairLines1(faceCountour, numHairLines = 100) {
//     const len = faceCountour.length - 2;
//     const results = new Array(numHairLines);
//
//     for (let i = 0; i < numHairLines; i++) {
//         const numHairPoints = 20 + ((Math.random() * 10) | 0) - 5;
//
//         const hair_line = new Array(numHairPoints);
//
//         for (let j = 0; j < numHairPoints; j++) {
//             const index_start = (Math.random() * 140 + 20) | 0;
//             const idx = fastIndex(len - index_start, len);
//             const p = faceCountour[idx];
//             hair_line[j] = { x: p[0], y: p[1] };
//         }
//
//         results[i] = computeBezierCurve(hair_line, numHairPoints);
//     }
//
//     return results;
// }
//
// // ================= 轻优化版本 =================
//
// export function generateHairLines2(faceCountour, numHairLines = 100) {
//     const len = faceCountour.length - 2;
//     const results = [];
//     const pickedIndices = new Array(numHairLines);
//
//     for (let i = 0; i < numHairLines; i++) {
//         pickedIndices[i] = (Math.random() * 170 + 10) | 0;
//     }
//
//     pickedIndices.sort();
//
//     for (let i = 0; i < numHairLines; i++) {
//         const numHairPoints = 20 + ((Math.random() * 10) | 0) - 5;
//
//         const hair_line = new Array(numHairPoints);
//         const index_offset = pickedIndices[i];
//
//         const lower = randomFromInterval(0.8, 1.4);
//         const reverse = Math.random() > 0.5 ? 1 : -1;
//
//         for (let j = 0; j < numHairPoints; j++) {
//             const powerscale = randomFromInterval(0.1, 3);
//             const portion = (1 - (j / numHairPoints) ** powerscale) * (1 - lower) + lower;
//
//             const idx = fastIndex(len - (reverse * j + index_offset), len);
//             const p = faceCountour[idx];
//
//             hair_line[j] = { x: p[0] * portion, y: p[1] * portion };
//         }
//
//         let d = computeBezierCurve(hair_line, numHairPoints);
//
//         if (Math.random() > 0.7) d = d.reverse();
//
//         if (results.length === 0) {
//             results.push(d);
//             continue;
//         }
//
//         const last = results[results.length - 1];
//         const lastPt = last[last.length - 1];
//
//         const dx = d[0][0] - lastPt[0];
//         const dy = d[0][1] - lastPt[1];
//
//         if (Math.random() > 0.5 && dx * dx + dy * dy < 10000) {
//             results[results.length - 1] = last.concat(d);
//         } else {
//             results.push(d);
//         }
//     }
//
//     return results;
// }
//
// export function generateHairLines3(faceCountour, numHairLines = 100) {
//     const len = faceCountour.length - 2;
//     const results = [];
//
//     const pickedIndices = new Array(numHairLines);
//     for (let i = 0; i < numHairLines; i++) {
//         pickedIndices[i] = (Math.random() * 170 + 10) | 0;
//     }
//
//     pickedIndices.sort();
//
//     const splitPoint = (Math.random() * 200) | 0;
//
//     for (let i = 0; i < numHairLines; i++) {
//         const numHairPoints = 30 + ((Math.random() * 16) | 0) - 8;
//
//         const hair_line = new Array(numHairPoints);
//
//         const index_offset = pickedIndices[i];
//
//         let lower = randomFromInterval(1, 2.3);
//         if (Math.random() > 0.9) lower = randomFromInterval(0, 1);
//
//         const reverse = index_offset > splitPoint ? 1 : -1;
//
//         for (let j = 0; j < numHairPoints; j++) {
//             const powerscale = randomFromInterval(0.1, 3);
//             const portion = (1 - (j / numHairPoints) ** powerscale) * (1 - lower) + lower;
//
//             const idx = fastIndex(len - (reverse * j * 2 + index_offset), len);
//             const p = faceCountour[idx];
//
//             hair_line[j] = { x: p[0] * portion, y: p[1] };
//         }
//
//         results.push(computeBezierCurve(hair_line, numHairPoints));
//     }
//
//     return results;
// }
