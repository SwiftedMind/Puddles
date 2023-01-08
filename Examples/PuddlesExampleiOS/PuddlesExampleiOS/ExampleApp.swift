//
//  ExampleApp.swift
//  PuddlesExampleIOS
//
//  Created by Dennis Müller on 06.01.23.
//

import SwiftUI

@main
struct ExampleApp: App {
    @StateObject private var services: Services = .real
    @State var isShowing: Bool = true

    var body: some Scene {
        WindowGroup {
            Root()
                .environmentObject(services)
        }
    }
}
