//
//  ExportView.swift
//  RoomPlan2DViewer
//
//  Created by user on 2024/10/23.
//

import SwiftUI
import RoomPlan
import SceneKit
import ZIPFoundation
import UniformTypeIdentifiers

struct ExportView: View {
    let capturedRoom: CapturedRoom
    let floorPlanImage: UIImage
    @Environment(\.presentationMode) var presentationMode
    @State private var xmlString: String = ""
    @State private var showingSaveSuccessAlert = false
    @State private var showingSaveErrorAlert = false
    @State private var saveError: Error?

    var body: some View {
        NavigationView {
            VStack {
                Text("XML Data Preview")
                    .font(.headline)
                ScrollView {
                    Text(xmlString)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                }
            }
            .navigationBarTitle("Preview XML", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save ZIP") {
                    saveZIPFile()
                }
            )
        }
        .onAppear {
            generateXML()
        }
        .alert(isPresented: $showingSaveSuccessAlert) {
            Alert(
                title: Text("Success"),
                message: Text("ZIP file has been saved successfully."),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .alert(isPresented: $showingSaveErrorAlert) {
            Alert(
                title: Text("Save Error"),
                message: Text(saveError?.localizedDescription ?? "An unknown error occurred while saving the file."),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func generateXML() {
        var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        xml += "<Room>\n"
        
        // Calculate room height (assuming it's the maximum height of all walls)
        let roomHeight = capturedRoom.walls.map { $0.dimensions.y }.max() ?? 0
        xml += "  <SceneHigh value=\"\(Int(roomHeight * 100))\"/>\n"
        
        // Walls
        xml += "  <WallInfo num=\"\(capturedRoom.walls.count)\"/>\n"
        for (index, wall) in capturedRoom.walls.enumerated() {
            let startPoint = transformPoint(SIMD3<Float>(0, 0, 0), wall.transform)
            let endPoint = transformPoint(SIMD3<Float>(wall.dimensions.x, 0, 0), wall.transform)
            xml += "  <WallData Type=\"0\" Width=\"\(Int(wall.dimensions.z * 100))\" "
            xml += "StartX=\"\(startPoint.x)\" StartY=\"\(startPoint.z)\" StartZ=\"0\" "
            xml += "EndX=\"\(endPoint.x)\" EndY=\"\(endPoint.z)\" EndZ=\"0\" ShowLabel=\"1\"/>\n"
        }
        
        // Doors
        xml += "  <DoorInfo num=\"\(capturedRoom.doors.count)\"/>\n"
        for door in capturedRoom.doors {
            let position = transformPoint(SIMD3<Float>(door.dimensions.x / 2, 0, 0), door.transform)
            let rotation = extractRotationY(door.transform)
            xml += "  <DoorData PosX=\"\(position.x)\" PosY=\"\(position.z)\" PosZ=\"0\" "
            xml += "Length=\"\(Int(door.dimensions.x * 100))\" Width=\"\(Int(door.dimensions.z * 100))\" Height=\"\(Int(door.dimensions.y * 100))\" "
            xml += "Rotate=\"\(rotation)\" Mode=\"0\" Mirror=\"0\" ModelType=\"3ds\" "
            xml += "source=\"\" numTexture=\"1\" ReplaceMaterial=\"0\" DoorStyle=\"100\" Material=\"\">\n"
            xml += "    <Texture></Texture>\n"
            xml += "  </DoorData>\n"
        }
        
        // Windows
        xml += "  <WinInfo num=\"\(capturedRoom.windows.count)\"/>\n"
        for window in capturedRoom.windows {
            let position = transformPoint(SIMD3<Float>(window.dimensions.x / 2, 0, 0), window.transform)
            let rotation = extractRotationY(window.transform)
            xml += "  <WinData PosX=\"\(position.x)\" PosY=\"\(position.z)\" PosZ=\"0\" "
            xml += "Length=\"\(Int(window.dimensions.x * 100))\" Width=\"\(Int(window.dimensions.z * 100))\" Height=\"\(Int(window.dimensions.y * 100))\" "
            xml += "Rotate=\"\(rotation)\" Mode=\"0\" Dist=\"100\" "
            xml += "source=\"\" ModelType=\"3ds\" type=\"0\" "
            xml += "index=\"undefined\" indexName=\"undefined\" int=\"undefined\" investBelong=\"undefined\" putonModel=\"undefined\" "
            xml += "constructionMode=\"undefined\" ReplaceMaterial=\"0\" Material=\"\">\n"
            xml += "    <Texture></Texture>\n"
            xml += "  </WinData>\n"
        }
        
        xml += "</Room>"
        
        xmlString = xml
    }

    private func transformPoint(_ point: SIMD3<Float>, _ transform: simd_float4x4) -> SIMD3<Float> {
        let homogeneousPoint = SIMD4<Float>(point.x, point.y, point.z, 1)
        let transformedPoint = transform * homogeneousPoint
        return SIMD3<Float>(transformedPoint.x, transformedPoint.y, transformedPoint.z) / transformedPoint.w
    }

    private func extractRotationY(_ transform: simd_float4x4) -> Float {
        return atan2(transform.columns.0.z, transform.columns.0.x)
    }
    
    private func generateXML_bak() {
        var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        xml += "<CapturedRoom>\n"
        
        // Add walls
        xml += "  <Walls>\n"
        for (index, wall) in capturedRoom.walls.enumerated() {
            xml += "    <Wall id=\"\(index)\">\n"
            xml += "      <Dimensions>\(formatSIMD3(wall.dimensions))</Dimensions>\n"
            xml += "      <Transform>\(formatMatrix4x4(wall.transform))</Transform>\n"
            xml += "    </Wall>\n"
        }
        xml += "  </Walls>\n"
        
        // Add doors
        xml += "  <Doors>\n"
        for (index, door) in capturedRoom.doors.enumerated() {
            xml += "    <Door id=\"\(index)\">\n"
            xml += "      <Dimensions>\(formatSIMD3(door.dimensions))</Dimensions>\n"
            xml += "      <Transform>\(formatMatrix4x4(door.transform))</Transform>\n"
            xml += "    </Door>\n"
        }
        xml += "  </Doors>\n"
        
        // Add windows
        xml += "  <Windows>\n"
        for (index, window) in capturedRoom.windows.enumerated() {
            xml += "    <Window id=\"\(index)\">\n"
            xml += "      <Dimensions>\(formatSIMD3(window.dimensions))</Dimensions>\n"
            xml += "      <Transform>\(formatMatrix4x4(window.transform))</Transform>\n"
            xml += "    </Window>\n"
        }
        xml += "  </Windows>\n"
        
        // Add objects
        xml += "  <Objects>\n"
        for (index, object) in capturedRoom.objects.enumerated() {
            xml += "    <Object id=\"\(index)\">\n"
            xml += "      <Category>\(categoryToString(object.category))</Category>\n"
            xml += "      <Dimensions>\(formatSIMD3(object.dimensions))</Dimensions>\n"
            xml += "      <Transform>\(formatMatrix4x4(object.transform))</Transform>\n"
            xml += "    </Object>\n"
        }
        xml += "  </Objects>\n"
        
        xml += "</CapturedRoom>"
        
        xmlString = xml
    }

    private func formatSIMD3(_ vector: SIMD3<Float>) -> String {
        return String(format: "%.2f,%.2f,%.2f", vector.x, vector.y, vector.z)
    }

    private func formatMatrix4x4(_ matrix: simd_float4x4) -> String {
        let columns = [matrix.columns.0, matrix.columns.1, matrix.columns.2, matrix.columns.3]
        let elements = columns.flatMap { [$0.x, $0.y, $0.z, $0.w] }
        return elements.map { String(format: "%.2f", $0) }.joined(separator: ",")
    }

    private func categoryToString(_ category: CapturedRoom.Object.Category) -> String {
        switch category {
        case .storage:
            return "Storage"
        case .refrigerator:
            return "Refrigerator"
        case .bathtub:
            return "Bathtub"
        case .bed:
            return "Bed"
        case .sink:
            return "Sink"
        case .table:
            return "Table"
        case .chair:
            return "Chair"
        case .sofa:
            return "Sofa"
        case .television:
            return "Television"
        case .toilet:
            return "Toilet"
        case .washerDryer:
            return "WasherDryer"
        case .fireplace:
            return "Fireplace"
        case .oven:
            return "Oven"
        case .dishwasher:
            return "Dishwasher"
        case .stove:
            return "Stove"
        case .stairs:
            return "Stairs"
        @unknown default:
            return "Unknown"
        }
    }
    
    private func saveXMLToFile() {
        let filename = "CapturedRoom_\(Date().timeIntervalSince1970).xml"
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
        
        do {
            try xmlString.write(to: url, atomically: true, encoding: .utf8)
            showingSaveSuccessAlert = true
        } catch {
            saveError = error
            showingSaveErrorAlert = true
        }
    }
    private func saveZIPFile() {
        let filename = "RoomPlan_Export_\(Date().timeIntervalSince1970)"
        let zipFilename = "\(filename).zip"
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let zipFileURL = documentsDirectory.appendingPathComponent(zipFilename)
        
        guard let archive = Archive(url: zipFileURL, accessMode: .create) else {
            saveError = NSError(domain: "ZIPCreation", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create ZIP archive"])
            showingSaveErrorAlert = true
            return
        }
        
        do {
            // Add XML file to ZIP
            let xmlData = xmlString.data(using: .utf8)!
            try archive.addEntry(with: "\(filename).xml", type: .file, uncompressedSize: UInt32(xmlData.count), provider: { (position, size) -> Data in
                return xmlData.subdata(in: position..<position+size)
            })
            
            // Add image file to ZIP
            if let imageData = floorPlanImage.pngData() {
                try archive.addEntry(with: "\(filename).png", type: .file, uncompressedSize: UInt32(imageData.count), provider: { (position, size) -> Data in
                    return imageData.subdata(in: position..<position+size)
                })
            }
            
            showingSaveSuccessAlert = true
        } catch {
            saveError = error
            showingSaveErrorAlert = true
        }
    }
}
