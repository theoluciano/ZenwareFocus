import Foundation
import AppKit
import NetworkExtension

class WebsiteBlockerService {
    private var blockedWebsites: Set<String> = []
    private var hostsFilePath = "/etc/hosts"
    private var isActive = false
    private var monitoringTimer: Timer?
    
    init() {
        // Initialize the service
    }
    
    // MARK: - Public Methods
    
    func blockWebsite(_ domain: String) {
        blockedWebsites.insert(domain)
        updateBlocking()
    }
    
    func unblockWebsite(_ domain: String) {
        blockedWebsites.remove(domain)
        updateBlocking()
    }
    
    func unblockAll() {
        blockedWebsites.removeAll()
        updateBlocking()
    }
    
    func isBlocked(_ domain: String) -> Bool {
        return blockedWebsites.contains(domain)
    }
    
    func getBlockedWebsites() -> [String] {
        return Array(blockedWebsites)
    }
    
    // MARK: - Private Methods
    
    private func updateBlocking() {
        if blockedWebsites.isEmpty {
            removeAllBlocks()
        } else {
            applyBlocks()
        }
    }
    
    private func applyBlocks() {
        if !blockedWebsites.isEmpty {
            startBrowserMonitoring()
        }
    }
    
    private func removeAllBlocks() {
        isActive = false
        stopBrowserMonitoring()
    }
    
    // MARK: - Browser Monitoring
    
    private func startBrowserMonitoring() {
        guard !isActive else { return }
        guard !blockedWebsites.isEmpty else { return }
        
        isActive = true
        
        // Start timer to check browser tabs every 2 seconds
        monitoringTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.checkAllBrowsers()
        }
    }
    
    private func stopBrowserMonitoring() {
        isActive = false
        monitoringTimer?.invalidate()
        monitoringTimer = nil
    }
    
    private func checkAllBrowsers() {
        guard isActive && !blockedWebsites.isEmpty else { return }
        
        checkSafariTabs()
        checkChromeTabs()
        checkArcTabs()
        checkFirefoxTabs()
    }
    
    private func checkSafariTabs() {
        guard isActive && !blockedWebsites.isEmpty else { return }
        
        // Only check if Safari is already running - don't launch it
        let runningApps = NSWorkspace.shared.runningApplications
        let isSafariRunning = runningApps.contains { $0.bundleIdentifier == "com.apple.Safari" }
        
        guard isSafariRunning else { return }
        
        let script = """
        tell application "Safari"
            if not running then return
            set blockedSites to {"\(blockedWebsites.joined(separator: "\", \""))"}
            repeat with theWindow in windows
                repeat with theTab in tabs of theWindow
                    set tabURL to URL of theTab
                    repeat with blockedSite in blockedSites
                        if tabURL contains blockedSite then
                            set URL of theTab to "about:blank"
                            return "blocked"
                        end if
                    end repeat
                end repeat
            end repeat
        end tell
        """
        
        executeAppleScript(script)
    }
    
    private func checkChromeTabs() {
        guard isActive && !blockedWebsites.isEmpty else { return }
        
        // Only check if Chrome is already running - don't launch it
        let runningApps = NSWorkspace.shared.runningApplications
        let isChromeRunning = runningApps.contains { $0.bundleIdentifier == "com.google.Chrome" }
        
        guard isChromeRunning else { return }
        
        let script = """
        tell application "Google Chrome"
            if not running then return
            set blockedSites to {"\(blockedWebsites.joined(separator: "\", \""))"}
            repeat with theWindow in windows
                repeat with theTab in tabs of theWindow
                    set tabURL to URL of theTab
                    repeat with blockedSite in blockedSites
                        if tabURL contains blockedSite then
                            set URL of theTab to "about:blank"
                            return "blocked"
                        end if
                    end repeat
                end repeat
            end repeat
        end tell
        """
        
        executeAppleScript(script)
    }
    
    private func checkArcTabs() {
        guard isActive && !blockedWebsites.isEmpty else { return }
        
        // Only check if Arc is already running - don't launch it
        let runningApps = NSWorkspace.shared.runningApplications
        let isArcRunning = runningApps.contains { $0.bundleIdentifier == "company.thebrowser.Browser" }
        
        guard isArcRunning else { return }
        
        // Arc uses similar AppleScript to Chrome since it's Chromium-based
        let script = """
        tell application "Arc"
            if not running then return
            set blockedSites to {"\(blockedWebsites.joined(separator: "\", \""))"}
            repeat with theWindow in windows
                repeat with theTab in tabs of theWindow
                    set tabURL to URL of theTab
                    repeat with blockedSite in blockedSites
                        if tabURL contains blockedSite then
                            set URL of theTab to "about:blank"
                            return "blocked"
                        end if
                    end repeat
                end repeat
            end repeat
        end tell
        """
        
        executeAppleScript(script)
    }
    
    private func checkFirefoxTabs() {
        // Firefox doesn't have great AppleScript support - skip for now
    }
    
    private func executeAppleScript(_ script: String) {
        guard isActive && !blockedWebsites.isEmpty else { return }
        
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: script) {
            let result = scriptObject.executeAndReturnError(&error)
            
            if let error = error {
                // Silently log errors for debugging
                print("AppleScript error: \(error)")
            }
            _ = result
        }
    }
    
    // MARK: - Alternative: Content Filter Extension
    // Note: For production use, you'd want to implement a proper Network Extension
    // This requires additional entitlements and setup
    
    func requestContentFilterPermission() {
        // This would request permission to install a content filter
        // Requires Network Extension framework and proper entitlements
    }
    
    // MARK: - Helper Methods
    
    func showBlockedWebsiteAlert(for domain: String) {
        DispatchQueue.main.async {
            // Post notification to show alert
            NotificationCenter.default.post(
                name: NSNotification.Name("WebsiteBlocked"),
                object: nil,
                userInfo: ["domain": domain]
            )
        }
    }
    
    func isDomainBlocked(_ url: String) -> Bool {
        for domain in blockedWebsites {
            if url.contains(domain) {
                return true
            }
        }
        return false
    }
}
