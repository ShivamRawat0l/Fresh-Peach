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
    var profilePic : String;
    var duration : Double;
    init(title: String, id: String, name: String, userId: String, isComment: Bool, likes: [String], dislikes: [String], commentParent: String, comments: [String],waveform : [Float], profilePic: String, duration : Double ) {
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
        self.profilePic = profilePic;
        self.duration = duration;
    }
}

enum PostType  {
    case recent
    case likes
}

