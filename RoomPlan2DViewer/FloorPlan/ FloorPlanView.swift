import SwiftUI
import SpriteKit
import RoomPlan
import Photos
import UniformTypeIdentifiers

struct FloorPlanView: View {
    @Environment(\.presentationMode) var presentationMode
    let capturedRoom: CapturedRoom
    @State private var scene: FloorPlanScene?
    @State private var showingSaveAlert = false
    @State private var saveAlertMessage = ""
    @State private var showingExportView = false
    @State private var floorPlanImage: UIImage?
    
    var body: some View {
        ZStack {
            SpriteView(scene: scene ?? FloorPlanScene(capturedRoom: capturedRoom))
                .ignoresSafeArea()
                .onAppear {
                    if scene == nil {
                        scene = FloorPlanScene(capturedRoom: capturedRoom)
                    }
                }
            
            VStack {
                Spacer()
                
                HStack {
                    Button(action: {
                        requestPhotoLibraryPermission()
                    }) {
                        Text("Save Image")
                            .padding()
                            .background(Color("AccentColor"))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .fontWeight(.bold)
                    }
                    
                    Button(action: {
                        showingExportView = true
                    }) {
                        Text("Export XML")
                            .padding()
                            .background(Color("AccentColor"))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .fontWeight(.bold)
                    }
                }
                .padding(.bottom)
            }
        }
        .navigationBarHidden(true)
        .alert(isPresented: $showingSaveAlert) {
            Alert(title: Text("Save Image"), message: Text(saveAlertMessage), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $showingExportView) {
            if let image = floorPlanImage {
                ExportView(capturedRoom: capturedRoom, floorPlanImage: image)
            }
        }
        .onChange(of: showingExportView) { newValue in
            if newValue {
                captureFloorPlanImage()
            }
        }
    }
    private func captureFloorPlanImage() {
        guard let scene = scene, let view = scene.view else { return }
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        floorPlanImage = renderer.image { ctx in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
    }
    private func requestPhotoLibraryPermission() {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    saveImage()
                case .denied, .restricted:
                    saveAlertMessage = "Please allow access to your photo library in Settings to save images."
                    showingSaveAlert = true
                case .notDetermined:
                    saveAlertMessage = "Unable to save image. Please try again."
                    showingSaveAlert = true
                @unknown default:
                    saveAlertMessage = "An unknown error occurred."
                    showingSaveAlert = true
                }
            }
        }
    }
    
    private func saveImage() {
        guard let scene = scene else { return }
        
        let texture = scene.view?.texture(from: scene)
        guard let image = texture?.cgImage() else { return }
        
        let uiImage = UIImage(cgImage: image)
        
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: uiImage)
        } completionHandler: { success, error in
            DispatchQueue.main.async {
                if success {
                    saveAlertMessage = "The floor plan has been saved to your photos."
                } else {
                    saveAlertMessage = "Failed to save image: \(error?.localizedDescription ?? "Unknown error")"
                }
                showingSaveAlert = true
            }
        }
    }
}
