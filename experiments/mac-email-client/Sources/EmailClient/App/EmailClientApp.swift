import SwiftUI
import Combine

@main
struct EmailClientApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var accountManager = AccountManager()
    @StateObject private var syncCoordinator = SyncCoordinator()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(accountManager)
                .environmentObject(syncCoordinator)
                .onAppear {
                    setupApplication()
                }
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
    }
    
    private func setupApplication() {
        // Initialize Core Data stack
        CoreDataStack.shared.initialize()
        
        // Setup account manager
        accountManager.loadAccounts()
        
        // Start sync coordinator
        syncCoordinator.startBackgroundSync()
    }
}

@MainActor
class AppState: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedAccount: EmailAccount?
    @Published var selectedFolder: EmailFolder?
    
    func showError(_ message: String) {
        errorMessage = message
    }
    
    func clearError() {
        errorMessage = nil
    }
}