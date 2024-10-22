//
//  RoomCaptureRepresentable.swift
//  RoomPlan 2D
//
//  Created by CodeYu on 22/10/2024.
//

import RoomPlan
import SwiftUI

struct RoomCaptureRepresentable: UIViewRepresentable {
        
    func makeUIView(context: Context) -> RoomCaptureView {
        return RoomCaptureModel.shared.roomCaptureView
    }
    
    func updateUIView(_ uiView: RoomCaptureView, context: Context) {
    }
    
}
