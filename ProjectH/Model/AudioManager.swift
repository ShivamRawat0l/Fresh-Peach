//
//  AudioManager.swift
//  ProjectH
//
//  Created by Shivam Rawat on 28/05/23.
//

import Foundation
import AVFoundation
import DSWaveformImage
import DSWaveformImageViews

class AudioManager : NSObject, ObservableObject {
    // AudioRecording
    var audioRecorder : AVAudioRecorder!;
    var audioPlayer : AVAudioPlayer!;
    
    // Foriegn Class
    var appwrite = AppwriteSerivce.shared;
    
    static func fetchAllRecording() -> [URL] {
        do {
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let directoryContents = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
            _ = FileManager.contents(.default)
            return directoryContents;
        }
        catch{
            print("AudioManager.swift fetchAllRecording",error.localizedDescription)
        }
        return [];
    }
    
    func recordAudio() {
        let recordingSession  = AVAudioSession.sharedInstance();
        do {
            try recordingSession.setCategory(.playAndRecord,mode:.default)
            try recordingSession.setActive(true)
        }catch {
            print("AudioManager.swift recordAudio setCategory",error.localizedDescription)
        }
        
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0];
        let fileName = path.appendingPathComponent("hoot.m4a")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do{
            audioRecorder = try AVAudioRecorder(url: fileName, settings: settings);
            _ = audioRecorder.prepareToRecord()
            _ = audioRecorder.record()
            audioRecorder.isMeteringEnabled = true;
        }
        catch {
            print("AudioManager.swift recordAudio record",error.localizedDescription)
        }
    }
    
    func stopRecording() {
        appwrite.createAudioFile(audioId: "myname", title: "String", userId: "userID", isComment: false, parentId: nil)
        if let audioRecorderSafe = audioRecorder {
            audioRecorderSafe.stop()
        }
    }
    
    func getAmplitude () -> Float {
        audioRecorder.updateMeters() 
        let currentAmplitude = 1 - pow(10, audioRecorder.averagePower(forChannel: 0) / 20)
        return currentAmplitude;
    }
}
