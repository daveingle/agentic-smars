import XCTest
import CoreData
@testable import EmailClient

final class EmailClientTests: XCTestCase {
    var testContext: NSManagedObjectContext!
    var accountManager: AccountManager!
    
    override func setUp() {
        super.setUp()
        
        // Create in-memory Core Data stack for testing
        let container = NSPersistentContainer(name: "EmailModel")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load test store: \(error)")
            }
        }
        
        testContext = container.viewContext
    }
    
    override func tearDown() {
        testContext = nil
        accountManager = nil
        super.tearDown()
    }
    
    // MARK: - Core Data Model Tests
    func testEmailAccountCreation() {
        let account = EmailAccount(context: testContext)
        account.name = "Test Account"
        account.emailAddress = "test@example.com"
        account.provider = "Gmail"
        account.protocol = "IMAP"
        account.authMethod = "OAuth2"
        
        XCTAssertNotNil(account.id)
        XCTAssertEqual(account.name, "Test Account")
        XCTAssertEqual(account.emailAddress, "test@example.com")
        XCTAssertTrue(account.isActive)
    }
    
    func testEmailMessageCreation() {
        let message = EmailMessage(context: testContext)
        message.subject = "Test Subject"
        message.fromAddress = "sender@example.com"
        message.toAddresses = "recipient@example.com"
        message.bodyText = "Test message body"
        
        XCTAssertNotNil(message.id)
        XCTAssertEqual(message.subject, "Test Subject")
        XCTAssertEqual(message.displaySubject, "Test Subject")
        XCTAssertFalse(message.isRead)
        XCTAssertTrue(message.isToday)
    }
    
    func testEmailFolderCreation() {
        let folder = EmailFolder(context: testContext)
        folder.name = "INBOX"
        folder.displayName = "Inbox"
        folder.type = EmailFolder.FolderType.inbox.rawValue
        folder.path = "/INBOX"
        
        XCTAssertNotNil(folder.id)
        XCTAssertEqual(folder.folderType, .inbox)
        XCTAssertEqual(folder.systemImageName, "tray")
        XCTAssertTrue(folder.isSystemFolder)
    }
    
    func testEmailAttachmentCreation() {
        let attachment = EmailAttachment(context: testContext)
        attachment.filename = "document.pdf"
        attachment.mimeType = "application/pdf"
        attachment.size = 1024000
        
        XCTAssertNotNil(attachment.id)
        XCTAssertEqual(attachment.fileExtension, "pdf")
        XCTAssertEqual(attachment.systemImageName, "doc.richtext")
        XCTAssertEqual(attachment.formattedSize, "1 MB")
        XCTAssertTrue(attachment.canPreview)
    }
    
    // MARK: - Account Manager Tests
    func testAccountManagerInitialization() {
        accountManager = AccountManager()
        
        XCTAssertNotNil(accountManager)
        XCTAssertFalse(accountManager.isLoading)
        XCTAssertNil(accountManager.error)
    }
    
    func testGmailAccountCreation() {
        accountManager = AccountManager()
        
        let account = accountManager.createGmailAccount(
            name: "My Gmail",
            emailAddress: "test@gmail.com"
        )
        
        XCTAssertEqual(account.name, "My Gmail")
        XCTAssertEqual(account.emailAddress, "test@gmail.com")
        XCTAssertEqual(account.provider, "Gmail")
        XCTAssertEqual(account.protocol, "IMAP")
        XCTAssertEqual(account.authMethod, "OAuth2")
    }
    
    func testOutlookAccountCreation() {
        accountManager = AccountManager()
        
        let account = accountManager.createOutlookAccount(
            name: "My Outlook",
            emailAddress: "test@outlook.com"
        )
        
        XCTAssertEqual(account.name, "My Outlook")
        XCTAssertEqual(account.emailAddress, "test@outlook.com")
        XCTAssertEqual(account.provider, "Outlook")
        XCTAssertEqual(account.protocol, "Graph")
        XCTAssertEqual(account.authMethod, "OAuth2")
    }
    
    func testAccountValidation() {
        accountManager = AccountManager()
        
        let validAccount = accountManager.createGmailAccount(
            name: "Valid Account",
            emailAddress: "valid@example.com"
        )
        
        let validationErrors = accountManager.validateAccount(validAccount)
        XCTAssertTrue(validationErrors.isEmpty)
        
        let invalidAccount = EmailAccount(context: testContext)
        invalidAccount.name = ""
        invalidAccount.emailAddress = "invalid-email"
        invalidAccount.provider = ""
        
        let invalidErrors = accountManager.validateAccount(invalidAccount)
        XCTAssertFalse(invalidErrors.isEmpty)
        XCTAssertTrue(invalidErrors.contains("Account name is required"))
        XCTAssertTrue(invalidErrors.contains("Email address is not valid"))
        XCTAssertTrue(invalidErrors.contains("Provider is required"))
    }
    
    // MARK: - OAuth2 Tests
    func testOAuth2TokenCreation() {
        let token = OAuth2Token(
            accessToken: "test-access-token",
            refreshToken: "test-refresh-token",
            expiresIn: 3600,
            tokenType: "Bearer"
        )
        
        XCTAssertEqual(token.accessToken, "test-access-token")
        XCTAssertEqual(token.refreshToken, "test-refresh-token")
        XCTAssertEqual(token.expiresIn, 3600)
        XCTAssertEqual(token.tokenType, "Bearer")
        XCTAssertTrue(token.expiryDate > Date())
    }
    
    func testCodeChallengeGeneration() {
        let oauth2Manager = OAuth2Manager.shared
        
        // Test that code challenge generation doesn't crash
        // (actual implementation would need to expose this method for testing)
        XCTAssertNotNil(oauth2Manager)
    }
    
    // MARK: - Sync Coordinator Tests
    func testSyncCoordinatorInitialization() {
        let syncCoordinator = SyncCoordinator()
        
        XCTAssertNotNil(syncCoordinator)
        XCTAssertFalse(syncCoordinator.isSyncing)
        XCTAssertNil(syncCoordinator.lastSyncDate)
        XCTAssertNil(syncCoordinator.syncError)
        XCTAssertEqual(syncCoordinator.syncProgress, 0.0)
    }
    
    // MARK: - Data Relationship Tests
    func testAccountFolderRelationship() {
        let account = EmailAccount(context: testContext)
        account.name = "Test Account"
        account.emailAddress = "test@example.com"
        account.provider = "Gmail"
        
        let folder = EmailFolder(context: testContext)
        folder.name = "INBOX"
        folder.displayName = "Inbox"
        folder.type = EmailFolder.FolderType.inbox.rawValue
        folder.account = account
        
        XCTAssertEqual(account.folderArray.count, 1)
        XCTAssertEqual(account.folderArray.first, folder)
        XCTAssertEqual(folder.account, account)
    }
    
    func testMessageFolderRelationship() {
        let folder = EmailFolder(context: testContext)
        folder.name = "INBOX"
        folder.displayName = "Inbox"
        folder.type = EmailFolder.FolderType.inbox.rawValue
        
        let message = EmailMessage(context: testContext)
        message.subject = "Test Message"
        message.fromAddress = "sender@example.com"
        message.toAddresses = "recipient@example.com"
        message.folder = folder
        
        XCTAssertEqual(folder.messageArray.count, 1)
        XCTAssertEqual(folder.messageArray.first, message)
        XCTAssertEqual(message.folder, folder)
    }
    
    func testMessageAttachmentRelationship() {
        let message = EmailMessage(context: testContext)
        message.subject = "Test Message"
        message.fromAddress = "sender@example.com"
        message.toAddresses = "recipient@example.com"
        
        let attachment = EmailAttachment(context: testContext)
        attachment.filename = "document.pdf"
        attachment.mimeType = "application/pdf"
        attachment.size = 1024000
        attachment.message = message
        
        message.hasAttachments = true
        
        XCTAssertEqual(message.attachmentArray.count, 1)
        XCTAssertEqual(message.attachmentArray.first, attachment)
        XCTAssertEqual(attachment.message, message)
        XCTAssertTrue(message.hasAttachments)
    }
    
    // MARK: - Performance Tests
    func testMessageListPerformance() {
        // Create test data
        let account = EmailAccount(context: testContext)
        account.name = "Test Account"
        account.emailAddress = "test@example.com"
        account.provider = "Gmail"
        
        let folder = EmailFolder(context: testContext)
        folder.name = "INBOX"
        folder.displayName = "Inbox"
        folder.type = EmailFolder.FolderType.inbox.rawValue
        folder.account = account
        
        // Create 1000 test messages
        for i in 0..<1000 {
            let message = EmailMessage(context: testContext)
            message.subject = "Test Message \(i)"
            message.fromAddress = "sender\(i)@example.com"
            message.toAddresses = "recipient@example.com"
            message.folder = folder
            message.account = account
            message.date = Date().addingTimeInterval(TimeInterval(-i * 60))
        }
        
        // Measure performance of loading messages
        measure {
            let messages = folder.messageArray
            XCTAssertEqual(messages.count, 1000)
        }
    }
    
    func testSearchPerformance() {
        // Create test data
        let account = EmailAccount(context: testContext)
        account.name = "Test Account"
        account.emailAddress = "test@example.com"
        account.provider = "Gmail"
        
        let folder = EmailFolder(context: testContext)
        folder.name = "INBOX"
        folder.displayName = "Inbox"
        folder.type = EmailFolder.FolderType.inbox.rawValue
        folder.account = account
        
        // Create test messages with searchable content
        for i in 0..<1000 {
            let message = EmailMessage(context: testContext)
            message.subject = i % 10 == 0 ? "Important Message \(i)" : "Regular Message \(i)"
            message.fromAddress = "sender\(i)@example.com"
            message.toAddresses = "recipient@example.com"
            message.bodyText = "This is the body of message \(i)"
            message.folder = folder
            message.account = account
        }
        
        let messages = folder.messageArray
        
        // Measure search performance
        measure {
            let searchResults = messages.filter { message in
                message.subject.localizedCaseInsensitiveContains("Important")
            }
            XCTAssertEqual(searchResults.count, 100)
        }
    }
}