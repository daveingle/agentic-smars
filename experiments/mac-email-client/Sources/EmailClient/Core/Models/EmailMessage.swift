import CoreData
import Foundation

@objc(EmailMessage)
public class EmailMessage: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var messageID: String
    @NSManaged public var threadID: String?
    @NSManaged public var subject: String
    @NSManaged public var fromAddress: String
    @NSManaged public var fromName: String?
    @NSManaged public var toAddresses: String
    @NSManaged public var ccAddresses: String?
    @NSManaged public var bccAddresses: String?
    @NSManaged public var date: Date
    @NSManaged public var isRead: Bool
    @NSManaged public var isStarred: Bool
    @NSManaged public var isFlagged: Bool
    @NSManaged public var isDeleted: Bool
    @NSManaged public var bodyText: String?
    @NSManaged public var bodyHTML: String?
    @NSManaged public var hasAttachments: Bool
    @NSManaged public var size: Int64
    @NSManaged public var importance: Int16
    @NSManaged public var account: EmailAccount?
    @NSManaged public var folder: EmailFolder?
    @NSManaged public var attachments: NSSet?
    @NSManaged public var syncMetadata: SyncMetadata?
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID()
        date = Date()
        isRead = false
        isStarred = false
        isFlagged = false
        isDeleted = false
        hasAttachments = false
        size = 0
        importance = 1
    }
}

// MARK: - Relationships
extension EmailMessage {
    @objc(addAttachmentsObject:)
    @NSManaged public func addToAttachments(_ value: EmailAttachment)
    
    @objc(removeAttachmentsObject:)
    @NSManaged public func removeFromAttachments(_ value: EmailAttachment)
    
    @objc(addAttachments:)
    @NSManaged public func addToAttachments(_ values: NSSet)
    
    @objc(removeAttachments:)
    @NSManaged public func removeFromAttachments(_ values: NSSet)
}

// MARK: - Computed Properties
extension EmailMessage {
    var attachmentArray: [EmailAttachment] {
        let set = attachments as? Set<EmailAttachment> ?? []
        return set.sorted { $0.filename < $1.filename }
    }
    
    var displaySubject: String {
        return subject.isEmpty ? "(No Subject)" : subject
    }
    
    var displayFromName: String {
        return fromName ?? fromAddress
    }
    
    var toAddressArray: [String] {
        return toAddresses.components(separatedBy: ";").filter { !$0.isEmpty }
    }
    
    var ccAddressArray: [String] {
        return ccAddresses?.components(separatedBy: ";").filter { !$0.isEmpty } ?? []
    }
    
    var bccAddressArray: [String] {
        return bccAddresses?.components(separatedBy: ";").filter { !$0.isEmpty } ?? []
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(date)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        
        if isToday {
            formatter.timeStyle = .short
            return formatter.string(from: date)
        } else if isYesterday {
            return "Yesterday"
        } else if Calendar.current.isDate(date, equalTo: Date(), toGranularity: .year) {
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        } else {
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: date)
        }
    }
}

// MARK: - Message Importance
extension EmailMessage {
    enum Importance: Int16, CaseIterable {
        case low = 0
        case normal = 1
        case high = 2
        
        var displayName: String {
            switch self {
            case .low: return "Low"
            case .normal: return "Normal"
            case .high: return "High"
            }
        }
    }
    
    var importanceLevel: Importance {
        get { Importance(rawValue: importance) ?? .normal }
        set { importance = newValue.rawValue }
    }
}