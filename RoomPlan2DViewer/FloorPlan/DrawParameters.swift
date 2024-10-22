//
//  DrawParameters.swift
//  RoomPlan 2D
//
//  Created by Dennis van Oosten on 12/03/2023.
//

import UIKit

// Universal scaling factor
let scalingFactor: CGFloat = 200

// Colors
let floorPlanBackgroundColor = UIColor(named: "BackgroundColor")!
let floorPlanSurfaceColor = UIColor(named: "AccentColor")!

// Line widths
let surfaceWith: CGFloat = 22.0
let hideSurfaceWith: CGFloat = 24.0
let windowWidth: CGFloat = 8.0
let doorArcWidth: CGFloat = 8.0
let objectOutlineWidth: CGFloat = 8.0

// zPositions
let hideSurfaceZPosition: CGFloat = 1

let windowZPosition: CGFloat = 10

let doorZPosition: CGFloat = 20
let doorArcZPosition: CGFloat = 21

let objectZPosition: CGFloat = 30
let objectOutlineZPosition: CGFloat = 31

// 尺度标记参数
let measurementLineOffset: CGFloat = 5.0  // 减小这个值，使测量线更靠近墙
let measurementLineWidth: CGFloat = 1.0   // 可以减小线宽使其看起来更精细
let measurementTextFontSize: CGFloat = 10.0
let measurementTextColor = UIColor.darkGray
let measurementLineColor = UIColor.darkGray

// 新增参数
let dimensionLineDistFromSurface: CGFloat = 30.0
let dimensionLabelWidth: CGFloat = 50.0
let dimensionWidth: CGFloat = 1.0
let labelFontSize: CGFloat = 12.0
let labelFont = "Helvetica"
let metersToInchesFactor: CGFloat = 39.3701
