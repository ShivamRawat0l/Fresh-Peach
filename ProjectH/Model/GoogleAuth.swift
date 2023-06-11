//
//  Auth.swift
//  ProjectH
//
//  Created by Shivam Rawat on 27/05/23.
//

import Foundation
import GoogleSignIn
import SwiftUI
class GoogleAuthService : ObservableObject{
    @Published var accessToken = "";
    @Published var email = "";
    @Published var profilePic : String = "";
    @Published var userName : String = "";
    @Published var userId : String = "";
    
    var appWrite = AppwriteSerivce.shared;
    
    func signin ()  {
        guard let windowScene =  UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        guard let rootViewController =  windowScene.windows.first?.rootViewController else { return }
         GIDSignIn.sharedInstance.signIn(withPresenting:rootViewController, hint: "Login account") { signInResult, error in
            if error != nil {
                return
            }
            guard let result = signInResult else {
                return
            }
             Task {
                await self.handleLogin(result.user, error)
             }
        }
    }
    
    func handleLogin (_ signInResult : GIDGoogleUser , _ error : Error?) async {
        if let userIdSafe = signInResult.userID {
            DispatchQueue.main.async {
                self.accessToken = signInResult.accessToken.tokenString
                self.email = signInResult.profile?.email ?? "" ;
                self.profilePic = signInResult.profile?.imageURL(withDimension: 1024)?.absoluteString ?? "" ;
                self.userName = signInResult.profile?.name ?? "";
                self.userId = userIdSafe ;
            }
           await appWrite.createUser(userId: userIdSafe, name: userName, email: email, pfp: profilePic)
        }
       
    }
    
    func restoreLogin()  {
         GIDSignIn.sharedInstance.restorePreviousSignIn  { user, error in
            if error != nil {
                return
            }
            guard let result = user else {
                return
            }
             Task{
                 await self.handleLogin(result, error)
             }
        }
    }
    
    func signout() {
        GIDSignIn.sharedInstance.signOut()
        accessToken = "";
    }
}
