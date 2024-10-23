//
//  ExportView.swift
//  RoomPlan2DViewer
//
//  Created by user on 2024/10/23.
//

import SwiftUI
import RoomPlan
import SceneKit

struct ExportView: View {
    let capturedRoom: CapturedRoom
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
            .navigationBarTitle("Export XML", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveXMLToFile()
                }
            )
        }
        .onAppear {
            generateXML()
        }
        .alert(isPresented: $showingSaveSuccessAlert) {
            Alert(
                title: Text("Success"),
                message: Text("XML file has been saved successfully."),
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
}
