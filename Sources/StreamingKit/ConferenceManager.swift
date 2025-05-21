//
//  File.swift
//  StreamingKit
//
//  Created by Alejandro on 5/21/25.
//

import LiveKit
import Observation

//@Observable public class ConferenceManager {
//    @MainActor public static let shared = ConferenceManager()
//    private init() {}
//    
//    private var room = Room()
//    private var localParticipant: LocalParticipant? { room.localParticipant }
//    
//    public enum Role {
//           case provider   // uses video and audio
//           case observer   // uses audio only
//       }
//
//    
//    
//    public func printJoke() {
//        
//        print("Life is short, use StreamingKit")
//    }
//    
//    
//    public func connect(to url: String, token: String, as role: Role) async throws {
//          let options = RoomOptions(
//              defaultCameraCaptureOptions: CameraCaptureOptions(position: .front), // no camera for Touristee
//              defaultAudioCaptureOptions: AudioCaptureOptions()
//          )
//        
//        do {
//            try await room.connect(url: url, token: token, roomOptions: options)
//            try await configurePermissions()
//        } catch (let error) {
//            throw error
//        }
//        
//      }
//
//    
//    
//    private func configurePermissions() async throws {
//        
//        do {
//            try await room.localParticipant.setMicrophone(enabled: true)
//            try await room.localParticipant.setCamera(enabled: true)
//        } catch(let error) {
//            throw error
//        }
//        
//        
//        
//    }
//    
//    public func disconnect() async throws {
//            await room.disconnect()
//    }
//    
//    
//    
//}



@Observable public class ConferenceManager {
    @MainActor public static let shared = ConferenceManager()
    private init() {}

    private var room = Room()
    private var localParticipant: LocalParticipant? { room.localParticipant }
    public private(set) var videoTrack: VideoTrack?

    public enum Role {
        case provider
        case observer
    }

    public func connect(to url: String, token: String, as role: Role) async throws {
        let options = RoomOptions(
            defaultCameraCaptureOptions: CameraCaptureOptions(position: .front),
            defaultAudioCaptureOptions: AudioCaptureOptions()
        )

        do {
            try await room.connect(url: url, token: token, roomOptions: options)
            try await configurePermissions()

            if let track = room.localParticipant.videoTracks.first?.track {
                videoTrack = track as? VideoTrack
            }

        } catch {
            throw error
        }
    }

    private func configurePermissions() async throws {
        do {
            try await room.localParticipant.setMicrophone(enabled: true)
            try await room.localParticipant.setCamera(enabled: true)
        } catch {
            throw error
        }
    }

    public func disconnect() async throws {
        await room.disconnect()
        videoTrack = nil
    }
}
