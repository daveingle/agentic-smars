import Foundation
import CoreData
import Combine
import KeychainSwift

@MainActor
class AccountManager: ObservableObject {
    @Published var accounts: [EmailAccount] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let context = CoreDataStack.shared.context
    private let keychain = KeychainSwift()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupKeychain()
        loadAccounts()
    }
    
    private func setupKeychain() {
        keychain.synchronizable = false
        keychain.accessGroup = nil
    }
    
    func loadAccounts() {
        isLoading = true
        
        let request: NSFetchRequest<EmailAccount> = EmailAccount.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \EmailAccount.name, ascending: true)]
        
        do {
            accounts = try context.fetch(request)
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
    
    func addAccount(_ account: EmailAccount) throws {
        context.insert(account)
        try context.save()
        loadAccounts()
    }
    
    func updateAccount(_ account: EmailAccount) throws {
        try context.save()
        loadAccounts()
    }
    
    func deleteAccount(_ account: EmailAccount) throws {
        // Remove credentials from keychain
        removeCredentialsFromKeychain(for: account)
        
        context.delete(account)
        try context.save()
        loadAccounts()
    }
    
    func toggleAccountActive(_ account: EmailAccount) throws {
        account.isActive.toggle()
        try updateAccount(account)
    }
}

// MARK: - Keychain Management
extension AccountManager {
    private func keychainKey(for account: EmailAccount, type: String) -> String {
        return "EmailClient.\(account.id.uuidString).\(type)"
    }
    
    func storeCredentialsInKeychain(for account: EmailAccount, accessToken: String, refreshToken: String?) {
        let accessKey = keychainKey(for: account, type: "access_token")
        keychain.set(accessToken, forKey: accessKey)
        
        if let refreshToken = refreshToken {
            let refreshKey = keychainKey(for: account, type: "refresh_token")
            keychain.set(refreshToken, forKey: refreshKey)
        }
    }
    
    func getCredentialsFromKeychain(for account: EmailAccount) -> (accessToken: String?, refreshToken: String?) {
        let accessKey = keychainKey(for: account, type: "access_token")
        let refreshKey = keychainKey(for: account, type: "refresh_token")
        
        return (
            accessToken: keychain.get(accessKey),
            refreshToken: keychain.get(refreshKey)
        )
    }
    
    func removeCredentialsFromKeychain(for account: EmailAccount) {
        let accessKey = keychainKey(for: account, type: "access_token")
        let refreshKey = keychainKey(for: account, type: "refresh_token")
        
        keychain.delete(accessKey)
        keychain.delete(refreshKey)
    }
    
    func updateTokensInKeychain(for account: EmailAccount, accessToken: String, refreshToken: String?, expiresIn: TimeInterval) {
        storeCredentialsInKeychain(for: account, accessToken: accessToken, refreshToken: refreshToken)
        
        // Update credentials in Core Data
        if account.credentials == nil {
            account.credentials = EmailCredentials(context: context)
        }
        
        account.credentials?.updateTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresIn: expiresIn
        )
        
        try? context.save()
    }
}

// MARK: - Account Creation Helpers
extension AccountManager {
    func createGmailAccount(name: String, emailAddress: String) -> EmailAccount {
        let account = EmailAccount(context: context)
        account.name = name
        account.emailAddress = emailAddress
        account.provider = EmailAccount.Provider.gmail.rawValue
        account.protocol = EmailAccount.Provider.gmail.defaultProtocol
        account.authMethod = EmailAccount.Provider.gmail.defaultAuthMethod
        account.syncMethod = "push"
        
        return account
    }
    
    func createOutlookAccount(name: String, emailAddress: String) -> EmailAccount {
        let account = EmailAccount(context: context)
        account.name = name
        account.emailAddress = emailAddress
        account.provider = EmailAccount.Provider.outlook.rawValue
        account.protocol = EmailAccount.Provider.outlook.defaultProtocol
        account.authMethod = EmailAccount.Provider.outlook.defaultAuthMethod
        account.syncMethod = "delta"
        
        return account
    }
    
    func createICloudAccount(name: String, emailAddress: String) -> EmailAccount {
        let account = EmailAccount(context: context)
        account.name = name
        account.emailAddress = emailAddress
        account.provider = EmailAccount.Provider.icloud.rawValue
        account.protocol = EmailAccount.Provider.icloud.defaultProtocol
        account.authMethod = EmailAccount.Provider.icloud.defaultAuthMethod
        account.syncMethod = "imap"
        
        return account
    }
    
    func createExchangeAccount(name: String, emailAddress: String) -> EmailAccount {
        let account = EmailAccount(context: context)
        account.name = name
        account.emailAddress = emailAddress
        account.provider = EmailAccount.Provider.exchange.rawValue
        account.protocol = EmailAccount.Provider.exchange.defaultProtocol
        account.authMethod = EmailAccount.Provider.exchange.defaultAuthMethod
        account.syncMethod = "ews"
        
        return account
    }
}

// MARK: - Account Validation
extension AccountManager {
    func validateAccount(_ account: EmailAccount) -> [String] {
        var errors: [String] = []
        
        if account.name.isEmpty {
            errors.append("Account name is required")
        }
        
        if account.emailAddress.isEmpty {
            errors.append("Email address is required")
        } else if !isValidEmail(account.emailAddress) {
            errors.append("Email address is not valid")
        }
        
        if account.provider.isEmpty {
            errors.append("Provider is required")
        }
        
        return errors
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    func accountExists(withEmail email: String) -> Bool {
        return accounts.contains { $0.emailAddress.lowercased() == email.lowercased() }
    }
}