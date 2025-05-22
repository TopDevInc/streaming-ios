//
//  File.swift
//  StreamingKit
//
//  Created by Alejandro on 5/21/25.
//

import LiveKit
import Observation


@Observable public class ConferenceManager {
    @MainActor public static let shared = ConferenceManager()
    private init() {}

    private var room = Room()
    private var localParticipant: LocalParticipant? { room.localParticipant }
    public private(set) var providerVideoTrack: VideoTrack?
    public private(set) var observerVideoTrack: VideoTrack?
    private(set) var myRole: Role = .observer

    public enum Role {
        case provider
        case observer
    }

    public func register(role: Role) {
        //this must be run on App to state who is joining the Conference -Alejandro
        myRole = role
    }
    
    public func connect(to url: String, token: String) async throws {
        
        let options = RoomOptions(
            defaultCameraCaptureOptions: CameraCaptureOptions(position: .front),
            defaultAudioCaptureOptions: AudioCaptureOptions()
        )

        do {
            try await room.connect(url: url, token: token, roomOptions: options)
            try await configurePermissions()

            switch myRole {
                
            case .provider:
                if let track = room.remoteParticipants.first?.value.videoTracks.first?.track {
                    observerVideoTrack = track as? VideoTrack
                }
                if let track = room.localParticipant.videoTracks.first?.track {
                    providerVideoTrack = track as? VideoTrack
                }
            case .observer:
                if let track = room.remoteParticipants.first?.value.videoTracks.first?.track {
                    providerVideoTrack = track as? VideoTrack
                }
                if let track = room.localParticipant.videoTracks.first?.track {
                    observerVideoTrack = track as? VideoTrack
                }
            }
            

        } catch {
            throw error
        }
    }

    private func configurePermissions() async throws {
        try await room.localParticipant.setMicrophone(enabled: true)
        try await room.localParticipant.setCamera(enabled: (myRole == .provider))
    }

    
    @MainActor
    public func setMicrophone(enabled: Bool) async throws {
        try await room.localParticipant.setMicrophone(enabled: enabled)
    }

    @MainActor
    public func setCamera(enabled: Bool) async throws {
        try await room.localParticipant.setCamera(enabled: enabled)
        switch myRole {
        case .provider:
            providerVideoTrack = enabled ? (room.localParticipant.videoTracks.first?.track as? VideoTrack) : nil
            
        case .observer:
            observerVideoTrack = enabled ? (room.localParticipant.videoTracks.first?.track as? VideoTrack) : nil
        }
        
        
    }
    
    
    public func disconnect() async throws {
        await room.disconnect()
        providerVideoTrack = nil
        observerVideoTrack = nil
    }
}
