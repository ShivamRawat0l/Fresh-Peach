//
//  RootNavigator.swift
//  ProjectH
//
//  Created by Shivam Rawat on 26/05/23.
//

import SwiftUI

struct RootNavigator: View {
    @EnvironmentObject   var googleAuthService : GoogleAuthService;
    var body: some View {
        NavigationView {
            ZStack(alignment: .center) {
                Color(googleAuthService.accessToken != "" ? "Background" : "Secondary").ignoresSafeArea()
                Group{
                    if( googleAuthService.accessToken != "" ){
                        Homescreen()
                    }
                    else{
                        OnboardingView()
                    }
                }
            }
        }.environmentObject(googleAuthService)
    }
}

struct RootNavigator_Previews: PreviewProvider {
    
    static var previews: some View {
        RootNavigator()
    }
}
