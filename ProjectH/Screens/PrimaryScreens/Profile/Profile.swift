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
            VStack{
                AsyncImage(url: URL(string: googleAuthService.profilePic),scale:1){ status in
                    status.resizable().scaledToFit()
                } placeholder: {
                    Color.black
                }
                .frame(width: 200, height: 200)
                .cornerRadius(150)
                VStack (alignment: .leading) {
                        Text("Username: ")
                            .font(.custom("Poppins-Thin", size: 20))
                        Text(googleAuthService.userName)
                            .font(.custom("Poppins-ExtraBold", size: 20))
                    
                        Text("Email: ")
                            .font(.custom("Poppins-Think", size: 20))
                        Text(googleAuthService.email)
                            .font(.custom("Poppins-ExtraBold", size: 20))
                    
                }.padding(.top, 20)
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
