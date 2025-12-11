import SwiftUI

struct PresetCard: View {
    let preset: FocusPreset
    let onSelect: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(preset.name)
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
                Text(formatDuration(preset.duration))
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            if !preset.blockCategories.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(preset.blockCategories) { category in
                        HStack(spacing: 4) {
                            Image(systemName: category.icon)
                                .font(.system(size: 10))
                            Text(category.rawValue)
                                .font(.system(size: 11))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(Color.blue.opacity(0.15))
                        .foregroundColor(.blue)
                        .cornerRadius(6)
                    }
                }
            }
            
            Button(action: onSelect) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Start")
                        .fontWeight(.medium)
                }
                .font(.system(size: 13))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(Color.gray.opacity(0.08))
        .cornerRadius(12)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes > 0 ? "\(minutes)m" : "")"
        } else {
            return "\(minutes)m"
        }
    }
}