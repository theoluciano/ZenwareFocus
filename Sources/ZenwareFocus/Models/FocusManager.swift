import Foundation
import Combine

@MainActor
class FocusManager: ObservableObject {
    // MARK: - Published Properties
    @Published var currentSession: FocusSession?
    @Published var savedPresets: [FocusPreset] = FocusPreset.defaultPresets
    @Published var sessionHistory: [FocusSession] = []
    @Published var snoozeStates: [SnoozeState] = []
    
    // MARK: - Private Properties
    private var timer: Timer?
    private var sessionDefaults = UserDefaults.standard
    
    // MARK: - Services
    private let appBlocker = AppBlockerService()
    private let websiteBlocker = WebsiteBlockerService()
    
    init() {
        loadSavedData()
    }
    
    // MARK: - Session Management
    
    func startSession(_ session: FocusSession) {
        var newSession = session
        newSession.startTime = Date()
        newSession.endTime = Date().addingTimeInterval(session.duration)
        newSession.isActive = true
        newSession.isPaused = false
        
        currentSession = newSession
        
        // Apply blocks
        applyBlocks(for: newSession)
        
        // Start timer
        startTimer()
        
        // Save state
        saveCurrentSession()
    }
    
    func pauseSession() {
        guard var session = currentSession, session.isActive, !session.isPaused else {
            return
        }
        
        session.isPaused = true
        session.pausedAt = Date()
        currentSession = session
        
        // Remove blocks temporarily
        removeBlocks()
        
        saveCurrentSession()
    }
    
    func resumeSession() {
        guard var session = currentSession, session.isActive, session.isPaused else {
            return
        }
        
        if let pausedAt = session.pausedAt {
            let pauseDuration = Date().timeIntervalSince(pausedAt)
            session.totalPausedTime += pauseDuration
        }
        
        session.isPaused = false
        session.pausedAt = nil
        currentSession = session
        
        // Reapply blocks
        applyBlocks(for: session)
        
        saveCurrentSession()
    }
    
    func stopSession() {
        guard let session = currentSession else { return }
        
        // Remove all blocks
        removeBlocks()
        
        // Stop timer
        stopTimer()
        
        // Save to history if it was active
        if session.isActive {
            var completedSession = session
            completedSession.isActive = false
            completedSession.endTime = Date()
            sessionHistory.append(completedSession)
            saveHistory()
        }
        
        currentSession = nil
        snoozeStates.removeAll()
        saveCurrentSession()
    }
    
    func extendSession(by duration: TimeInterval) {
        guard var session = currentSession, session.isActive else { return }
        
        session.duration += duration
        if let endTime = session.endTime {
            session.endTime = endTime.addingTimeInterval(duration)
        }
        
        currentSession = session
        saveCurrentSession()
    }
    
    // MARK: - Snooze Management
    
