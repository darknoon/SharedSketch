//
//  DrawingExperience.swift
//  SharedSketch
//
//  Created by Andrew Pouliot on 6/7/21.
//

import GroupActivities
import Foundation
import Combine
import PencilKit

struct DrawingExperience: GroupActivity {
    typealias Identifier = UUID
    var id: Identifier = .init()
    static let activityIdentifier = "com.darknoon.drawing"
    
    var metadata: GroupActivityMetadata {
        var m = GroupActivityMetadata()
        m.title = "Drawing \(id)"
        m.fallbackURL = URL(string: "https://darknoon.com/drawing/\(id)")
        return m
    }
}

class DrawingSessionManager : ObservableObject {
    let groupSession: GroupSession<DrawingExperience>
    let messenger: GroupSessionMessenger
    
    let localData: AnyPublisher<Data, DrawingView.Failure>

    private var subscriptions: Set<AnyCancellable> =  []
    
    @Published var currentDrawing: PKDrawing = PKDrawing()

    init(groupSession: GroupSession<DrawingExperience>,
         item: DrawingExperience,
         localData: AnyPublisher<Data, DrawingView.Failure>)
    {
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

        async {
            for await (message, context) in messenger.messages(of: DrawingMessage.self) {
                do {
                    print("Update from participant: \(context.source.id)")
                    currentDrawing = try PKDrawing(data: message.drawingState)
                } catch {
                    print("error updating drawing: \(error)")
                }
            }
        }
        
    }
}


struct DrawingMessage: Codable {
    var drawingState: Data
}

extension DrawingExperience : Identifiable {}
