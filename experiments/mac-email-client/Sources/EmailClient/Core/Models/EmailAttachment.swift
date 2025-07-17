import CoreData
import Foundation
import UniformTypeIdentifiers

@objc(EmailAttachment)
public class EmailAttachment: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var filename: String
    @NSManaged public var mimeType: String
    @NSManaged public var size: Int64
    @NSManaged public var contentID: String?
    @NSManaged public var isInline: Bool
    @NSManaged public var localPath: String?
    @NSManaged public var downloadURL: String?
    @NSManaged public var isDownloaded: Bool
    @NSManaged public var message: EmailMessage?
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID()
        isInline = false
        isDownloaded = false
        size = 0
    }
}

// MARK: - Computed Properties
extension EmailAttachment {
    var fileExtension: String {
        return (filename as NSString).pathExtension.lowercased()
    }
    
    var formattedSize: String {
        return ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
    
    var utType: UTType? {
        if !mimeType.isEmpty {
            return UTType(mimeType: mimeType)
        }
        return UTType(filenameExtension: fileExtension)
    }
    
    var isImage: Bool {
        guard let utType = utType else { return false }
        return utType.conforms(to: .image)
    }
    
    var isDocument: Bool {
        guard let utType = utType else { return false }
        return utType.conforms(to: .data) && !isImage
    }
    
    var systemImageName: String {
        if isImage {
            return "photo"
        } else if fileExtension == "pdf" {
            return "doc.richtext"
        } else if ["doc", "docx"].contains(fileExtension) {
            return "doc.text"
        } else if ["xls", "xlsx"].contains(fileExtension) {
            return "tablecells"
        } else if ["ppt", "pptx"].contains(fileExtension) {
            return "rectangle.stack"
        } else if ["zip", "rar", "7z"].contains(fileExtension) {
            return "archivebox"
        } else {
            return "doc"
        }
    }
    
    var canPreview: Bool {
        return isImage || ["pdf", "txt", "rtf"].contains(fileExtension)
    }
}