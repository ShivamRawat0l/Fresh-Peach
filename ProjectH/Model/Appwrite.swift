//
//  Appwrite.swift
//  ProjectH
//
//  Created by Shivam Rawat on 28/05/23.
//

import Foundation
import Appwrite
import NIOCore

class AppwriteSerivce : ObservableObject {
    
    static var shared = AppwriteSerivce()
    @Published var fileUploaded = true;
    
    var client =  Client()
        .setEndpoint("https://cloud.appwrite.io/v1")
        .setProject(Config.APPWRITE_PROJECT_KEY);
    
    var databases : Databases;
    var storage : Storage;
    
    
    private init(){
        databases =  Databases(client);
        storage = Storage(client);
    }
    
    func createUser(userId:String, name:String, email:String, pfp: String){
        Task {
            do {
                _ = try await databases.createDocument(
                    databaseId:  Config.APPWRITE_DATABASE_ID,
                    collectionId: Config.APPWRITE_USER_COLLECTION_ID,
                    documentId: userId,
                    data: [
                        "id" : userId,
                        "name" : name,
                        "email" : email,
                        "profilePicture" : pfp,
                    ] as [String : Any]
                )
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func createAudioFile(audioId: String, title:String,userId: String, isComment : Bool,parentId: String?){
        Task {
            do {
                _ = try await databases.createDocument(
                    databaseId:  Config.APPWRITE_DATABASE_ID,
                    collectionId: Config.APPWRITE_AUDIO_COLLECTION_ID,
                    documentId: audioId,
                    data: [
                        "id" : audioId,
                        "name" : audioId,
                        "title" : title,
                        "userId" : userId,
                        "isComment" : isComment,
                        "commentParent": parentId ?? "",
                        "likes": [String](),
                        "dislikes": [String]()
                    ] as [String : Any]
                )
                addAudioToStorage(audioId: audioId);
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func deleteRecording( audioId : String ){
        
    }
    
    func addAudioToStorage(audioId : String) {
        Task {
            do {
                let audioData = try Data(contentsOf: AudioManager.fetchAllRecording()[0] )
                let byteBuffer = ByteBuffer(data: audioData)
                _ = try await storage.createFile(
                    bucketId: Config.APPWRITE_BUCKET_ID,
                    fileId: audioId,
                    file: InputFile.fromBuffer(
                        byteBuffer,
                        filename: "\(audioId).m4c",
                        mimeType: "audio/m4c"
                    ),
                    permissions: nil
                )
            }
            catch{
                print(error.localizedDescription)
            }
        }
    }
}
