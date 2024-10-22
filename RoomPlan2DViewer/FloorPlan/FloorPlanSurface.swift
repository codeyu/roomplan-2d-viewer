//
//  FloorPlanSurface.swift
//  RoomPlan 2D
//
//  Created by CodeYu on 22/10/2024.
//

import SpriteKit
import RoomPlan

class FloorPlanSurface: SKNode {
    
    private let capturedSurface: CapturedRoom.Surface
    private static var largestSurface: CapturedRoom.Surface?
    
    // MARK: - Computed properties
    
    private var halfLength: CGFloat {
        return CGFloat(capturedSurface.dimensions.x) * scalingFactor / 2
    }
    
    private var pointA: CGPoint {
        return CGPoint(x: -halfLength, y: 0)
    }
    
    private var pointB: CGPoint {
        return CGPoint(x: halfLength, y: 0)
    }
    private var pointC: CGPoint {
        return pointB.rotateAround(point: pointA, by: 0.25 * .pi)
    }
    private var pointADim: CGPoint {
        return CGPoint(x: -halfLength, y: -dimensionLineDistFromSurface)
    }
    
    private var pointBDim: CGPoint {
        return CGPoint(x: halfLength, y: -dimensionLineDistFromSurface)
    }
    
    // MARK: - Init
    
