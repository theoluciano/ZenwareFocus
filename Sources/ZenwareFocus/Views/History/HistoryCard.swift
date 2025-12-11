import SwiftUI

struct HistoryCard: View {
    let session: FocusSession
    let onDelete: () -> Void
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(session.goal)
                .font(.system(size: 14, weight: .semibold))
                .lineLimit(2)
            
            HStack(spacing: 16) {
                if let startTime = session.startTime {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 11))
                        Text(formatDate(startTime))
                            .font(.system(size: 11))
                    }
                    .foregroundColor(.secondary)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 11))
                    Text(formatDuration(session.duration))
                        .font(.system(size: 11))
                }
                .foregroundColor(.secondary)
                
                Spacer()
                
                if session.isCompleted {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 11))
                        Text("Completed")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(.green)
                }
            }
        }
        .padding(14)
        .background(Color.gray.opacity(0.08))
        .cornerRadius(10)
        .contextMenu {
            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .alert("Delete Session?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("This session will be permanently deleted.")
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}