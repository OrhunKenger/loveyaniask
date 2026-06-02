//
//  AuthGateView.swift
//  Loveyaniask
//
//  Uygulamanın "kapısı": giriş yapılmadıysa splash/login/şifre,
//  giriş yapıldıysa ana uygulamayı (RootView) gösterir.
//

import SwiftUI

struct AuthGateView: View {
    let dependencies: AppDependencies

    @State private var auth: AuthViewModel

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        _auth = State(initialValue: dependencies.makeAuthViewModel())
    }

    var body: some View {
        Group {
            if auth.isAuthenticated {
                RootView(dependencies: dependencies)
            } else {
                switch auth.stage {
                case .splash:
                    SplashView { auth.finishSplash() }
                case .selectProfile:
                    LoginView { auth.select($0) }
                case .password:
                    if let profile = auth.selectedProfile {
                        PasswordView(viewModel: auth, profile: profile)
                    }
                }
            }
        }
        .animation(.easeInOut, value: auth.stage)
        .animation(.easeInOut, value: auth.isAuthenticated)
    }
}
