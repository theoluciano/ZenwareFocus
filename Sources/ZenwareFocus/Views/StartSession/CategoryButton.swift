import SwiftUI

struct CategoryButton: View {
    let category: BlockCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: category.icon)
                    .font(.system(size: 16))
                    .foregroundColor(isSelected ? .blue : .secondary)
                    .frame(width: 24)
                
                Text(category.rawValue)
                    .font(.system(size: 13))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Spacer(minLength: 4)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(isSelected ? Color.blue.opacity(0.15) : Color.gray.opacity(0.08))
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}