    init(capturedSurface: CapturedRoom.Surface, largestSurface: CapturedRoom.Surface?) {
        self.capturedSurface = capturedSurface
        FloorPlanSurface.largestSurface = largestSurface
        
        super.init()
        
        // Set the surface's position using the transform matrix
        let surfacePositionX = -CGFloat(capturedSurface.transform.position.x) * scalingFactor
        let surfacePositionY = CGFloat(capturedSurface.transform.position.z) * scalingFactor
        self.position = CGPoint(x: surfacePositionX, y: surfacePositionY)
            .rotateAround(
                point: .zero,
                by: -CGFloat(FloorPlanSurface.largestSurface?.transform.eulerAngles.y ?? 0)
            )
        
        // Set the surface's zRotation using the transform matrix
        self.zRotation = -CGFloat(capturedSurface.transform.eulerAngles.z - capturedSurface.transform.eulerAngles.y + (FloorPlanSurface.largestSurface?.transform.eulerAngles.y ?? 0))
        
        // Draw the right surface
        switch capturedSurface.category {
        case .door:
            drawDoor()
        case .opening:
            drawOpening()
        case .wall:
            drawWall()
        case .window:
            drawWindow()
        case .floor:
            drawFloor()
        @unknown default:
            drawWall()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Draw
    private func drawFloor(){
        //TODO
    }
    private func drawDoor() {
        let hideWallPath = createPath(from: pointA, to: pointB)
        let doorPath = createPath(from: pointA, to: pointC)

        // Hide the wall underneath the door
        let hideWallShape = createShapeNode(from: hideWallPath)
        hideWallShape.strokeColor = floorPlanBackgroundColor
        hideWallShape.lineWidth = hideSurfaceWith
        hideWallShape.zPosition = hideSurfaceZPosition
        
        // The door itself
        let doorShape = createShapeNode(from: doorPath)
        doorShape.strokeColor = doorColor
        doorShape.lineWidth = doorWidth
        doorShape.lineCap = .square
        doorShape.zPosition = doorZPosition
        
        // The door's arc
        let doorArcPath = CGMutablePath()
        doorArcPath.addArc(
            center: pointA,
            radius: halfLength * 2,
            startAngle: 0.25 * .pi,
            endAngle: 0,
            clockwise: true
        )
        
        let doorArcShape = createShapeNode(from: doorArcPath)
        doorArcShape.strokeColor = doorColor
        doorArcShape.lineWidth = doorWidth
        doorArcShape.zPosition = doorArcZPosition
        
        // Add dimension line and label
        let doorDimPointA = CGPoint(x: pointADim.x, y: pointADim.y - doorWindowDimensionOffset)
        let doorDimPointB = CGPoint(x: pointBDim.x, y: pointBDim.y - doorWindowDimensionOffset)
        
        let dimensionsPath = createDimPath(from: doorDimPointA, to: doorDimPointB)
        let dimensionsShape = createDimNode(from: dimensionsPath)
        dimensionsShape.lineCap = .round
        
        let dimensionsLabel = createDimLabel()
        dimensionsLabel.position.y -= doorWindowDimensionOffset // 调整标签位置
        
        addChild(hideWallShape)
        addChild(doorShape)
        addChild(doorArcShape)
        addChild(dimensionsShape)
        addChild(dimensionsLabel)
    }
    
    private func drawOpening() {
        let openingPath = createPath(from: pointA, to: pointB)
        
        // Hide the wall underneath the opening
        let hideWallShape = createShapeNode(from: openingPath)
        hideWallShape.strokeColor = floorPlanBackgroundColor
        hideWallShape.lineWidth = hideSurfaceWith
        hideWallShape.zPosition = hideSurfaceZPosition
        
        addChild(hideWallShape)
    }
    
    private func drawWall() {
        let wallPath = createPath(from: pointA, to: pointB)
        let wallShape = createShapeNode(from: wallPath)
        wallShape.strokeColor = wallColor
        wallShape.lineWidth = wallWidth
        wallShape.lineCap = .round
        
        let dimensionsPath = createDimPath(from: pointADim, to: pointBDim)
        let dimensionsShape = createDimNode(from: dimensionsPath)
        dimensionsShape.lineCap = .round
        
        let dimensionsLabel = createDimLabel()
        
        addChild(wallShape)
        addChild(dimensionsShape)
        addChild(dimensionsLabel)
    }
    
    private func drawWindow() {
        let windowPath = createPath(from: pointA, to: pointB)
        
        // Hide the wall underneath the window
        let hideWallShape = createShapeNode(from: windowPath)
        hideWallShape.strokeColor = floorPlanBackgroundColor
        hideWallShape.lineWidth = hideSurfaceWith
        hideWallShape.zPosition = hideSurfaceZPosition
        
        // The window itself (dashed line)
        let windowShape = SKShapeNode()
        let dashedPath = CGMutablePath()
        let dashLength: CGFloat = 6.0
        let gapLength: CGFloat = 3.0
        let endPoint = CGPoint(x: pointB.x - pointA.x, y: pointB.y - pointA.y)
        var currentPoint = CGPoint.zero
        var remainingLength = sqrt(endPoint.x * endPoint.x + endPoint.y * endPoint.y)
        let angle = atan2(endPoint.y, endPoint.x)
        
        while remainingLength > 0 {
            let dashDistance = min(dashLength, remainingLength)
            let nextPoint = CGPoint(x: currentPoint.x + dashDistance * cos(angle),
                                    y: currentPoint.y + dashDistance * sin(angle))
            dashedPath.move(to: currentPoint)
            dashedPath.addLine(to: nextPoint)
            currentPoint = nextPoint
            remainingLength -= dashDistance
            
            if remainingLength > 0 {
                let gapDistance = min(gapLength, remainingLength)
                currentPoint = CGPoint(x: currentPoint.x + gapDistance * cos(angle),
                                       y: currentPoint.y + gapDistance * sin(angle))
                remainingLength -= gapDistance
            }
        }
        
        windowShape.path = dashedPath
        windowShape.strokeColor = windowColor
        windowShape.lineWidth = windowWidth
        windowShape.zPosition = windowZPosition
        windowShape.position = pointA
        
        // Add dimension line and label
        let windowDimPointA = CGPoint(x: pointADim.x, y: pointADim.y - doorWindowDimensionOffset)
        let windowDimPointB = CGPoint(x: pointBDim.x, y: pointBDim.y - doorWindowDimensionOffset)
        
        let dimensionsPath = createDimPath(from: windowDimPointA, to: windowDimPointB)
        let dimensionsShape = createDimNode(from: dimensionsPath)
        dimensionsShape.lineCap = .round
        
        let dimensionsLabel = createDimLabel()
        dimensionsLabel.position.y -= doorWindowDimensionOffset // 调整标签位置
        
        addChild(hideWallShape)
        addChild(windowShape)
        addChild(dimensionsShape)
        addChild(dimensionsLabel)
    }
    
    // MARK: - Helper functions
    
    private func createPath(from pointA: CGPoint, to pointB: CGPoint) -> CGMutablePath {
        let path = CGMutablePath()
        path.move(to: pointA)
        path.addLine(to: pointB)
        
        return path
    }
    
    private func createShapeNode(from path: CGPath) -> SKShapeNode {
        let shapeNode = SKShapeNode(path: path)
        // 移除默认的颜色设置，因为我们现在在每个具体的绘制方法中设置颜色
        return shapeNode
    }
    
    // private func drawMeasurement() {
    //     let length = CGFloat(capturedSurface.dimensions.x) * scalingFactor
        
    //     // 计算测量线的位置（墙的外围）
    //     let measurementOffset = surfaceWith / 2 + measurementLineOffset
        
    //     // 创建测量线
    //     let measurementPath = CGMutablePath()
    //     measurementPath.move(to: CGPoint(x: -length/2, y: measurementOffset))
    //     measurementPath.addLine(to: CGPoint(x: length/2, y: measurementOffset))
        
    //     let measurementLine = SKShapeNode(path: measurementPath)
    //     measurementLine.strokeColor = measurementLineColor
    //     measurementLine.lineWidth = measurementLineWidth
        
    //     // 添加截断符
    //     let endCapLength: CGFloat = 10
    //     let leftEndCap = SKShapeNode(path: createEndCapPath(at: CGPoint(x: -length/2, y: measurementOffset), length: endCapLength))
    //     let rightEndCap = SKShapeNode(path: createEndCapPath(at: CGPoint(x: length/2, y: measurementOffset), length: endCapLength))
    //     leftEndCap.strokeColor = measurementLineColor
    //     rightEndCap.strokeColor = measurementLineColor
    //     leftEndCap.lineWidth = measurementLineWidth
    //     rightEndCap.lineWidth = measurementLineWidth
        
    //     // 创建测量文本
    //     let measurementText = SKLabelNode(text: String(format: "%.2f m", capturedSurface.dimensions.x))
    //     measurementText.fontSize = measurementTextFontSize
    //     measurementText.fontColor = measurementTextColor
    //     measurementText.position = CGPoint(x: 0, y: measurementOffset + endCapLength + 5)
    //     measurementText.verticalAlignmentMode = .bottom
        
    //     addChild(measurementLine)
    //     addChild(leftEndCap)
    //     addChild(rightEndCap)
    //     addChild(measurementText)
    // }
    
    // private func createEndCapPath(at point: CGPoint, length: CGFloat) -> CGPath {
    //     let path = CGMutablePath()
    //     path.move(to: CGPoint(x: point.x, y: point.y - length/2))
    //     path.addLine(to: CGPoint(x: point.x, y: point.y + length/2))
    //     return path
    // }
    
    private func createDimPath(from pointA: CGPoint, to pointB: CGPoint) -> CGMutablePath {
        let path = CGMutablePath()
        // edges of dimension line
        path.move(to: CGPoint(x: pointA.x, y: pointA.y-surfaceWith))
        path.addLine(to: CGPoint(x: pointA.x, y: pointA.y+surfaceWith))
        path.move(to: CGPoint(x: pointB.x, y: pointB.y-surfaceWith))
        path.addLine(to: CGPoint(x: pointB.x, y: pointB.y+surfaceWith))
        
        // main line with gap for label
        path.move(to: pointA)
        path.addLine(to: CGPoint(x: -dimensionLabelWidth/2, y: pointA.y))
        path.move(to: pointB)
        path.addLine(to: CGPoint(x: dimensionLabelWidth/2, y: pointB.y))
        
        return path
    }
    
    private func createDimLabel() -> SKLabelNode {
        let dimMeters = self.capturedSurface.dimensions.x
        
        // 根据尺寸大小选择合适的单位（米或厘米）
        let (value, unit) = if dimMeters < 1 {
            (dimMeters * 100, "cm")
        } else {
            (dimMeters, "m")
        }
        
        // 格式化标签文本
        let formattedText = String(format: "%.2f %@", value, unit)
        
        let label = SKLabelNode(text: formattedText)
        label.fontColor = floorPlanSurfaceColor
        label.position.y = -dimensionLineDistFromSurface - labelFontSize/2
        label.fontSize = labelFontSize
        label.fontName = labelFont
        
        return label
    }
    
    private func createDimNode(from path: CGPath) -> SKShapeNode {
        let shapeNode = SKShapeNode(path: path)
        shapeNode.strokeColor = floorPlanSurfaceColor
        shapeNode.lineWidth = dimensionWidth
        
        return shapeNode
    }
}
