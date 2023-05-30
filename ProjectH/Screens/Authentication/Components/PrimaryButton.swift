//
//  PrimaryButton.swift
//  ProjectH
//
//  Created by Shivam Rawat on 26/05/23.
//

import SwiftUI

struct PrimaryButton: View {
    var text = "";
    var onAction: () -> Void = { };
    var body: some View {
        Button {
            onAction()
        } label: {
            Rectangle()
                .cornerRadius(20)
                .foregroundColor(.black)
                .frame(height:80).overlay {
                    Text(text)
                }
        }
    }
}

struct PrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryButton(text: "Hello")
    }
}
