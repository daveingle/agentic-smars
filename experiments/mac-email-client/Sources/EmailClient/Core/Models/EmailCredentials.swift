import CoreData
import Foundation

@objc(EmailCredentials)
public class EmailCredentials: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var accessToken: String?
    @NSManaged public var refreshToken: String?
    @NSManaged public var tokenExpiry: Date?
    @NSManaged public var username: String?
    @NSManaged public var serverHost: String?
    @NSManaged public var serverPort: Int32
    @NSManaged public var usesSSL: Bool
    @NSManaged public var account: EmailAccount?
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID()
        serverPort = 993 // Default IMAP SSL port
        usesSSL = true
    }
}

// MARK: - Computed Properties
extension EmailCredentials {
    var hasValidToken: Bool {
        guard let accessToken = accessToken, !accessToken.isEmpty else { return false }
        guard let expiry = tokenExpiry else { return true } // No expiry means valid
        return expiry > Date()
    }
    
    var needsRefresh: Bool {
        guard let expiry = tokenExpiry else { return false }
        // Refresh if token expires within 5 minutes
        return expiry.timeIntervalSinceNow < 300
    }
    
    var hasRefreshToken: Bool {
        return refreshToken != nil && !refreshToken!.isEmpty
    }
    
    var serverURL: String {
        guard let host = serverHost else { return "" }
        let scheme = usesSSL ? "https" : "http"
        return "\(scheme)://\(host):\(serverPort)"
    }
}

// MARK: - Token Management
extension EmailCredentials {
    func updateTokens(accessToken: String, refreshToken: String?, expiresIn: TimeInterval) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.tokenExpiry = Date().addingTimeInterval(expiresIn)
    }
    
    func clearTokens() {
        accessToken = nil
        refreshToken = nil
        tokenExpiry = nil
    }
    
    func isTokenValid() -> Bool {
        return hasValidToken
    }
}