    func snoozeApp(_ appName: String, for duration: TimeInterval = 180) {
        let snoozeState = SnoozeState(
            targetIdentifier: appName,
            type: .app,
            snoozedUntil: Date().addingTimeInterval(duration)
        )
        
        snoozeStates.append(snoozeState)
        appBlocker.unblockApp(appName)
        
        // Schedule re-blocking
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.endSnooze(for: appName, type: .app)
        }
    }
    
    func snoozeWebsite(_ domain: String, for duration: TimeInterval = 180) {
        let snoozeState = SnoozeState(
            targetIdentifier: domain,
            type: .website,
            snoozedUntil: Date().addingTimeInterval(duration)
        )
        
        snoozeStates.append(snoozeState)
        websiteBlocker.unblockWebsite(domain)
        
        // Schedule re-blocking
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.endSnooze(for: domain, type: .website)
        }
    }
    
    private func endSnooze(for identifier: String, type: SnoozeType) {
        snoozeStates.removeAll { $0.targetIdentifier == identifier && $0.type == type }
        
        guard let session = currentSession, session.isActive, !session.isPaused else {
            return
        }
        
        // Reapply block
        switch type {
        case .app:
            appBlocker.blockApp(identifier)
        case .website:
            websiteBlocker.blockWebsite(identifier)
        }
    }
    
    func isAppSnoozed(_ appName: String) -> Bool {
        return snoozeStates.contains { 
            $0.targetIdentifier == appName && $0.type == .app && $0.isActive 
        }
    }
    
    func isWebsiteSnoozed(_ domain: String) -> Bool {
        return snoozeStates.contains { 
            $0.targetIdentifier == domain && $0.type == .website && $0.isActive 
        }
    }
    
    // MARK: - Blocking
    
    private func applyBlocks(for session: FocusSession) {
        var allApps = session.blockedApps
        var allWebsites = session.blockedWebsites
        
        // Add apps and websites from categories
        for category in session.blockCategories {
            allApps.append(contentsOf: category.defaultApps)
            allWebsites.append(contentsOf: category.defaultWebsites)
        }
        
        // Remove duplicates
        allApps = Array(Set(allApps))
        allWebsites = Array(Set(allWebsites))
        
        // Apply blocks
        for app in allApps where !isAppSnoozed(app) {
            appBlocker.blockApp(app)
        }
        
        for website in allWebsites where !isWebsiteSnoozed(website) {
            websiteBlocker.blockWebsite(website)
        }
    }
    
    private func removeBlocks() {
        appBlocker.unblockAll()
        websiteBlocker.unblockAll()
    }
    
    // MARK: - Timer
    
    private func startTimer() {
        stopTimer()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateSession()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateSession() {
        guard let session = currentSession else {
            stopTimer()
            return
        }
        
        // Don't update if paused
        if session.isPaused {
            return
        }
        
        // Check if session is complete
        if session.isCompleted {
            stopSession()
            showCompletionNotification()
            return
        }
        
        // Trigger UI update
        objectWillChange.send()
    }
    
    // MARK: - Notifications
    
    private func showCompletionNotification() {
        // TODO: Implement notification
        print("Focus session completed! 🎉")
    }
    
    // MARK: - Presets
    
    func savePreset(_ preset: FocusPreset) {
        if let index = savedPresets.firstIndex(where: { $0.id == preset.id }) {
            savedPresets[index] = preset
        } else {
            savedPresets.append(preset)
        }
        savePresets()
    }
    
    func deletePreset(_ preset: FocusPreset) {
        savedPresets.removeAll { $0.id == preset.id }
        savePresets()
    }
    
    // MARK: - History Management
    
    func deleteSession(_ session: FocusSession) {
        sessionHistory.removeAll { $0.id == session.id }
        saveHistory()
    }
    
    func clearHistory() {
        sessionHistory.removeAll()
        saveHistory()
    }
    
    func createSessionFromPreset(_ preset: FocusPreset, goal: String = "") -> FocusSession {
        var allApps = preset.customApps
        var allWebsites = preset.customWebsites
        
        for category in preset.blockCategories {
            allApps.append(contentsOf: category.defaultApps)
            allWebsites.append(contentsOf: category.defaultWebsites)
        }
        
        return FocusSession(
            goal: goal.isEmpty ? preset.name : goal,
            duration: preset.duration,
            blockedApps: Array(Set(allApps)),
            blockedWebsites: Array(Set(allWebsites)),
            blockCategories: preset.blockCategories
        )
    }
    
    // MARK: - Persistence
    
    private func saveCurrentSession() {
        if let session = currentSession,
           let data = try? JSONEncoder().encode(session) {
            sessionDefaults.set(data, forKey: "currentSession")
        } else {
            sessionDefaults.removeObject(forKey: "currentSession")
        }
    }
    
    private func savePresets() {
        if let data = try? JSONEncoder().encode(savedPresets) {
            sessionDefaults.set(data, forKey: "savedPresets")
        }
    }
    
    private func saveHistory() {
        if let data = try? JSONEncoder().encode(sessionHistory) {
            sessionDefaults.set(data, forKey: "sessionHistory")
        }
    }
    
    private func loadSavedData() {
        // Load current session
        if let data = sessionDefaults.data(forKey: "currentSession"),
           let session = try? JSONDecoder().decode(FocusSession.self, from: data) {
            currentSession = session
            if session.isActive && !session.isPaused {
                startTimer()
                applyBlocks(for: session)
            }
        }
        
        // Load presets
        if let data = sessionDefaults.data(forKey: "savedPresets"),
           let presets = try? JSONDecoder().decode([FocusPreset].self, from: data) {
            savedPresets = presets
        }
        
        // Load history
        if let data = sessionDefaults.data(forKey: "sessionHistory"),
           let history = try? JSONDecoder().decode([FocusSession].self, from: data) {
            sessionHistory = history
        }
    }
}