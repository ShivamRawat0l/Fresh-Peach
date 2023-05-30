//
//  Login.swift
//  ProjectH
//
//  Created by Shivam Rawat on 26/05/23.
//

import SwiftUI

struct Login: View {
    @State var email : String = "";
    @State var password : String = "";
    @State var navigateToSignup = false;
    
    var body: some View {
        NavigationLink( destination: Signup(),isActive: $navigateToSignup){
        }
        VStack{
            TextField("Email", text: $email).font(Font.system(size:30))
            TextField("Password", text: $password).font(Font.system(size:30)).padding(.bottom,200)
            Spacer()
            PrimaryButton(text:"Log In"){
            }
            PrimaryButton(text:"Dont have an Account ?"){
                navigateToSignup = true;
            }
            PrimaryButton(text:"Login with Google"){
                
            }
        }.navigationBarTitle("Login")
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login()
    }
}
