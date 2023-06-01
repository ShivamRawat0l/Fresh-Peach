//
//  Hoots.swift
//  ProjectH
//
//  Created by Shivam Rawat on 30/05/23.
//

import Foundation

class HootsStructure : Codable{
    var title:  String;
    var id: String;
    var name: String;
    var userId : String ;
    var isComment: Bool;
    var likes : [String];
    var comments : [String]
    var dislikes: [String];
    var commentParent : String;
    var waveform : [Float];
    init(title: String, id: String, name: String, userId: String, isComment: Bool, likes: [String], dislikes: [String], commentParent: String, comments: [String],waveform : [Float]) {
        self.title = title
        self.id = id
        self.name = name
        self.userId = userId
        self.isComment = isComment
        self.likes = likes
        self.dislikes = dislikes
        self.commentParent = commentParent
        self.comments = comments
        self.waveform = waveform;
    }
}

enum PostType  {
    case recent
    case likes
}

class Hoots : ObservableObject {
    @Published var  hootsData = [HootsStructure]() ;

    func getPosts(_ type : PostType = PostType.recent) async {
        if(type == PostType.recent){
            self.hootsData = await AppwriteSerivce.shared.getRecentHoots();
            print("HERE ", self.hootsData)
        }else {
            self.hootsData = await AppwriteSerivce.shared.getLikedHoots();
        }
    }
    
}
