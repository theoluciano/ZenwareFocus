import SwiftUI

struct GoalInputSheet: View {
    let preset: FocusPreset
    let onStart: (String) -> Void
    let onCancel: () -> Void
    @State private var goal: String = ""
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Image(systemName: "target")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                Text("Start \(preset.name)")
                    .font(.system(size: 18, weight: .semibold))
            }
            .padding(.top, 20)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("What's your focus goal?")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                
                TextField("e.g., Write blog post", text: $goal)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 14))
            }
            
            HStack(spacing: 12) {
                Button("Cancel") {
                    onCancel()
                }
                .keyboardShortcut(.escape)
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.gray.opacity(0.15))
                .foregroundColor(.primary)
                .cornerRadius(8)
                
                Button("Start Focus") {
                    onStart(goal.isEmpty ? preset.name : goal)
                }
                .keyboardShortcut(.return)
                .disabled(goal.isEmpty)
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(goal.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .opacity(goal.isEmpty ? 0.6 : 1.0)
            }
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 24)
        .frame(width: 340)
    }
}