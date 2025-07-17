import SwiftUI

struct ContentView: View {
    @EnvironmentObject var accountManager: AccountManager
    @EnvironmentObject var appState: AppState
    @State private var showingAccountSetup = false
    @State private var selectedFolder: EmailFolder?
    @State private var selectedMessage: EmailMessage?
    
    var body: some View {
        NavigationSplitView {
            SidebarView(selectedFolder: $selectedFolder)
        } content: {
            MessageListView(
                folder: selectedFolder,
                selectedMessage: $selectedMessage
            )
        } detail: {
            if let selectedMessage = selectedMessage {
                MessageDetailView(message: selectedMessage)
            } else {
                MessagePlaceholderView()
            }
        }
        .navigationSplitViewStyle(.balanced)
        .sheet(isPresented: $showingAccountSetup) {
            AccountSetupFlow()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add Account") {
                    showingAccountSetup = true
                }
            }
        }
        .onAppear {
            if accountManager.accounts.isEmpty {
                showingAccountSetup = true
            }
        }
    }
}

// MARK: - Sidebar View
struct SidebarView: View {
    @EnvironmentObject var accountManager: AccountManager
    @Binding var selectedFolder: EmailFolder?
    
    var body: some View {
        List(selection: $selectedFolder) {
            ForEach(accountManager.accounts, id: \.id) { account in
                if account.isActive {
                    AccountSection(account: account)
                }
            }
        }
        .navigationTitle("Mailboxes")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AccountSection: View {
    let account: EmailAccount
    
    var body: some View {
        Section(account.displayName) {
            ForEach(account.folderArray, id: \.id) { folder in
                FolderRow(folder: folder)
            }
        }
    }
}

struct FolderRow: View {
    let folder: EmailFolder
    
    var body: some View {
        HStack {
            Image(systemName: folder.systemImageName)
                .foregroundColor(.secondary)
            
            Text(folder.displayName)
            
            Spacer()
            
            if folder.hasUnreadMessages {
                Text("\(folder.unreadCount)")
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }
    }
}

// MARK: - Message List View
struct MessageListView: View {
    let folder: EmailFolder?
    @Binding var selectedMessage: EmailMessage?
    @State private var messages: [EmailMessage] = []
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            if let folder = folder {
                List(filteredMessages, id: \.id, selection: $selectedMessage) { message in
                    MessageRow(message: message)
                }
                .searchable(text: $searchText, prompt: "Search messages")
                .navigationTitle(folder.displayName)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Compose") {
                            // TODO: Show compose view
                        }
                    }
                }
            } else {
                MessagePlaceholderView()
            }
        }
        .onChange(of: folder) { newFolder in
            loadMessages(for: newFolder)
        }
    }
    
    private var filteredMessages: [EmailMessage] {
        if searchText.isEmpty {
            return messages
        } else {
            return messages.filter { message in
                message.subject.localizedCaseInsensitiveContains(searchText) ||
                message.fromAddress.localizedCaseInsensitiveContains(searchText) ||
                message.bodyText?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
    }
    
    private func loadMessages(for folder: EmailFolder?) {
        guard let folder = folder else {
            messages = []
            return
        }
        
        messages = folder.messageArray
    }
}

struct MessageRow: View {
    let message: EmailMessage
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(message.displayFromName)
                        .font(.headline)
                        .fontWeight(message.isRead ? .regular : .bold)
                    
                    Spacer()
                    
                    Text(message.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(message.displaySubject)
                    .font(.subheadline)
                    .fontWeight(message.isRead ? .regular : .medium)
                    .lineLimit(1)
                
                if let bodyText = message.bodyText {
                    Text(bodyText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            VStack {
                if message.hasAttachments {
                    Image(systemName: "paperclip")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                
                if message.isStarred {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }
                
                if message.isFlagged {
                    Image(systemName: "flag.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        }
        .padding(.vertical, 4)
        .background(message.isRead ? Color.clear : Color.blue.opacity(0.1))
        .contextMenu {
            MessageContextMenu(message: message)
        }
    }
}

struct MessageContextMenu: View {
    let message: EmailMessage
    
    var body: some View {
        Button(message.isRead ? "Mark as Unread" : "Mark as Read") {
            toggleReadStatus()
        }
        
        Button(message.isStarred ? "Remove Star" : "Add Star") {
            toggleStarStatus()
        }
        
        Button(message.isFlagged ? "Remove Flag" : "Add Flag") {
            toggleFlagStatus()
        }
        
        Divider()
        
        Button("Delete", role: .destructive) {
            deleteMessage()
        }
    }
    
    private func toggleReadStatus() {
        message.isRead.toggle()
        CoreDataStack.shared.save()
    }
    
    private func toggleStarStatus() {
        message.isStarred.toggle()
        CoreDataStack.shared.save()
    }
    
    private func toggleFlagStatus() {
        message.isFlagged.toggle()
        CoreDataStack.shared.save()
    }
    
    private func deleteMessage() {
        message.isDeleted = true
        CoreDataStack.shared.save()
    }
}

// MARK: - Message Detail View
struct MessageDetailView: View {
    let message: EmailMessage
    @State private var showingAttachments = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(message.displaySubject)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack {
                        Text("From: \(message.displayFromName)")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text(message.formattedDate)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if !message.toAddressArray.isEmpty {
                        Text("To: \(message.toAddressArray.joined(separator: ", "))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if !message.ccAddressArray.isEmpty {
                        Text("Cc: \(message.ccAddressArray.joined(separator: ", "))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Divider()
                
                // Attachments
                if message.hasAttachments {
                    AttachmentListView(attachments: message.attachmentArray)
                }
                
                // Body
                if let bodyHTML = message.bodyHTML {
                    HTMLView(html: bodyHTML)
                } else if let bodyText = message.bodyText {
                    Text(bodyText)
                        .font(.body)
                        .textSelection(.enabled)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Message")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Reply") {
                    // TODO: Show compose view with reply
                }
            }
        }
        .onAppear {
            markAsRead()
        }
    }
    
    private func markAsRead() {
        if !message.isRead {
            message.isRead = true
            CoreDataStack.shared.save()
        }
    }
}

// MARK: - Attachment List View
struct AttachmentListView: View {
    let attachments: [EmailAttachment]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Attachments")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 200))
            ], spacing: 8) {
                ForEach(attachments, id: \.id) { attachment in
                    AttachmentRow(attachment: attachment)
                }
            }
        }
    }
}

struct AttachmentRow: View {
    let attachment: EmailAttachment
    
    var body: some View {
        HStack {
            Image(systemName: attachment.systemImageName)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading) {
                Text(attachment.filename)
                    .font(.caption)
                    .lineLimit(1)
                
                Text(attachment.formattedSize)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if attachment.isDownloaded {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Button("Download") {
                    // TODO: Download attachment
                }
                .buttonStyle(.borderless)
                .font(.caption)
            }
        }
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(4)
    }
}

// MARK: - HTML View
struct HTMLView: View {
    let html: String
    
    var body: some View {
        // TODO: Implement proper HTML rendering
        Text("HTML content rendering not implemented yet")
            .foregroundColor(.secondary)
            .italic()
    }
}

// MARK: - Placeholder View
struct MessagePlaceholderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "envelope")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("Select a message to read")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
    }
}