import CoreData
import Foundation

@objc(EmailFolder)
public class EmailFolder: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var displayName: String
    @NSManaged public var type: String
    @NSManaged public var path: String
    @NSManaged public var unreadCount: Int32
    @NSManaged public var totalCount: Int32
    @NSManaged public var isSelectable: Bool
    @NSManaged public var parentPath: String?
    @NSManaged public var account: EmailAccount?
    @NSManaged public var messages: NSSet?
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID()
        unreadCount = 0
        totalCount = 0
        isSelectable = true
    }
}

// MARK: - Relationships
extension EmailFolder {
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
extension EmailFolder {
    var messageArray: [EmailMessage] {
        let set = messages as? Set<EmailMessage> ?? []
        return set.sorted { $0.date > $1.date }
    }
    
    var unreadMessages: [EmailMessage] {
        return messageArray.filter { !$0.isRead }
    }
    
    var hasUnreadMessages: Bool {
        return unreadCount > 0
    }
    
    var displayUnreadCount: String {
        return unreadCount > 0 ? "(\(unreadCount))" : ""
    }
}

// MARK: - Folder Types
extension EmailFolder {
    enum FolderType: String, CaseIterable {
        case inbox = "INBOX"
        case sent = "SENT"
        case drafts = "DRAFTS"
        case trash = "TRASH"
        case spam = "SPAM"
        case archive = "ARCHIVE"
        case custom = "CUSTOM"
        
        var displayName: String {
            switch self {
            case .inbox: return "Inbox"
            case .sent: return "Sent"
            case .drafts: return "Drafts"
            case .trash: return "Trash"
            case .spam: return "Spam"
            case .archive: return "Archive"
            case .custom: return "Custom"
            }
        }
        
        var systemImageName: String {
            switch self {
            case .inbox: return "tray"
            case .sent: return "paperplane"
            case .drafts: return "doc.text"
            case .trash: return "trash"
            case .spam: return "exclamationmark.octagon"
            case .archive: return "archivebox"
            case .custom: return "folder"
            }
        }
        
        var isSystemFolder: Bool {
            return self != .custom
        }
    }
    
    var folderType: FolderType {
        get { FolderType(rawValue: type) ?? .custom }
        set { type = newValue.rawValue }
    }
    
    var systemImageName: String {
        return folderType.systemImageName
    }
    
    var isSystemFolder: Bool {
        return folderType.isSystemFolder
    }
}