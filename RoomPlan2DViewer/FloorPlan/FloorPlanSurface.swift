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
        let doorLength = CGFloat(capturedSurface.dimensions.x) * scalingFactor
        let doorColor = SKColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 1.0) // Light blue color
        
        // Hide the wall underneath the door
        let hideWallPath = createPath(from: pointA, to: pointB)
        let hideWallShape = createShapeNode(from: hideWallPath)
        hideWallShape.strokeColor = floorPlanBackgroundColor
        hideWallShape.lineWidth = hideSurfaceWith
        hideWallShape.zPosition = hideSurfaceZPosition
        
        // The door's arc parameters
        let arcCenter = pointA
        let arcRadius = doorLength
        let startAngle: CGFloat = 0 // Start from 0 degrees (pointing right)
        let endAngle: CGFloat = .pi / 2 // End at 90 degrees (pointing up)
        
        // Calculate the end point of the door (where the arc ends)
        let doorEndPoint = CGPoint(x: arcCenter.x + arcRadius * cos(endAngle),
                                y: arcCenter.y + arcRadius * sin(endAngle))
        
        // The door itself (solid line)
        let doorPath = CGMutablePath()
        doorPath.move(to: pointA)
        doorPath.addLine(to: doorEndPoint)
        
        let doorShape = createShapeNode(from: doorPath)
        doorShape.strokeColor = doorColor
        doorShape.lineWidth = doorWidth
        doorShape.zPosition = doorZPosition
        
        // The door's arc (90 degrees, dotted line)
        let doorArcNode = SKNode()
        doorArcNode.zPosition = doorArcZPosition
        
        // Create dotted line effect
        let dashLength: CGFloat = 2.0
        let gapLength: CGFloat = 2.0
        var angle = startAngle
        while angle < endAngle {
            let startPoint = CGPoint(x: arcCenter.x + arcRadius * cos(angle),
                                    y: arcCenter.y + arcRadius * sin(angle))
            angle += (dashLength / arcRadius)
            let endPoint = CGPoint(x: arcCenter.x + arcRadius * cos(angle),
                                y: arcCenter.y + arcRadius * sin(angle))
            
            let dashPath = CGMutablePath()
            dashPath.move(to: startPoint)
            dashPath.addLine(to: endPoint)
            
            let dashNode = SKShapeNode(path: dashPath)
            dashNode.strokeColor = doorColor
            dashNode.lineWidth = doorArcWidth
            
            doorArcNode.addChild(dashNode)
            
            angle += (gapLength / arcRadius)
        }
        
        // Add dimension line and label
        let doorDimPointA = CGPoint(x: pointADim.x, y: pointADim.y - doorWindowDimensionOffset)
        let doorDimPointB = CGPoint(x: pointBDim.x, y: pointBDim.y - doorWindowDimensionOffset)
        
        let dimensionsPath = createDimPath(from: doorDimPointA, to: doorDimPointB)
        let dimensionsShape = createDimNode(from: dimensionsPath)
        dimensionsShape.lineCap = .round
        
        let dimensionsLabel = createDimLabel()
        dimensionsLabel.position.y -= doorWindowDimensionOffset
        
        addChild(hideWallShape)
        addChild(doorShape)
        addChild(doorArcNode)
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
        // Hide the wall underneath the window
        let hidePath = createPath(from: pointA, to: pointB)
        let hideWallShape = createShapeNode(from: hidePath)
        hideWallShape.strokeColor = floorPlanBackgroundColor
        hideWallShape.lineWidth = hideSurfaceWith
        hideWallShape.zPosition = hideSurfaceZPosition
        // 创建白色背景
        let backgroundPath = createPath(from: pointA, to: pointB)
        let backgroundShape = createShapeNode(from: backgroundPath)
        backgroundShape.strokeColor = .white
        backgroundShape.lineWidth = windowWidth + 4 // 稍微宽一些，以确保完全覆盖墙壁
        backgroundShape.zPosition = hideSurfaceZPosition

        // 创建两条平行线
        let windowPath = CGMutablePath()
        let lineSpacing: CGFloat = 3.0 // 两条线之间的间距
        
        // 上面的线
        windowPath.move(to: CGPoint(x: pointA.x, y: pointA.y + lineSpacing/2))
        windowPath.addLine(to: CGPoint(x: pointB.x, y: pointB.y + lineSpacing/2))
        
        // 下面的线
        windowPath.move(to: CGPoint(x: pointA.x, y: pointA.y - lineSpacing/2))
        windowPath.addLine(to: CGPoint(x: pointB.x, y: pointB.y - lineSpacing/2))

        let windowShape = SKShapeNode(path: windowPath)
        windowShape.strokeColor = windowColor
        windowShape.lineWidth = 1 // 使用较细的线条
        windowShape.zPosition = windowZPosition

        // 添加尺寸线和标签
        let windowDimPointA = CGPoint(x: pointADim.x, y: pointADim.y - doorWindowDimensionOffset)
        let windowDimPointB = CGPoint(x: pointBDim.x, y: pointBDim.y - doorWindowDimensionOffset)
        
        let dimensionsPath = createDimPath(from: windowDimPointA, to: windowDimPointB)
        let dimensionsShape = createDimNode(from: dimensionsPath)
        dimensionsShape.lineCap = .round
        
        let dimensionsLabel = createDimLabel()
        dimensionsLabel.position.y -= doorWindowDimensionOffset // 调整标签位置

        addChild(hideWallShape)
        addChild(backgroundShape)
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
