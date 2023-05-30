//
//  Profile.swift
//  ProjectH
//
//  Created by Shivam Rawat on 27/05/23.
//

import SwiftUI

struct Profile: View {
    @EnvironmentObject var googleAuthService  : GoogleAuthService ;
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        Group {
            Text("Home Screen")
            Button {
                googleAuthService.signout();
            } label: {
                Text("Sign Out")
            }
        }
    }
}

struct Profile_Previews: PreviewProvider {
    static var previews: some View {
        Profile()
    }
}
