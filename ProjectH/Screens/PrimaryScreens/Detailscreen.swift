//
//  Detailscreen.swift
//  ProjectH
//
//  Created by Shivam Rawat on 27/05/23.
//

import SwiftUI

struct Detailscreen: View {
    var hootValue : HootsStructure;
    var appwrite = AppwriteSerivce.shared;
    @State var comments = [HootsStructure]();
    var body: some View {
        VStack{
            AudioComponent(hootObject: hootValue)
            List {
                ForEach(0..<comments.count , id: \.self) { index in
                    AudioComponent(hootObject: comments[index])
                }
            }
        }.task {
            comments = await appwrite.getCommentsFor(id: hootValue.id)
        }
        
        
    }
}

struct Detailscreen_Previews: PreviewProvider {
    static var previews: some View {
        Detailscreen(hootValue: .init(title: "Title", id: "someID", name: "Some Name", userId: "someID", isComment: false, likes: [], dislikes: [], commentParent: "someID", comments: [], waveform: [],profilePic:""))
    }
}
