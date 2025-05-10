//
//  Login.swift
//  GittleHub
//
//  Created by Softwind on 2025/5/7.
//

import Foundation
import SwiftUI
import Combine
import WebKit
import LocalAuthentication

class LoginVM: ObservableObject {

    @Published
    var loginFailed: Bool = false

    @Security.Encrypted
    var cs = "e0b28cd2630c17580cc560a7191db1de6004b301e1610e0d659a2238b76d5fc9c90afdbef0056e1e00990c063ed71c4e"
    @Security.Encrypted
    var ci = "09a3567b1c1a5cbb9cb29045648dd6b32b729ea61156e6e18ae289f83a744b3b"

    @Published
    var needsBiometry: Bool = false
    
    var code: String?
    
    lazy var state = { UUID().uuidString  }()
    
    lazy var requestURL = { "https://\(GeneralGHRequest.GHHost)/login/oauth/authorize?client_id=\(self.ci)&state=\(self.state)" } ()

    func performUserAutoLogin() async {
        guard let code = code else {
            return
        }
        await MainActor.run {
            self.needsBiometry = false
        }
        do {
            let model = try await BearerToken.post(params: [
                "client_id": self.ci,
                "client_secret": self.cs,
                "code": code,
                "redirect_uri": "http://127.0.0.1/github/callback",
                "state": self.state
            ])
            A.token = model
            let user = try await User.get()
            await MainActor.run {
                A.user = user
                A.showLoginPage = false
            }
        } catch {
            await MainActor.run {
                A.showLoginPage = false
                A.errorMessage = "\(error)"
            }
        }
    }
    
    func onUserLogin(view: WKWebView, action: WKNavigationAction) -> WKNavigationActionPolicy {
        if let url = action.request.url,
           let uc = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            if uc.path == "/github/callback",
               let code = uc.queryItems?.first(where: { $0.name == "code" })?.value {
                self.code = code
                // wait for faceid
//                self.needsBiometry = true
                Task {
                    await self.performUserAutoLogin()
                }
                return .cancel
            } else if uc.path == "/login",
                      uc.host == "github.com" {
//                self.isNewLogin = true
                return .allow
            } else {
                return .allow
            }
        } else {
            return .allow
        }
    }
}

class FaceIDAuthenticator: ObservableObject {

    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    @Published var isAuthenticating = false
    
    private let context = LAContext()
    
    func authenticate() {
        isAuthenticating = true
        
        // 检查设备是否支持 Face ID/Touch ID
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // 支持生物识别
            let reason = "请使用 Face ID 解锁应用"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, error in
                DispatchQueue.main.async {
                    self?.isAuthenticating = false
                    
                    if success {
                        self?.isAuthenticated = true
                        self?.errorMessage = nil
                    } else {
                        // 认证失败，处理错误
                        self?.errorMessage = self?.handleAuthenticationError(error)
                    }
                }
            }
        } else {
            // 不支持生物识别，可能需要密码或其他验证方式
            isAuthenticating = false
            errorMessage = handleAuthenticationError(error)
        }
    }

    private func handleAuthenticationError(_ error: Error?) -> String {
        guard let error = error as NSError? else {
            return "身份验证失败"
        }

        switch error.code {
        case LAError.biometryNotAvailable.rawValue:
            return "Face ID/Touch ID 不可用"
        case LAError.biometryNotEnrolled.rawValue:
            return "Face ID/Touch ID 未设置"
        case LAError.biometryLockout.rawValue:
            return "Face ID/Touch ID 已被锁定，请使用密码"
        case LAError.userFallback.rawValue:
            return "用户选择了其他验证方式"
        case LAError.userCancel.rawValue:
            return "用户取消了验证"
        default:
            return "身份验证失败: \(error.localizedDescription)"
        }
    }

    func checkBiometricType() -> LABiometryType {
        return context.biometryType
    }
}
