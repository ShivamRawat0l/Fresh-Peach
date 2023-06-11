//
//  ProfileHeader.swift
//  ProjectH
//
//  Created by Shivam Rawat on 04/06/23.
//

import SwiftUI

struct ProfileHeader: View {
    
    
    @EnvironmentObject var googleAuthService : GoogleAuthService ;
    var body: some View {
        HStack(alignment: .center){
                NavigationLink {
                    Profile()
                }
                label : {
                    AsyncImage(url: URL(string:googleAuthService.profilePic),scale: 1) { status in
                        status
                            .resizable()
                            .scaledToFill()
                    }
                placeholder: {
                    Color.purple.opacity(0.1)
                }
                .frame(width:60,height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                Spacer()
                Text("Your Feed!").font(.custom("Poppins-ExtraBold", size: 30))
            }
            .padding()
    }
}

struct ProfileHeader_Previews: PreviewProvider {
    static var previews: some View {
        ProfileHeader()
    }
}
