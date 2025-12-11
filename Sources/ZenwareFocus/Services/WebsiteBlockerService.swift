import Foundation
import AppKit
import NetworkExtension

class WebsiteBlockerService {
    private var blockedWebsites: Set<String> = []
    private var hostsFilePath = "/etc/hosts"
    private var isActive = false
    
    // Temporary solution: Use hosts file blocking
    // Note: This requires sudo permissions, so we'll implement a lightweight approach
    
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
        
        // Don't start monitoring immediately - wait for browsers to actually be running
        // This prevents force-opening browsers
    }
    
    private func stopBrowserMonitoring() {
        isActive = false
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
    
    private func checkFirefoxTabs() {
        // Firefox doesn't have great AppleScript support - skip for now
    }
    
    private func executeAppleScript(_ script: String) {
        guard isActive && !blockedWebsites.isEmpty else { return }
        
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: script) {
            let result = scriptObject.executeAndReturnError(&error)
            
            // Silently ignore errors - browser might not be running or accessible
            _ = result
        }
    }
    
    // MARK: - Alternative: Content Filter Extension
    // Note: For production use, you'd want to implement a proper Network Extension
    // This requires additional entitlements and setup
    
    func requestContentFilterPermission() {
        // This would request permission to install a content filter
        // Requires Network Extension framework and proper entitlements
        
        // Example (commented out as it requires full setup):
        /*
        NEFilterManager.shared().loadFromPreferences { error in
            if let error = error {
                print("Failed to load filter configuration: \(error)")
                return
            }
            
            let filterConfiguration = NEFilterManager.shared()
            filterConfiguration.isEnabled = true
            
            filterConfiguration.saveToPreferences { error in
                if let error = error {
                    print("Failed to save filter configuration: \(error)")
                } else {
                    print("Content filter enabled successfully")
                }
            }
        }
        */
    }
    
    // MARK: - Hosts File Approach (Alternative)
    // This requires admin privileges
    
    private func blockViaHostsFile() {
        // This would modify /etc/hosts to redirect blocked domains to 127.0.0.1
        // Requires sudo access, so we'd need to ask for admin password
        
        var hostsEntries = ""
        for domain in blockedWebsites {
            hostsEntries += "127.0.0.1 \(domain)\n"
            hostsEntries += "127.0.0.1 www.\(domain)\n"
        }
        
        // Would execute: echo "entries" | sudo tee -a /etc/hosts
        // This is commented out as it requires privilege elevation
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