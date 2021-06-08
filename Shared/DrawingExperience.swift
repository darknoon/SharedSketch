//
//  DrawingExperience.swift
//  SharedSketch
//
//  Created by Andrew Pouliot on 6/7/21.
//

import GroupActivities
import Foundation
import Combine

struct DrawingExperience: GroupActivity {
    typealias Identifier = UUID
    var id: Identifier = .init()
    static let activityIdentifier = "com.darknoon.drawing"
    
    var metadata: GroupActivityMetadata {
        var m = GroupActivityMetadata()
        m.title = "Shared Drawing ID \(id)"
        m.fallbackURL = URL(string: "https://darknoon.com/drawing/\(id)")
        return m
    }
}

class DrawingSessionManager : ObservableObject {
    let groupSession: GroupSession<DrawingExperience>
    let messenger: GroupSessionMessenger
    
    let localData: AnyPublisher<Data, DrawingView.Failure>

    private var subscriptions: Set<AnyCancellable> =  []

    init(groupSession: GroupSession<DrawingExperience>, item: DrawingExperience, localData: AnyPublisher<Data, DrawingView.Failure>) {
        self.groupSession = groupSession
        self.localData = localData
        self.messenger = GroupSessionMessenger(session: groupSession)

        self.groupSession.join()
        
        localData.sink { _ in
            // done
        } receiveValue: {[messenger] data in
            messenger.send(DrawingMessage(drawingState: data), to: .all) { error in
                if let error = error {
                    print("Error sending to participants \(error)")
                }
            }
        }.store(in: &subscriptions)

    }
}


struct DrawingMessage: Codable {
    var drawingState: Data
}

extension DrawingExperience : Identifiable {}
