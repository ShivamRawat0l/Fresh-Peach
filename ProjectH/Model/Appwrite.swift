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
    
    func createAudioFile(audioId: String, title:String,userId: String, isComment : Bool,parentId: String?,waveform: [Float]) async {
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
                        "dislikes": [String](),
                        "waveform" :waveform
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
                var file = try await storage.getFileView(bucketId: Config.APPWRITE_BUCKET_ID, fileId: audioID)
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
            var jsonDecoder = JSONDecoder()
            
            var jsonDetails =  try jsonDecoder.decode(HootsStructure.self,from: from)
            print(jsonDetails)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getRecentHoots () async -> [HootsStructure]  {
        // Need to add filter to add using
        var audioFilesData = [HootsStructure]();
        do {
            var audioFiles = try await databases.listDocuments(
                databaseId:  Config.APPWRITE_DATABASE_ID,
                collectionId: Config.APPWRITE_AUDIO_COLLECTION_ID
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
    
    func getLikedHoots() -> [HootsStructure]{
        return []
    }
}
