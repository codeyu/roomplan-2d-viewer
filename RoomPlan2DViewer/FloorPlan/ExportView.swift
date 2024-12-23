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
    @State private var isCreatingZIP = false
    @State private var showingShareSheet = false
    @State private var zipFileURL: URL?
    @State private var showingErrorAlert = false
    @State private var errorMessage: String = ""
    @State private var jsonString: String = ""

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Text("XML Data Preview")
                        .font(.headline)
                    ScrollView {
                        Text(xmlString)
                            .font(.system(.body, design: .monospaced))
                            .padding()
                    }
                }
                
                if isCreatingZIP {
                    ProgressView("Creating ZIP...")
                        .padding()
                        .background(Color.secondary.colorInvert())
                        .cornerRadius(10)
                }
            }
            .navigationBarTitle("Export Data", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Share ZIP") {
                    createAndShareZIP()
                }
            )
        }
        .onAppear {
            generateXML()
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = zipFileURL {
                ActivityViewController(activityItems: [url])
            }
        }
        .alert(isPresented: $showingErrorAlert) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
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
    
//    private func saveXMLToFile() {
//        let filename = "CapturedRoom_\(Date().timeIntervalSince1970).xml"
//        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
//        
//        do {
//            try xmlString.write(to: url, atomically: true, encoding: .utf8)
//            showingSaveSuccessAlert = true
//        } catch {
//            saveError = error
//            showingSaveErrorAlert = true
//        }
//    }
//    private func saveZIPFile() {
//        let filename = "RoomPlan_Export_\(Date().timeIntervalSince1970)"
//        let zipFilename = "\(filename).zip"
//        
//        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        let zipFileURL = documentsDirectory.appendingPathComponent(zipFilename)
//        
//        guard let archive = Archive(url: zipFileURL, accessMode: .create) else {
//            saveError = NSError(domain: "ZIPCreation", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create ZIP archive"])
//            showingSaveErrorAlert = true
//            return
//        }
//        
//        do {
//            // Add XML file to ZIP
//            let xmlData = xmlString.data(using: .utf8)!
//            try archive.addEntry(with: "\(filename).xml", type: .file, uncompressedSize: UInt32(xmlData.count), provider: { (position, size) -> Data in
//                return xmlData.subdata(in: position..<position+size)
//            })
//            
//            // Add image file to ZIP
//            if let imageData = floorPlanImage.pngData() {
//                try archive.addEntry(with: "\(filename).png", type: .file, uncompressedSize: UInt32(imageData.count), provider: { (position, size) -> Data in
//                    return imageData.subdata(in: position..<position+size)
//                })
//            }
//            
//            showingSaveSuccessAlert = true
//        } catch {
//            saveError = error
//            showingSaveErrorAlert = true
//        }
//    }
    private func createAndShareZIP() {
        isCreatingZIP = true
        
        let filename = "RoomPlan_Export_\(Date().timeIntervalSince1970)"
        let zipFilename = "\(filename).zip"
        
        let tempDirectory = FileManager.default.temporaryDirectory
        let zipFileURL = tempDirectory.appendingPathComponent(zipFilename)
        
        do {
            guard let archive = Archive(url: zipFileURL, accessMode: .create) else {
                throw NSError(domain: "ZIPCreation", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create ZIP archive"])
            }
            
            // Add XML file to ZIP
            let xmlData = xmlString.data(using: .utf8)!
            try archive.addEntry(with: "\(filename).xml", type: .file, uncompressedSize: UInt32(xmlData.count), provider: { (position, size) -> Data in
                return xmlData.subdata(in: position..<position+size)
            })
            
            // Add JSON file to ZIP
            let jsonString = generateJSON()
            let jsonData = jsonString.data(using: .utf8)!
            try archive.addEntry(with: "\(filename).json", type: .file, uncompressedSize: UInt32(jsonData.count), provider: { (position, size) -> Data in
                return jsonData.subdata(in: position..<position+size)
            })
            
            // Add image file to ZIP
            if let imageData = floorPlanImage.pngData() {
                try archive.addEntry(with: "\(filename).png", type: .file, uncompressedSize: UInt32(imageData.count), provider: { (position, size) -> Data in
                    return imageData.subdata(in: position..<position+size)
                })
            }
            
            // Add USDZ file to ZIP
            let usdzURL = tempDirectory.appendingPathComponent("\(filename).usdz")
            try capturedRoom.export(to: usdzURL)
            let usdzData = try Data(contentsOf: usdzURL)
            try archive.addEntry(with: "\(filename).usdz", type: .file, uncompressedSize: UInt32(usdzData.count), provider: { (position, size) -> Data in
                return usdzData.subdata(in: position..<position+size)
            })
            
            self.zipFileURL = zipFileURL
            
            DispatchQueue.main.async {
                isCreatingZIP = false
                showingShareSheet = true
            }
        } catch {
            DispatchQueue.main.async {
                isCreatingZIP = false
                errorMessage = "Error creating ZIP: \(error.localizedDescription)"
                showingErrorAlert = true
            }
        }
    }

    private func generateJSON() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let roomData: [String: Any] = [
            "walls": capturedRoom.walls.enumerated().map { index, wall in
                [
                    "id": index,
                    "dimensions": [
                        "x": wall.dimensions.x,
                        "y": wall.dimensions.y,
                        "z": wall.dimensions.z
                    ],
                    "transform": transformMatrixToArray(wall.transform)
                ]
            },
            "doors": capturedRoom.doors.enumerated().map { index, door in
                [
                    "id": index,
                    "dimensions": [
                        "x": door.dimensions.x,
                        "y": door.dimensions.y,
                        "z": door.dimensions.z
                    ],
                    "transform": transformMatrixToArray(door.transform)
                ]
            },
            "windows": capturedRoom.windows.enumerated().map { index, window in
                [
                    "id": index,
                    "dimensions": [
                        "x": window.dimensions.x,
                        "y": window.dimensions.y,
                        "z": window.dimensions.z
                    ],
                    "transform": transformMatrixToArray(window.transform)
                ]
            },
            "objects": capturedRoom.objects.enumerated().map { index, object in
                [
                    "id": index,
                    "category": categoryToString(object.category),
                    "dimensions": [
                        "x": object.dimensions.x,
                        "y": object.dimensions.y,
                        "z": object.dimensions.z
                    ],
                    "transform": transformMatrixToArray(object.transform)
                ]
            }
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: roomData, options: .prettyPrinted)
            return String(data: jsonData, encoding: .utf8) ?? "{}"
        } catch {
            print("Error generating JSON: \(error)")
            return "{}"
        }
    }
    
    private func transformMatrixToArray(_ matrix: simd_float4x4) -> [Float] {
        let columns = [matrix.columns.0, matrix.columns.1, matrix.columns.2, matrix.columns.3]
        return columns.flatMap { [$0.x, $0.y, $0.z, $0.w] }
    }
}

struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
