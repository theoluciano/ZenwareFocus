import Foundation
import AppKit

class AppBlockerService {
    private var blockedApps: Set<String> = []
    private var monitorTimer: Timer?
    private var isMonitoring = false
    private var hiddenApps: Set<NSRunningApplication> = []
    
    init() {
        // Initialize the service
    }
    
    // MARK: - Public Methods
    
    func blockApp(_ appName: String) {
        blockedApps.insert(appName)
        
        if !isMonitoring {
            startMonitoring()
        }
        
        // Immediately hide the app if it's running
        hideApplication(appName)
    }
    
    func unblockApp(_ appName: String) {
        blockedApps.remove(appName)
        
        if blockedApps.isEmpty {
            stopMonitoring()
        }
    }
    
    func unblockAll() {
        // Restore all hidden apps
        restoreAllApps()
        
        blockedApps.removeAll()
        stopMonitoring()
    }
    
    func isBlocked(_ appName: String) -> Bool {
        return blockedApps.contains(appName)
    }
    
    func getBlockedApps() -> [String] {
        return Array(blockedApps)
    }
    
    // MARK: - Private Methods
    
    private func startMonitoring() {
        guard !isMonitoring else { return }
        
        isMonitoring = true
        
        // Monitor every 2 seconds
        monitorTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.checkRunningApplications()
        }
        
        // Also listen to app launch notifications
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(applicationDidLaunch(_:)),
            name: NSWorkspace.didLaunchApplicationNotification,
            object: nil
        )
    }
    
    private func stopMonitoring() {
        isMonitoring = false
        monitorTimer?.invalidate()
        monitorTimer = nil
        
        NSWorkspace.shared.notificationCenter.removeObserver(
            self,
            name: NSWorkspace.didLaunchApplicationNotification,
            object: nil
        )
    }
    
    @objc private func applicationDidLaunch(_ notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication else {
            return
        }
        
        if let appName = app.localizedName, blockedApps.contains(appName) {
            hideApplication(app)
            showBlockedNotification(for: appName)
        }
    }
    
    private func checkRunningApplications() {
        let runningApps = NSWorkspace.shared.runningApplications
        
        for app in runningApps {
            if let appName = app.localizedName, blockedApps.contains(appName) {
                // If app is active (focused), hide it
                if app.isActive {
                    hideApplication(app)
                    showBlockedNotification(for: appName)
                }
            }
        }
    }
    
    private func hideApplication(_ appName: String) {
        let runningApps = NSWorkspace.shared.runningApplications
        
        for app in runningApps {
            if app.localizedName == appName {
                hideApplication(app)
            }
        }
    }
    
    private func hideApplication(_ app: NSRunningApplication) {
        // Hide the app instead of quitting it
        if !app.isHidden {
            app.hide()
            hiddenApps.insert(app)
        }
        
        // If app tries to activate, prevent it
        if app.isActive {
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    private func restoreAllApps() {
        // Unhide all apps that were hidden during the session
        for app in hiddenApps {
            if !app.isTerminated {
                app.unhide()
            }
        }
        hiddenApps.removeAll()
    }
    
    private func showBlockedNotification(for appName: String) {
        // Create alert window
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "\(appName) is blocked during this focus session"
            alert.informativeText = "This app will remain hidden until your focus session ends. You can snooze it for 3 minutes if you need temporary access."
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "Snooze for 3 minutes")
            
            let response = alert.runModal()
            
            if response == .alertSecondButtonReturn {
                // User wants to snooze - this will be handled by FocusManager
                NotificationCenter.default.post(
                    name: NSNotification.Name("SnoozeAppRequested"),
                    object: nil,
                    userInfo: ["appName": appName]
                )
            }
        }
    }
    
    // MARK: - Utility Methods
    
    func getInstalledApplications() -> [String] {
        // Get list of installed applications
        let fileManager = FileManager.default
        var apps: [String] = []
        
        let applicationDirs = [
            "/Applications",
            "/System/Applications",
            FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Applications").path
        ]
        
        for dir in applicationDirs {
            guard let contents = try? fileManager.contentsOfDirectory(atPath: dir) else {
                continue
            }
            
            for item in contents {
                if item.hasSuffix(".app") {
                    let appName = item.replacingOccurrences(of: ".app", with: "")
                    apps.append(appName)
                }
            }
        }
        
        return apps.sorted()
    }
    
    deinit {
        stopMonitoring()
    }
}