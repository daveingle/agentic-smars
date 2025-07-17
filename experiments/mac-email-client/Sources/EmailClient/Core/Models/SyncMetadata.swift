import CoreData
import Foundation

@objc(SyncMetadata)
public class SyncMetadata: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var lastSyncDate: Date?
    @NSManaged public var syncToken: String?
    @NSManaged public var deltaToken: String?
    @NSManaged public var etag: String?
    @NSManaged public var version: Int32
    @NSManaged public var isDeleted: Bool
    @NSManaged public var needsSync: Bool
    @NSManaged public var syncError: String?
    @NSManaged public var retryCount: Int32
    @NSManaged public var message: EmailMessage?
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID()
        version = 1
        isDeleted = false
        needsSync = true
        retryCount = 0
    }
}

// MARK: - Computed Properties
extension SyncMetadata {
    var hasSyncError: Bool {
        return syncError != nil && !syncError!.isEmpty
    }
    
    var shouldRetry: Bool {
        return hasSyncError && retryCount < 3
    }
    
    var lastSyncTimeInterval: TimeInterval {
        guard let lastSync = lastSyncDate else { return 0 }
        return Date().timeIntervalSince(lastSync)
    }
    
    var formattedLastSync: String {
        guard let lastSync = lastSyncDate else { return "Never" }
        let formatter = RelativeDateTimeFormatter()
        return formatter.localizedString(for: lastSync, relativeTo: Date())
    }
}

// MARK: - Sync Management
extension SyncMetadata {
    func markSyncSuccess() {
        lastSyncDate = Date()
        needsSync = false
        syncError = nil
        retryCount = 0
    }
    
    func markSyncError(_ error: String) {
        syncError = error
        retryCount += 1
        needsSync = true
    }
    
    func markNeedsSync() {
        needsSync = true
    }
    
    func incrementVersion() {
        version += 1
    }
}