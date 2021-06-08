//
//  PlatformViewRepresentable.swift
//  MagicSparkleDonkey
//
//  Created by Andrew Pouliot on 5/21/21.
//

import SwiftUI

#if os(macOS)

protocol PlatformViewRepresentable  {
    associatedtype ViewType
    
    func makeView(context: Context) -> NSViewType
    func updateView(_ platformView: NSViewType, context: Context)
}

extension PlatformViewRepresentable: NSViewRepresentable where ViewType == NSViewType {
    func makeNSView(context: Context) -> NSViewType {
        makeView(context: context)
    }
    func updateNSView(_ nsView: NSViewType, context: Context) {
        updateView(nsView, context: context)
    }
}

#else

protocol PlatformViewRepresentable  {
    associatedtype ViewType
    associatedtype Context = Void
    
    func makeView(context: Context) -> ViewType
    func updateView(_ platformView: ViewType, context: Context)
}

extension PlatformViewRepresentable {
    typealias UIViewType = ViewType
    func makeUIView(context: Context) -> UIViewType {
        makeView(context: context)
    }
    func updateUIView(_ UIView: UIViewType, context: Context) {
        updateView(UIView, context: context)
    }
}

#endif
