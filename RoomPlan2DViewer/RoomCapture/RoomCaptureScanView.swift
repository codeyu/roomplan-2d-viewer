//
//  RoomCaptureView.swift
//  RoomPlan 2D
//
//  Created by CodeYu on 22/10/2024.
//

import SwiftUI
import _SpriteKit_SwiftUI

struct RoomCaptureScanView: View {
    // MARK: - Properties & State
    private let model = RoomCaptureModel.shared
    
    @State private var isScanning = false
    @State private var isShowingFloorPlan = false
    
    // MARK: - View Body
    var body: some View {
        ZStack {
            // The RoomCaptureView
            RoomCaptureRepresentable()
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                HStack {
                    if !isScanning {
                        Button("Start New Scanning") {
                            // 重置当前的扫描状态
                            model.finalRoom = nil
                            isShowingFloorPlan = false
                            // 开始新的扫描
                            startSession()
                        }
                        .padding()
                        .background(Color("AccentColor"))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .fontWeight(.bold)
                    }
                    
                    // The button changes according to the state of isScanning
                    Button(isScanning ? "Done" : "View 2D floor plan") {
                        if isScanning {
                            stopSession()
                        } else {
                            isShowingFloorPlan = true
                        }
                    }
                    .padding()
                    .background(Color("AccentColor"))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .fontWeight(.bold)
                }
                .padding(.bottom)
            }
        }
        
        // Start the scan session when the view appears
        .onAppear {
            startSession()
        }
        
        // Show the floor plan in full screen
        .sheet(isPresented: $isShowingFloorPlan) {
            FloorPlanView(capturedRoom: model.finalRoom!)
        }
    }
    
    private func startSession() {
        isScanning = true
        model.startSession()
        
        // Prevent the screen from sleeping
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    private func stopSession() {
        isScanning = false
        model.stopSession()
        
        // Enable the screen to sleep again
        UIApplication.shared.isIdleTimerDisabled = false
    }
}

struct RoomCaptureScanView_Previews: PreviewProvider {
    static var previews: some View {
        RoomCaptureScanView()
    }
}
