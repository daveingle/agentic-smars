import SwiftUI

struct AccountSetupFlow: View {
    @StateObject private var viewModel = AccountSetupViewModel()
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var accountManager: AccountManager
    
    var body: some View {
        NavigationStack {
            VStack {
                switch viewModel.currentStep {
                case .providerSelection:
                    ProviderSelectionView(viewModel: viewModel)
                case .accountDetails:
                    AccountDetailsView(viewModel: viewModel)
                case .authentication:
                    AuthenticationView(viewModel: viewModel)
                case .verification:
                    VerificationView(viewModel: viewModel)
                }
            }
            .navigationTitle("Add Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Next") {
                        viewModel.nextStep()
                    }
                    .disabled(!viewModel.canProceed)
                }
            }
        }
        .frame(width: 500, height: 400)
        .onReceive(viewModel.$isCompleted) { isCompleted in
            if isCompleted {
                dismiss()
            }
        }
    }
}

// MARK: - Provider Selection View
struct ProviderSelectionView: View {
    @ObservedObject var viewModel: AccountSetupViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Choose your email provider")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(EmailAccount.Provider.allCases, id: \.self) { provider in
                    ProviderButton(
                        provider: provider,
                        isSelected: viewModel.selectedProvider == provider
                    ) {
                        viewModel.selectedProvider = provider
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

struct ProviderButton: View {
    let provider: EmailAccount.Provider
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: providerIcon)
                    .font(.system(size: 32))
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(provider.rawValue)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(width: 100, height: 80)
            .background(isSelected ? Color.accentColor : Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
    
    private var providerIcon: String {
        switch provider {
        case .gmail: return "envelope.circle"
        case .outlook: return "envelope.circle.fill"
        case .icloud: return "icloud"
        case .exchange: return "building.2"
        case .imap: return "envelope"
        case .pop3: return "envelope.arrow.triangle.branch"
        }
    }
}

// MARK: - Account Details View
struct AccountDetailsView: View {
    @ObservedObject var viewModel: AccountSetupViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Account Details")
                .font(.headline)
            
            Form {
                TextField("Account Name", text: $viewModel.accountName)
                TextField("Email Address", text: $viewModel.emailAddress)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                
                if viewModel.selectedProvider == .imap || viewModel.selectedProvider == .pop3 {
                    Section("Server Settings") {
                        TextField("Server Host", text: $viewModel.serverHost)
                        TextField("Port", value: $viewModel.serverPort, format: .number)
                        Toggle("Use SSL", isOn: $viewModel.useSSL)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Authentication View
struct AuthenticationView: View {
    @ObservedObject var viewModel: AccountSetupViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Authentication")
                .font(.headline)
            
            if viewModel.selectedProvider == .gmail || viewModel.selectedProvider == .outlook {
                VStack(spacing: 16) {
                    Text("Sign in with \(viewModel.selectedProvider?.rawValue ?? "")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button("Sign In") {
                        viewModel.startOAuthFlow()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            } else {
                Form {
                    if viewModel.selectedProvider == .icloud {
                        Text("Use an app-specific password for iCloud")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    SecureField("Password", text: $viewModel.password)
                        .textContentType(.password)
                }
            }
            
            if viewModel.isAuthenticating {
                ProgressView("Authenticating...")
                    .progressViewStyle(CircularProgressViewStyle())
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Verification View
struct VerificationView: View {
    @ObservedObject var viewModel: AccountSetupViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Verification")
                .font(.headline)
            
            if viewModel.isVerifying {
                ProgressView("Verifying account...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else if viewModel.verificationSuccess {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.green)
                    
                    Text("Account verified successfully!")
                        .font(.headline)
                        .foregroundColor(.green)
                }
            } else if let error = viewModel.verificationError {
                VStack(spacing: 16) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.red)
                    
                    Text("Verification failed")
                        .font(.headline)
                        .foregroundColor(.red)
                    
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - View Model
@MainActor
class AccountSetupViewModel: ObservableObject {
    @Published var currentStep: SetupStep = .providerSelection
    @Published var selectedProvider: EmailAccount.Provider?
    @Published var accountName = ""
    @Published var emailAddress = ""
    @Published var password = ""
    @Published var serverHost = ""
    @Published var serverPort: Int = 993
    @Published var useSSL = true
    @Published var isAuthenticating = false
    @Published var isVerifying = false
    @Published var verificationSuccess = false
    @Published var verificationError: String?
    @Published var isCompleted = false
    
    var canProceed: Bool {
        switch currentStep {
        case .providerSelection:
            return selectedProvider != nil
        case .accountDetails:
            return !accountName.isEmpty && !emailAddress.isEmpty
        case .authentication:
            return !isAuthenticating && (hasOAuthToken || !password.isEmpty)
        case .verification:
            return verificationSuccess
        }
    }
    
    private var hasOAuthToken: Bool {
        // This would check if OAuth flow completed successfully
        return selectedProvider == .gmail || selectedProvider == .outlook
    }
    
    enum SetupStep {
        case providerSelection
        case accountDetails
        case authentication
        case verification
    }
    
    func nextStep() {
        switch currentStep {
        case .providerSelection:
            currentStep = .accountDetails
        case .accountDetails:
            currentStep = .authentication
        case .authentication:
            currentStep = .verification
            verifyAccount()
        case .verification:
            completeSetup()
        }
    }
    
    func startOAuthFlow() {
        isAuthenticating = true
        
        // Simulate OAuth flow
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isAuthenticating = false
        }
    }
    
    private func verifyAccount() {
        isVerifying = true
        verificationError = nil
        
        // Simulate account verification
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isVerifying = false
            self.verificationSuccess = true
        }
    }
    
    private func completeSetup() {
        // Create and save account
        isCompleted = true
    }
}