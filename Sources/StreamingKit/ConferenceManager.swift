//
//  File.swift
//  StreamingKit
//
//  Created by Alejandro on 5/21/25.
//

import LiveKit
import Observation

@Observable public class ConferenceManager {
    private var room: Room?
    private var localParticipant: LocalParticipant? { room?.localParticipant }
    
    
    
    
    func printJoke() {
        print("Life is short, use StreamingKit")
    }
    public func connect(to url: String, token: String) async throws {
          let options = RoomOptions(
              defaultCameraCaptureOptions: CameraCaptureOptions(position: .front),
              defaultAudioCaptureOptions: AudioCaptureOptions()
          )

          try await room?.connect(
              url: url,
              token: token,
              roomOptions: options
          )

          try await configurePermissions()
      }

    
    
//    func connect(to url: String, token: String) async throws {
//        let config = RoomOptions(
//            defaultCameraCaptureOptions: CameraCaptureOptions(position: .front),
//            defaultAudioCaptureOptions: AudioCaptureOptions()
//        )
//        
//        room = try await LiveKit.connect(url: url, token: token)
//        
//        configurePermissions()
//    }
    
    private func configurePermissions() async throws {
        
        do {
            try await room?.localParticipant.setMicrophone(enabled: true)
            try await room?.localParticipant.setCamera(enabled: true)
        } catch(let error) {
            throw error
        }
        
        
        
    }
    
    func disconnect() async {
        try? await room?.disconnect()
    }
    
    
    
}
