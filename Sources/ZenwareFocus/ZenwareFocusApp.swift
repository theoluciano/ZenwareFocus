import SwiftUI
import AppKit

@main
struct ZenwareFocusApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // Menu bar app - no window scene needed initially
        Settings {
            EmptyView()
        }
    }
}

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem?
    var popover: NSPopover?
    var menuBarTimer: Timer?
    
    // Shared FocusManager instance
    static let shared = AppDelegate()
    let focusManager = FocusManager()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create menu bar item with fixed length to prevent jumping
        statusBarItem = NSStatusBar.system.statusItem(withLength: 80)
        
        if let button = statusBarItem?.button {
            button.image = NSImage(systemSymbolName: "dot.scope", accessibilityDescription: "Zenware Focus")
            button.imagePosition = .imageLeading
            button.action = #selector(togglePopover)
            button.target = self
            
            // Use monospaced font for consistent width and set alignment
            button.font = NSFont.monospacedDigitSystemFont(ofSize: 13, weight: .regular)
            button.alignment = .center
            
            // Remove default spacing between image and title
            button.imageHugsTitle = true
        }
        
        // Setup popover with the same FocusManager instance
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 360, height: 500)
        popover?.behavior = .transient
        // Pass the focusManager to FocusView
        let focusView = FocusView()
        popover?.contentViewController = NSHostingController(rootView: focusView.environmentObject(focusManager))
        
        // Don't show app in Dock
        NSApp.setActivationPolicy(.accessory)
        
        // Start menu bar update timer
        startMenuBarTimer()
    }
    
    private func startMenuBarTimer() {
        menuBarTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateMenuBar()
            }
        }
    }
    
    private func updateMenuBar() {
        guard let button = statusBarItem?.button else { return }
        
        // Check if session exists and is active
        guard let session = focusManager.currentSession, 
              session.isActive, 
              !session.isPaused,
              let endTime = session.endTime else {
            // No active session - show just icon, clear title
            button.title = ""
            statusBarItem?.length = NSStatusItem.squareLength
            return
        }
        
        // Ensure fixed width when showing timer
        statusBarItem?.length = 80
        
        // Calculate remaining time
        let remaining = endTime.timeIntervalSinceNow
        
        if remaining <= 0 {
            // Session ended
            button.title = ""
            statusBarItem?.length = NSStatusItem.squareLength
            return
        }
        
        // Format time with fixed width using monospaced digits
        let hours = Int(remaining) / 3600
        let minutes = Int(remaining) / 60 % 60
        let seconds = Int(remaining) % 60
        
        if hours > 0 {
            button.title = String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            button.title = String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    @objc func togglePopover() {
        if let button = statusBarItem?.button {
            if let popover = popover {
                if popover.isShown {
                    popover.performClose(nil)
                } else {
                    popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                    NSApp.activate(ignoringOtherApps: true)
                }
            }
        }
    }
}
