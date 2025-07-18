import CoreData
import Foundation

@objc(EmailAccount)
public class EmailAccount: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var emailAddress: String
    @NSManaged public var provider: String
    @NSManaged public var protocol: String
    @NSManaged public var authMethod: String
    @NSManaged public var syncMethod: String
    @NSManaged public var isActive: Bool
    @NSManaged public var lastSyncDate: Date?
    @NSManaged public var folders: NSSet?
    @NSManaged public var messages: NSSet?
    @NSManaged public var credentials: EmailCredentials?
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID()
        isActive = true
    }
}

// MARK: - Relationships
extension EmailAccount {
    @objc(addFoldersObject:)
    @NSManaged public func addToFolders(_ value: EmailFolder)
    
    @objc(removeFoldersObject:)
    @NSManaged public func removeFromFolders(_ value: EmailFolder)
    
    @objc(addFolders:)
    @NSManaged public func addToFolders(_ values: NSSet)
    
    @objc(removeFolders:)
    @NSManaged public func removeFromFolders(_ values: NSSet)
    
    @objc(addMessagesObject:)
    @NSManaged public func addToMessages(_ value: EmailMessage)
    
    @objc(removeMessagesObject:)
    @NSManaged public func removeFromMessages(_ value: EmailMessage)
    
    @objc(addMessages:)
    @NSManaged public func addToMessages(_ values: NSSet)
    
    @objc(removeMessages:)
    @NSManaged public func removeFromMessages(_ values: NSSet)
}

// MARK: - Computed Properties
extension EmailAccount {
    var folderArray: [EmailFolder] {
        let set = folders as? Set<EmailFolder> ?? []
        return set.sorted { $0.name < $1.name }
    }
    
    var messageArray: [EmailMessage] {
        let set = messages as? Set<EmailMessage> ?? []
        return set.sorted { $0.date > $1.date }
    }
    
    var displayName: String {
        return name.isEmpty ? emailAddress : name
    }
}

// MARK: - Provider Types
extension EmailAccount {
    enum Provider: String, CaseIterable {
        case gmail = "Gmail"
        case outlook = "Outlook"
        case icloud = "iCloud"
        case exchange = "Exchange"
        case imap = "IMAP"
        case pop3 = "POP3"
        
        var defaultProtocol: String {
            switch self {
            case .gmail: return "IMAP"
            case .outlook: return "Graph"
            case .icloud: return "IMAP"
            case .exchange: return "EWS"
            case .imap: return "IMAP"
            case .pop3: return "POP3"
            }
        }
        
        var defaultAuthMethod: String {
            switch self {
            case .gmail, .outlook: return "OAuth2"
            case .icloud: return "App Password"
            case .exchange: return "OAuth2"
            case .imap, .pop3: return "Basic"
            }
        }
    }
}