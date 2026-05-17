//
//  MousePointerApp.swift
//  MousePointer
//
//  Created by MAKINO Takashi on 2026/05/18.
//

import SwiftUI
import AppKit

@main
struct MousePointerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Background-only app — no visible windows
        Settings { EmptyView() }
    }
}
