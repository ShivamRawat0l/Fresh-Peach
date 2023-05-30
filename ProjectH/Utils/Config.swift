//
//  Config.swift
//  ProjectH
//
//  Created by Shivam Rawat on 30/05/23.
//

import Foundation

class Config {
    static var APPWRITE_PROJECT_KEY = Bundle.main.infoDictionary?["APPWRITE_PROJECT_KEY"] as! String
    static var APPWRITE_DATABASE_ID = Bundle.main.infoDictionary?["APPWRITE_DATABASE_ID"] as! String
    static var APPWRITE_USER_COLLECTION_ID = Bundle.main.infoDictionary?["APPWRITE_USER_COLLECTION_ID"] as! String
    static var APPWRITE_AUDIO_COLLECTION_ID = Bundle.main.infoDictionary?["APPWRITE_AUDIO_COLLECTION_ID"] as! String
    static var APPWRITE_BUCKET_ID = Bundle.main.infoDictionary?["APPWRITE_BUCKET_ID"] as! String
}
