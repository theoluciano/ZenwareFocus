import SwiftUI

struct PresetsView: View {
    @ObservedObject var focusManager: FocusManager
    @State private var selectedPreset: FocusPreset?
    @State private var showingGoalSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Quick Start")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                ForEach(focusManager.savedPresets) { preset in
                    PresetCard(
                        preset: preset,
                        onSelect: {
                            selectedPreset = preset
                            showingGoalSheet = true
                        }
                    )
                    .padding(.horizontal, 20)
                }
                
                Spacer(minLength: 20)
            }
        }
        .sheet(isPresented: $showingGoalSheet) {
            if let preset = selectedPreset {
                GoalInputSheet(
                    preset: preset,
                    onStart: { goal in
                        let session = focusManager.createSessionFromPreset(preset, goal: goal)
                        focusManager.startSession(session)
                        showingGoalSheet = false
                    },
                    onCancel: {
                        showingGoalSheet = false
                    }
                )
            }
        }
    }
}