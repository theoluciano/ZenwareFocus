import Foundation
import Combine

@MainActor
class FocusManager: ObservableObject {
    // MARK: - Published Properties
    @Published var currentSession: FocusSession?
    @Published var savedPresets: [FocusPreset] = []
    @Published var sessionHistory: [FocusSession] = []
    @Published var snoozeStates: [SnoozeState] = []
    
    // MARK: - Private Properties
    private var timer: Timer?
    private var sessionDefaults = UserDefaults.standard
    private var snoozeObserver: NSObjectProtocol?
    
    // MARK: - Services
    private let appBlocker = AppBlockerService()
    private let websiteBlocker = WebsiteBlockerService()
    
    init() {
        setupSnoozeObserver()
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
    
    func deletePreset(_ preset: FocusPreset) {
        let sourceId = preset.sourceSessionId
        savedPresets.removeAll { existing in
            if existing.id == preset.id {
                return true
            }
            if let sourceId = sourceId {
                return existing.sourceSessionId == sourceId
            }
            return false
        }
        savePresets()
    }

    func savePreset(from session: FocusSession) {
        if isSessionSaved(session) {
            return
        }
        let name = presetName(from: session)
        let preset = FocusPreset(
            name: name,
            duration: session.duration,
            blockCategories: session.blockCategories,
            customApps: session.blockedApps,
            customWebsites: session.blockedWebsites,
            sourceSessionId: session.id
        )
        addPreset(preset)
    }

    func isSessionSaved(_ session: FocusSession) -> Bool {
        return savedPresets.contains { $0.sourceSessionId == session.id }
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

    private func addPreset(_ preset: FocusPreset) {
        savedPresets.append(preset)
        savePresets()
    }

    private func presetName(from session: FocusSession) -> String {
        let trimmed = session.goal.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            return trimmed
        }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        if let startTime = session.startTime {
            return "Session \(formatter.string(from: startTime))"
        }

        return "Saved Session"
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

    private func setupSnoozeObserver() {
        snoozeObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("SnoozeAppRequested"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let appName = notification.userInfo?["appName"] as? String else {
                return
            }
            Task { @MainActor in
                self?.snoozeApp(appName)
            }
        }
    }

    deinit {
        if let snoozeObserver = snoozeObserver {
            NotificationCenter.default.removeObserver(snoozeObserver)
        }
    }
}