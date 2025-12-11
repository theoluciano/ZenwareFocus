import SwiftUI

struct AppPickerSheet: View {
    @Binding var selectedApps: Set<String>
    @Environment(\.dismiss) var dismiss
    @State private var installedApps: [String] = []
    @State private var searchText: String = ""
    
    var filteredApps: [String] {
        if searchText.isEmpty {
            return installedApps
        }
        return installedApps.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            searchBar
            appList
            footerView
        }
        .frame(width: 480, height: 560)
        .onAppear {
            loadInstalledApps()
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            Text("Select Apps to Block")
                .font(.system(size: 16, weight: .semibold))
            Spacer()
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(20)
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.system(size: 14))
            TextField("Search apps", text: $searchText)
                .textFieldStyle(.plain)
                .font(.system(size: 14))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
    
    // MARK: - App List
    
    private var appList: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(filteredApps, id: \.self) { appName in
                    AppPickerRow(
                        appName: appName,
                        isSelected: selectedApps.contains(appName),
                        onToggle: { toggleApp(appName) }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }
    
    // MARK: - Footer
    
    private var footerView: some View {
        HStack {
            Text("\(selectedApps.count) app\(selectedApps.count == 1 ? "" : "s") selected")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
            Spacer()
            Button("Done") {
                dismiss()
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding(20)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    // MARK: - Actions
    
    private func toggleApp(_ appName: String) {
        if selectedApps.contains(appName) {
            selectedApps.remove(appName)
        } else {
            selectedApps.insert(appName)
        }
    }
    
    private func loadInstalledApps() {
        let appBlocker = AppBlockerService()
        installedApps = appBlocker.getInstalledApplications()
    }
}