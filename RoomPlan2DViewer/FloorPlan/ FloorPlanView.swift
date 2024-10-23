//
//   FloorPlanView.swift
//  RoomPlan2DViewer
//
//  Created by user on 2024/10/23.
//

import SwiftUI
import SpriteKit
import RoomPlan

struct FloorPlanView: View {
    @Environment(\.presentationMode) var presentationMode
    let capturedRoom: CapturedRoom

    var body: some View {
        ZStack {
            SpriteView(scene: FloorPlanScene(capturedRoom: capturedRoom))
                .ignoresSafeArea()
        }
        .navigationBarHidden(true)
    }
}
