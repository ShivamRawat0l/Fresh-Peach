//
//  SignIn.swift
//  ProjectH
//
//  Created by Shivam Rawat on 26/05/23.
//

import SwiftUI

struct Signup: View {
    @State var email : String = "";
    @State var password : String = "";
    @State var navigateToLogin = false;
    var body: some View {
        NavigationLink( destination: Login(),isActive: $navigateToLogin) {}
        VStack{
            TextField("Email", text: $email).font(Font.system(size:30))
            TextField("Password", text: $password).font(Font.system(size:30)).padding(.bottom,200)
            Spacer()
            PrimaryButton(text:"Sign Up"){
                
            }
            PrimaryButton(text:"Already a member ?"){
                navigateToLogin = true; 
            }
            PrimaryButton(text:"Sign up with Google"){
                
            }
        }.navigationBarTitle("Signup")
        
    }
}


struct Signup_Previews: PreviewProvider {
    static var previews: some View {
        Signup()
    }
}
