//
//  DrawingView.swift
//  SharedSketch
//
//  Created by Andrew Pouliot on 6/7/21.
//

import SwiftUI
import PencilKit
import Combine
import GroupActivities

typealias SpecificPublisher = PassthroughSubject<Data, DrawingView.Failure>

struct DrawingView : View {
    enum Failure: Error {
        
    }
    
    typealias Session = GroupSession<DrawingExperience>

    @StateObject var sessionManager: DrawingSessionManager
    
    let ourData = SpecificPublisher()
    
    init(session: Session) {
        let item = DrawingExperience(id: session.id)
        let sm = DrawingSessionManager(groupSession: session, item: item, localData: ourData.eraseToAnyPublisher())
        _sessionManager = .init(wrappedValue: sm)
    }
    
    var body: some View {
        Text("State is \(String(describing: sessionManager.groupSession.state))")
        PencilView(othersData: nil, ourData: ourData)
    }
}

struct PencilView : UIViewRepresentable {
    
    typealias Failure = DrawingView.Failure
    
    let othersData: Data?
    let ourData: PassthroughSubject<Data, DrawingView.Failure>

    typealias ViewType = PKCanvasView
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        @Published var ourData: Data? = nil

        let drawingData: SpecificPublisher
        
        init(drawingData: SpecificPublisher) {
            self.drawingData = drawingData
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            async(priority: .default) { [drawing = canvasView.drawing, drawingData] in
                drawingData.send(drawing.dataRepresentation())
            }
        }
        
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(drawingData: ourData)
    }

    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = PKCanvasView()
        canvasView.delegate = context.coordinator
        canvasView.tool = PKInkingTool(.pen, color: .gray, width: 10)
//        #if targetEnvironment(simulator)
          canvasView.drawingPolicy = .anyInput
//        #endif
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        
    }
    
}
