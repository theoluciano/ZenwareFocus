import Foundation
import AppKit

class WebsiteBlockerService {
    private var blockedWebsites: Set<String> = []
    private var isActive = false
    private var monitoringTimer: Timer?
    
    init() {
        // Initialize the service
    }
    
    // MARK: - Public Methods
    
    func blockWebsite(_ domain: String) {
        let normalized = normalizeDomain(domain)
        guard !normalized.isEmpty else { return }
        blockedWebsites.insert(normalized)
        updateBlocking()
    }
    
    func unblockWebsite(_ domain: String) {
        let normalized = normalizeDomain(domain)
        guard !normalized.isEmpty else { return }
        blockedWebsites.remove(normalized)
        updateBlocking()
    }
    
    func unblockAll() {
        blockedWebsites.removeAll()
        updateBlocking()
    }
    
    func isBlocked(_ domain: String) -> Bool {
        let normalized = normalizeDomain(domain)
        guard !normalized.isEmpty else { return false }
        return blockedWebsites.contains(normalized)
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
        let isSafariRunning = isAppRunning(bundleId: "com.apple.Safari")
        
        guard isSafariRunning else { return }

        executeAppleScript(
            buildBrowserScript(target: .name("Safari"), useActiveTabOnly: false)
        )
    }
    
    private func checkChromeTabs() {
        guard isActive && !blockedWebsites.isEmpty else { return }
        
        // Only check if Chrome is already running - don't launch it
        let isChromeRunning = isAppRunning(bundleId: "com.google.Chrome")
        
        guard isChromeRunning else { return }

        executeAppleScript(
            buildBrowserScript(target: .name("Google Chrome"), useActiveTabOnly: false)
        )
    }
    
    private func checkArcTabs() {
        guard isActive && !blockedWebsites.isEmpty else { return }
        
        // Only check if Arc is already running - don't launch it
        let isArcRunning = isAppRunning(
            bundleId: "company.thebrowser.Browser",
            fallbackName: "Arc"
        )
        
        guard isArcRunning else { return }

        // Arc's tab list can throw invalid index errors; use the active tab only.
        executeAppleScript(
            buildBrowserScript(target: .bundleId("company.thebrowser.Browser"), useActiveTabOnly: true)
        )
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
        let host = normalizeDomain(url)
        guard !host.isEmpty else { return false }
        return blockedWebsites.contains { domain in
            host == domain || host.hasSuffix(".\(domain)")
        }
    }

    private func isAppRunning(bundleId: String, fallbackName: String? = nil) -> Bool {
        let runningApps = NSWorkspace.shared.runningApplications
        if runningApps.contains(where: { $0.bundleIdentifier == bundleId }) {
            return true
        }
        if let fallbackName = fallbackName?.lowercased() {
            return runningApps.contains { $0.localizedName?.lowercased() == fallbackName }
        }
        return false
    }

    private enum BrowserTarget {
        case name(String)
        case bundleId(String)

        var tellTarget: String {
            switch self {
            case .name(let name):
                return "\"\(name)\""
            case .bundleId(let bundleId):
                return "id \"\(bundleId)\""
            }
        }
    }

    private func buildBrowserScript(target: BrowserTarget, useActiveTabOnly: Bool) -> String {
        let blockedSitesList = blockedWebsites
            .map { $0.replacingOccurrences(of: "\"", with: "\\\"") }
            .sorted()
            .joined(separator: "\", \"")

        let normalizeHostFunction = """
        on normalizeHost(tabURL)
            if tabURL is missing value then
                set tabURL to ""
            end if
            set tabURL to tabURL as text
            set hostOnly to tabURL
            if tabURL contains "://" then
                set AppleScript's text item delimiters to "://"
                if (count of text items of tabURL) > 1 then
                    set hostOnly to text item 2 of tabURL
                end if
                set AppleScript's text item delimiters to ""
            end if
            set AppleScript's text item delimiters to "/"
            if (count of text items of hostOnly) > 0 then
                set hostOnly to text item 1 of hostOnly
            end if
            set AppleScript's text item delimiters to ""
            if hostOnly starts with "www." then
                set hostOnly to text 5 thru -1 of hostOnly
            end if
            return hostOnly
        end normalizeHost
        """

        let matchBlock = """
            repeat with blockedSite in blockedSites
                ignoring case
                    if hostOnly is blockedSite or hostOnly ends with "." & blockedSite then
                        set URL of theTab to "about:blank"
                        return "blocked"
                    end if
                end ignoring
            end repeat
        """

        let tabLoop: String
        if useActiveTabOnly {
            tabLoop = """
            try
                set theTab to active tab of front window
                set hostOnly to normalizeHost(URL of theTab)
                \(matchBlock)
            on error
                -- Skip if active tab is not available.
            end try
            """
        } else {
            tabLoop = """
            repeat with theWindow in windows
                repeat with theTab in tabs of theWindow
                    set hostOnly to normalizeHost(URL of theTab)
                    \(matchBlock)
                end repeat
            end repeat
            """
        }

        return """
        tell application \(target.tellTarget)
            if not running then return
            set blockedSites to {"\(blockedSitesList)"}
            \(normalizeHostFunction)
            \(tabLoop)
        end tell
        """
    }

    private func normalizeDomain(_ domain: String) -> String {
        let trimmed = domain.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }

        if let url = URL(string: trimmed), let host = url.host {
            return stripWww(from: host.lowercased())
        }

        if let url = URL(string: "https://\(trimmed)"), let host = url.host {
            return stripWww(from: host.lowercased())
        }

        return stripWww(from: trimmed.lowercased())
    }

    private func stripWww(from host: String) -> String {
        if host.hasPrefix("www.") {
            return String(host.dropFirst(4))
        }
        return host
    }
}
