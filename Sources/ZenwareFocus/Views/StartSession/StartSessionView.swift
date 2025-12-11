import SwiftUI

struct StartSessionView: View {
    @ObservedObject var focusManager: FocusManager
    @State private var goal: String = ""
    @State private var selectedDuration: TimeInterval = 1500
    @State private var selectedCategories: Set<BlockCategory> = []
    @State private var customApps: Set<String> = []
    @State private var showingAppPicker = false

    let durations: [(String, TimeInterval)] = [
        ("5 min", 300),
        ("15 min", 900),
        ("25 min", 1500),
        ("45 min", 2700),
        ("1 hour", 3600),
        ("2 hours", 7200)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                goalSection
                durationSection
                categoriesSection
                customAppsSection

                if !goal.isEmpty {
                    startButton
                }
            }
            .padding(20)
        }
        .sheet(isPresented: $showingAppPicker) {
            AppPickerSheet(selectedApps: $customApps)
        }
    }

    // MARK: - Goal Section

    private var goalSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Focus Goal", systemImage: "target")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)

                TextField("What do you want to accomplish?", text: $goal)
                    .textFieldStyle(.plain)
                    .font(.system(size: 14))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(NSColor.controlBackgroundColor))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    )

        }
    }

    // MARK: - Duration Section

    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Duration", systemImage: "clock")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(durations, id: \.0) { duration in
                    DurationButton(
                        title: duration.0,
                        isSelected: selectedDuration == duration.1,
                        action: { selectedDuration = duration.1 }
                    )
                }
            }
        }
    }

    // MARK: - Categories Section

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Block Distractions", systemImage: "hand.raised.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(BlockCategory.allCases) { category in
                    CategoryButton(
                        category: category,
                        isSelected: selectedCategories.contains(category),
                        action: { toggleCategory(category) }
                    )
                }
            }
        }
    }

    // MARK: - Custom Apps Section

    private var customAppsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Block Specific Apps", systemImage: "app.badge.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)

            VStack(spacing: 8) {
                customAppsButton

                if !customApps.isEmpty {
                    selectedAppsView
                }
            }
        }
    }

    private var customAppsButton: some View {
        Button(action: { showingAppPicker = true }) {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(customApps.isEmpty ? .secondary : .purple)
                    .frame(width: 24)

                Text(customApps.isEmpty ? "Select apps to block" : "\(customApps.count) app\(customApps.count == 1 ? "" : "s") selected")
                    .font(.system(size: 13))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Spacer(minLength: 4)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(customApps.isEmpty ? Color.gray.opacity(0.08) : Color.purple.opacity(0.15))
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }

    private var selectedAppsView: some View {
        FlowLayout(spacing: 6) {
            ForEach(Array(customApps).sorted(), id: \.self) { appName in
                HStack(spacing: 6) {
                    Text(appName)
                        .font(.system(size: 11))
                    Button(action: { customApps.remove(appName) }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(Color.purple.opacity(0.15))
                .foregroundColor(.purple)
                .cornerRadius(6)
            }
        }
    }

    // MARK: - Start Button

    private var startButton: some View {
        Button(action: startSession) {
            HStack(spacing: 8) {
                Image(systemName: "play.fill")
                Text("Start Focus Session")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private func toggleCategory(_ category: BlockCategory) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }

    private func startSession() {
        var allApps: [String] = []
        var allWebsites: [String] = []

        for category in selectedCategories {
            allApps.append(contentsOf: category.defaultApps)
            allWebsites.append(contentsOf: category.defaultWebsites)
        }

        allApps.append(contentsOf: customApps)

        let session = FocusSession(
            goal: goal,
            duration: selectedDuration,
            blockedApps: Array(Set(allApps)),
            blockedWebsites: Array(Set(allWebsites)),
            blockCategories: Array(selectedCategories)
        )

        focusManager.startSession(session)
    }
}
