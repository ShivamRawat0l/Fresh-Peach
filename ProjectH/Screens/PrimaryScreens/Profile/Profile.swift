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
        ZStack{
            Color("Background").ignoresSafeArea()
            VStack {
                AsyncImage(url: URL(string: googleAuthService.profilePic),scale:1){ status in
                    status.resizable().scaledToFit()
                } placeholder: {
                    Color.black
                }
                .frame(width: 200, height: 200)
                .cornerRadius(150)
                Text(googleAuthService.userName)
                Text(googleAuthService.email)

                Spacer()
                Button {
                    googleAuthService.signout();
                } label: {
                    Text("Sign Out")
                }
            }
        }
    }
}

struct Profile_Previews: PreviewProvider {
    static var previews: some View {
        Profile()
    }
}
