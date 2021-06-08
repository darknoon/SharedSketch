//
//  ContentView.swift
//  Shared
//
//  Created by Andrew Pouliot on 6/7/21.
//

import SwiftUI
import Combine
import GroupActivities

struct ContentView: View {
    @State var session: GroupSession<DrawingExperience>?

    var body: some View {
        Button("New drawing…") {
            // This seems wrong… but OK.
            DrawingExperience(id: UUID()).activate()
        }
            .task {
                // Receive the new session asynchronously.
                for await drawingSession in DrawingExperience.sessions() {
                   session = drawingSession
                }
            }
            .fullScreenCover(item: $session) { session in
                DrawingView(session: session)
            }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


extension GroupSession : Identifiable where ActivityType == DrawingExperience {
    
}
