import Foundation

// MARK: - Focus Session Model
struct FocusSession: Identifiable, Codable {
    let id: UUID
    var goal: String
    var duration: TimeInterval // in seconds
    var startTime: Date?
    var endTime: Date?
    var blockedApps: [String]
    var blockedWebsites: [String]
    var blockCategories: [BlockCategory]
    var isActive: Bool
    var isPaused: Bool
    var pausedAt: Date?
    var totalPausedTime: TimeInterval
    
    init(
        id: UUID = UUID(),
        goal: String = "",
        duration: TimeInterval = 1500, // 25 minutes default
        blockedApps: [String] = [],
        blockedWebsites: [String] = [],
        blockCategories: [BlockCategory] = []
    ) {
        self.id = id
        self.goal = goal
        self.duration = duration
        self.startTime = nil
        self.endTime = nil
        self.blockedApps = blockedApps
        self.blockedWebsites = blockedWebsites
        self.blockCategories = blockCategories
        self.isActive = false
        self.isPaused = false
        self.pausedAt = nil
        self.totalPausedTime = 0
    }
    
    // Computed properties
    var remainingTime: TimeInterval {
        guard let startTime = startTime, isActive else {
            return duration
        }
        
        let elapsed = Date().timeIntervalSince(startTime) - totalPausedTime
        return max(0, duration - elapsed)
    }
    
    var progress: Double {
        guard duration > 0 else { return 0 }
        return 1.0 - (remainingTime / duration)
    }
    
    var isCompleted: Bool {
        return isActive && remainingTime <= 0
    }
    
    var formattedRemainingTime: String {
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Block Category
enum BlockCategory: String, Codable, CaseIterable, Identifiable {
    case socialMedia = "Social Media"
    case shopping = "Shopping"
    case news = "News"
    case entertainment = "Entertainment"
    case gaming = "Gaming"
    case messaging = "Messaging"
    
    var id: String { rawValue }
    
    var defaultApps: [String] {
        switch self {
        case .socialMedia:
            return ["Twitter", "Facebook", "Instagram", "TikTok", "LinkedIn", "Reddit"]
        case .shopping:
            return ["Amazon", "eBay", "Etsy"]
        case .news:
            return ["News", "Safari", "Arc"] // Can be filtered by domain
        case .entertainment:
            return ["YouTube", "Netflix", "Spotify", "Apple TV"]
        case .gaming:
            return ["Steam", "Discord", "Epic Games"]
        case .messaging:
            return ["Slack", "Discord", "WhatsApp", "Telegram", "Messages"]
        }
    }
    
    var defaultWebsites: [String] {
        switch self {
        case .socialMedia:
            return ["twitter.com", "facebook.com", "instagram.com", "tiktok.com", "linkedin.com", "reddit.com", "x.com"]
        case .shopping:
            return ["amazon.com", "ebay.com", "etsy.com", "alibaba.com"]
        case .news:
            return ["cnn.com", "bbc.com", "nytimes.com", "theguardian.com", "reuters.com"]
        case .entertainment:
            return ["youtube.com", "netflix.com", "hulu.com", "twitch.tv", "spotify.com"]
        case .gaming:
            return ["steampowered.com", "epicgames.com", "twitch.tv"]
        case .messaging:
            return ["slack.com", "discord.com", "web.whatsapp.com", "web.telegram.org"]
        }
    }
    
    var icon: String {
        switch self {
        case .socialMedia:
            return "person.3.fill"
        case .shopping:
            return "cart.fill"
        case .news:
            return "newspaper.fill"
        case .entertainment:
            return "tv.fill"
        case .gaming:
            return "gamecontroller.fill"
        case .messaging:
            return "message.fill"
        }
    }
}

// MARK: - Focus Preset
struct FocusPreset: Identifiable, Codable {
    let id: UUID
    var sourceSessionId: UUID?
    var name: String
    var duration: TimeInterval
    var blockCategories: [BlockCategory]
    var customApps: [String]
    var customWebsites: [String]
    
    init(
        id: UUID = UUID(),
        name: String,
        duration: TimeInterval,
        blockCategories: [BlockCategory] = [],
        customApps: [String] = [],
        customWebsites: [String] = [],
        sourceSessionId: UUID? = nil
    ) {
        self.id = id
        self.sourceSessionId = sourceSessionId
        self.name = name
        self.duration = duration
        self.blockCategories = blockCategories
        self.customApps = customApps
        self.customWebsites = customWebsites
    }
    
    // Default presets
    static var defaultPresets: [FocusPreset] {
        return [
            FocusPreset(
                name: "Deep Work",
                duration: 7200, // 2 hours
                blockCategories: [.socialMedia, .shopping, .entertainment, .messaging]
            ),
            FocusPreset(
                name: "Quick Focus",
                duration: 1500, // 25 minutes
                blockCategories: [.socialMedia, .entertainment]
            ),
            FocusPreset(
                name: "Study Session",
                duration: 3600, // 1 hour
                blockCategories: [.socialMedia, .gaming, .entertainment]
            ),
            FocusPreset(
                name: "Meeting Mode",
                duration: 1800, // 30 minutes
                blockCategories: [.socialMedia, .shopping, .gaming]
            )
        ]
    }
}

// MARK: - Snooze State
struct SnoozeState: Codable {
    let targetIdentifier: String // app name or website domain
    let type: SnoozeType
    let snoozedUntil: Date
    
    var isActive: Bool {
        return Date() < snoozedUntil
    }
}

enum SnoozeType: String, Codable {
    case app
    case website
}