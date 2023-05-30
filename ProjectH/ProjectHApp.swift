//
//  ProjectHApp.swift
//  ProjectH
//
//  Created by Shivam Rawat on 26/05/23.
//

import SwiftUI
import Appwrite
import GoogleSignInSwift
import GoogleSignIn
@main
struct ProjectHApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
   @StateObject var googleAuthService = GoogleAuthService();

    var body: some Scene {
        WindowGroup {
            RootNavigator().onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }.onAppear {
                googleAuthService.restoreLogin()
            }.environmentObject(googleAuthService)
        }
    }
}
