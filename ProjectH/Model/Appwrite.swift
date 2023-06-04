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
    
    func createCommentAudioFile(audioID: String, name: String , title: String, userID: String ,  parentID: String, waveform: [Float], profilePic: String , comments: [String]  ) async {
        do {
            _ = try await databases.createDocument(
                databaseId: Config.APPWRITE_DATABASE_ID,
                collectionId: Config.APPWRITE_AUDIO_COLLECTION_ID,
                documentId: audioID,
                data: [
                    "id": audioID,
                    "name": name,
                    "title": title,
                    "userId": userID,
                    "isComment": true,
                    "commentParent": parentID,
                    "likes": [String](),
                    "dislikes": [String](),
                    "waveform": waveform,
                    "comments": [String](),
                    "profilePic": profilePic
                ] as [String: Any])
            var mutableComments = comments;
            
            mutableComments.append(audioID)
            _ = try await databases.updateDocument(
                databaseId: Config.APPWRITE_DATABASE_ID,
                collectionId: Config.APPWRITE_AUDIO_COLLECTION_ID,
                documentId: parentID,
                data: [
                    "comments": mutableComments
                ]
            )
            addAudioToStorage(audioId: audioID)
        }
        catch {
            print("Fresh-Peach createCommentAudioFile",error.localizedDescription)
        }
    }
    
    func createAudioFile(audioId: String,name: String ,title:String,userId: String ,waveform: [Float], profilePic: String) async {
        do {
            _ = try await databases.createDocument(
                databaseId:  Config.APPWRITE_DATABASE_ID,
                collectionId: Config.APPWRITE_AUDIO_COLLECTION_ID,
                documentId: audioId,
                data: [
                    "id" : audioId,
                    "name" : name,
                    "title" : title,
                    "userId" : userId,
                    "isComment" : false,
                    "commentParent": "",
                    "likes": [String](),
                    "dislikes": [String](),
                    "waveform" :waveform,
                    "comments": [String](),
                    "profilePic": profilePic
                ] as [String : Any]
            )
            addAudioToStorage(audioId: audioId);
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteRecording( audioId : String ){
        
    }
    
    func getAudioFromStorage (audioID : String ) async -> ByteBuffer?  {
        do {
            let file = try await storage.getFileView(bucketId: Config.APPWRITE_BUCKET_ID, fileId: audioID)
            return file;
        }
        catch {
            print("Fresh-Peach getAudioFromStorage", error.localizedDescription)
        }
        return nil;
    }
    
    func addAudioToStorage(audioId : String) {
        Task {
            do {
                let audioData = try Data(contentsOf: AudioManager.fetchAllRecording())
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
    
    // MARK: Move this function elsewhere ( utils )
    func jsonDecoder(from  : Data){
        do {
            let jsonDecoder = JSONDecoder()
            let jsonDetails =  try jsonDecoder.decode(HootsStructure.self,from: from)
            print(jsonDetails)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getCommentsFor(id: String ) async -> [HootsStructure] {
        var audioFilesData = [HootsStructure]();
        do {
            let audioFiles = try await databases.listDocuments(
                databaseId: Config.APPWRITE_DATABASE_ID,
                collectionId: Config.APPWRITE_AUDIO_COLLECTION_ID,
                queries: [
                    Query.equal("commentParent", value: id)
                ]
            )
            audioFiles.documents.map { document in
                do{
                    var convertedObject: [String:Any] = [:]
                    for (key,value) in document.data {
                        convertedObject[key] = value.value;
                    }
                    let jsonData = try JSONSerialization.data(withJSONObject: convertedObject, options: [])
                    let decoder = JSONDecoder();
                    decoder.dateDecodingStrategy = .iso8601
                    let data = try decoder.decode(HootsStructure.self, from: jsonData)
                    audioFilesData.append(data)
                }
                catch{
                    print("Fresh-Peach getCommentFor #1",error.localizedDescription)
                }
            }
        }
        catch{
            print("Fresh-Peach getCommentsFor #2",error.localizedDescription)
        }
        return audioFilesData;
    }
    
    func getRecentHoots () async -> [HootsStructure]  {
        // Need to add filter to add using
        var audioFilesData = [HootsStructure]();
        do {
            let audioFiles = try await databases.listDocuments(
                databaseId:  Config.APPWRITE_DATABASE_ID,
                collectionId: Config.APPWRITE_AUDIO_COLLECTION_ID,
                queries: [
                    Query.equal("isComment", value: false)
                ]
            );
            audioFiles.documents.map { document in
                do{
                    var convertedObject: [String: Any] = [:]
                    for (key, value) in document.data {
                        convertedObject[key] = value.value
                    }
                    let jsonData = try JSONSerialization.data(withJSONObject: convertedObject,options: [])
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let data = try decoder.decode(HootsStructure.self, from: jsonData);
                    audioFilesData.append(data);
                }catch{
                    print("Fresh-Peach getRecentHoots #1",error.localizedDescription)
                }
            }
        } catch {
            print("Fresh-Peach getRecentHoots #2",error.localizedDescription)
        }
        return audioFilesData;
    }
    
    func addReactionToPost (parentID: String, likes: [String], dislikes: [String]) async {
        do {
            _ = try await databases.updateDocument(
                databaseId: Config.APPWRITE_DATABASE_ID,
                collectionId: Config.APPWRITE_AUDIO_COLLECTION_ID,
                documentId: parentID,
                data: [
                    "likes" : likes,
                    "dislikes":dislikes
                ]
            )
        }
        catch {
            print("Fresh-Peach addReactionToPost #1",error.localizedDescription)
        }
    }
    
    func getLikedHoots() -> [HootsStructure]{
        // TODO: Add tab to the homescreen then add this.
        return []
    }
}
