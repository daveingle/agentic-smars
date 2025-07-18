import Foundation
import Combine
import AuthenticationServices

class OAuth2Manager: NSObject, ObservableObject {
    static let shared = OAuth2Manager()
    
    @Published var isAuthenticating = false
    @Published var authenticationError: Error?
    
    private var authSession: ASWebAuthenticationSession?
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
    }
    
    // MARK: - Gmail OAuth2
    func authenticateWithGmail() async throws -> OAuth2Token {
        let clientID = "your-gmail-client-id"
        let redirectURI = "com.yourapp.emailclient://oauth/gmail"
        let scope = "https://www.googleapis.com/auth/gmail.readonly https://www.googleapis.com/auth/gmail.send"
        
        let authURL = buildGmailAuthURL(clientID: clientID, redirectURI: redirectURI, scope: scope)
        let authCode = try await performAuthFlow(authURL: authURL, callbackScheme: "com.yourapp.emailclient")
        
        return try await exchangeGmailCodeForTokens(
            authCode: authCode,
            clientID: clientID,
            redirectURI: redirectURI
        )
    }
    
    private func buildGmailAuthURL(clientID: String, redirectURI: String, scope: String) -> URL {
        let codeChallenge = generateCodeChallenge()
        var components = URLComponents(string: "https://accounts.google.com/o/oauth2/v2/auth")!
        
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: scope),
            URLQueryItem(name: "access_type", value: "offline"),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: "S256")
        ]
        
        return components.url!
    }
    
    private func exchangeGmailCodeForTokens(authCode: String, clientID: String, redirectURI: String) async throws -> OAuth2Token {
        let tokenURL = URL(string: "https://oauth2.googleapis.com/token")!
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let codeVerifier = getStoredCodeVerifier()
        let body = [
            "client_id": clientID,
            "code": authCode,
            "grant_type": "authorization_code",
            "redirect_uri": redirectURI,
            "code_verifier": codeVerifier
        ]
        
        request.httpBody = body.compactMap { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(OAuth2TokenResponse.self, from: data)
        
        return OAuth2Token(
            accessToken: response.access_token,
            refreshToken: response.refresh_token,
            expiresIn: response.expires_in,
            tokenType: response.token_type
        )
    }
    
    // MARK: - Microsoft Graph OAuth2
    func authenticateWithMicrosoft() async throws -> OAuth2Token {
        let clientID = "your-microsoft-client-id"
        let redirectURI = "com.yourapp.emailclient://oauth/microsoft"
        let scope = "https://graph.microsoft.com/Mail.ReadWrite https://graph.microsoft.com/Mail.Send"
        
        let authURL = buildMicrosoftAuthURL(clientID: clientID, redirectURI: redirectURI, scope: scope)
        let authCode = try await performAuthFlow(authURL: authURL, callbackScheme: "com.yourapp.emailclient")
        
        return try await exchangeMicrosoftCodeForTokens(
            authCode: authCode,
            clientID: clientID,
            redirectURI: redirectURI
        )
    }
    
    private func buildMicrosoftAuthURL(clientID: String, redirectURI: String, scope: String) -> URL {
        let codeChallenge = generateCodeChallenge()
        var components = URLComponents(string: "https://login.microsoftonline.com/common/oauth2/v2.0/authorize")!
        
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: scope),
            URLQueryItem(name: "response_mode", value: "query"),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: "S256")
        ]
        
        return components.url!
    }
    
    private func exchangeMicrosoftCodeForTokens(authCode: String, clientID: String, redirectURI: String) async throws -> OAuth2Token {
        let tokenURL = URL(string: "https://login.microsoftonline.com/common/oauth2/v2.0/token")!
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let codeVerifier = getStoredCodeVerifier()
        let body = [
            "client_id": clientID,
            "code": authCode,
            "grant_type": "authorization_code",
            "redirect_uri": redirectURI,
            "code_verifier": codeVerifier
        ]
        
        request.httpBody = body.compactMap { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(OAuth2TokenResponse.self, from: data)
        
        return OAuth2Token(
            accessToken: response.access_token,
            refreshToken: response.refresh_token,
            expiresIn: response.expires_in,
            tokenType: response.token_type
        )
    }
    
    // MARK: - Token Refresh
    func refreshToken(_ token: OAuth2Token, provider: EmailAccount.Provider) async throws -> OAuth2Token {
        switch provider {
        case .gmail:
            return try await refreshGmailToken(token)
        case .outlook:
            return try await refreshMicrosoftToken(token)
        default:
            throw OAuth2Error.unsupportedProvider
        }
    }
    
    private func refreshGmailToken(_ token: OAuth2Token) async throws -> OAuth2Token {
        let tokenURL = URL(string: "https://oauth2.googleapis.com/token")!
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let body = [
            "client_id": "your-gmail-client-id",
            "refresh_token": token.refreshToken ?? "",
            "grant_type": "refresh_token"
        ]
        
        request.httpBody = body.compactMap { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(OAuth2TokenResponse.self, from: data)
        
        return OAuth2Token(
            accessToken: response.access_token,
            refreshToken: response.refresh_token ?? token.refreshToken,
            expiresIn: response.expires_in,
            tokenType: response.token_type
        )
    }
    
    private func refreshMicrosoftToken(_ token: OAuth2Token) async throws -> OAuth2Token {
        let tokenURL = URL(string: "https://login.microsoftonline.com/common/oauth2/v2.0/token")!
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let body = [
            "client_id": "your-microsoft-client-id",
            "refresh_token": token.refreshToken ?? "",
            "grant_type": "refresh_token"
        ]
        
        request.httpBody = body.compactMap { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(OAuth2TokenResponse.self, from: data)
        
        return OAuth2Token(
            accessToken: response.access_token,
            refreshToken: response.refresh_token ?? token.refreshToken,
            expiresIn: response.expires_in,
            tokenType: response.token_type
        )
    }
    
    // MARK: - Authentication Flow
    private func performAuthFlow(authURL: URL, callbackScheme: String) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                self.authSession = ASWebAuthenticationSession(
                    url: authURL,
                    callbackURLScheme: callbackScheme
                ) { callbackURL, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    guard let callbackURL = callbackURL,
                          let code = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)?
                        .queryItems?
                        .first(where: { $0.name == "code" })?
                        .value else {
                        continuation.resume(throwing: OAuth2Error.invalidAuthCode)
                        return
                    }
                    
                    continuation.resume(returning: code)
                }
                
                self.authSession?.presentationContextProvider = self
                self.authSession?.prefersEphemeralWebBrowserSession = true
                self.authSession?.start()
            }
        }
    }
    
    // MARK: - PKCE Implementation
    private func generateCodeChallenge() -> String {
        let codeVerifier = generateCodeVerifier()
        storeCodeVerifier(codeVerifier)
        
        let digest = Data(codeVerifier.utf8).sha256
        return digest.base64URLEncodedString()
    }
    
    private func generateCodeVerifier() -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"
        return String((0..<128).compactMap { _ in characters.randomElement() })
    }
    
    private func storeCodeVerifier(_ verifier: String) {
        UserDefaults.standard.set(verifier, forKey: "oauth2_code_verifier")
    }
    
    private func getStoredCodeVerifier() -> String {
        return UserDefaults.standard.string(forKey: "oauth2_code_verifier") ?? ""
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding
extension OAuth2Manager: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}

// MARK: - Data Models
struct OAuth2Token {
    let accessToken: String
    let refreshToken: String?
    let expiresIn: TimeInterval
    let tokenType: String
    
    var expiryDate: Date {
        return Date().addingTimeInterval(expiresIn)
    }
}

struct OAuth2TokenResponse: Codable {
    let access_token: String
    let refresh_token: String?
    let expires_in: TimeInterval
    let token_type: String
    let scope: String?
}

enum OAuth2Error: Error, LocalizedError {
    case invalidAuthCode
    case tokenExchangeFailed
    case unsupportedProvider
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidAuthCode:
            return "Invalid authorization code received"
        case .tokenExchangeFailed:
            return "Failed to exchange code for tokens"
        case .unsupportedProvider:
            return "OAuth2 not supported for this provider"
        case .networkError:
            return "Network error during authentication"
        }
    }
}

// MARK: - Data Extensions
extension Data {
    var sha256: Data {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(count), &hash)
        }
        return Data(hash)
    }
    
    func base64URLEncodedString() -> String {
        return base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

// Import for CC_SHA256
import CommonCrypto