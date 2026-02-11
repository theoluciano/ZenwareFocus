import SwiftUI

struct PresetsView: View {
    @ObservedObject var focusManager: FocusManager
    @State private var selectedPreset: FocusPreset?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if focusManager.savedPresets.isEmpty {
                    emptyStateView
                } else {
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
                            },
                            onDelete: {
                                focusManager.deletePreset(preset)
                            }
                        )
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 20)
                }
            }
        }
        .sheet(item: $selectedPreset) { preset in
            GoalInputSheet(
                preset: preset,
                onStart: { goal in
                    let session = focusManager.createSessionFromPreset(preset, goal: goal)
                    focusManager.startSession(session)
                    selectedPreset = nil
                },
                onCancel: {
                    selectedPreset = nil
                }
            )
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bookmark.slash")
                .font(.system(size: 40))
                .foregroundColor(.secondary)

            Text("No presets yet")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)

            Text("Save any past focus session as a preset from the History tab.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 80)
    }
}
