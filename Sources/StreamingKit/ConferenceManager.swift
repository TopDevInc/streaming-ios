//
//  File.swift
//  StreamingKit
//
//  Created by Alejandro on 5/21/25.
//

import LiveKit
import Observation
import AVFoundation


@Observable public class ConferenceManager {
    @MainActor public static let shared = ConferenceManager()
    private init() {}

    private var room = Room()
    private var localParticipant: LocalParticipant? { room.localParticipant }
    public private(set) var providerVideoTrack: VideoTrack?
    public private(set) var clientVideoTrack: VideoTrack?
    private(set) var myRole: Role = .client
    
    public enum Role {
        case provider
        case client
    }

    public func register(role: Role) {
        //this must be run on client App to state who is joining the Conference -Alejandro
        myRole = role
    }
    
    
    public func connect(to url: String, token: String, muted: Bool, videoEnabled: Bool, cameraPosition: AVCaptureDevice.Position) async throws {
        let options = RoomOptions(
            defaultCameraCaptureOptions: CameraCaptureOptions(position: cameraPosition),
            defaultAudioCaptureOptions: AudioCaptureOptions()
        )

        do {
            try await room.connect(url: url, token: token, roomOptions: options)
            try await configurePermissions(isMuted: muted, isCameraEnabled: videoEnabled)

            
            // Track assignment
            switch myRole {
            case .provider:
                if let track = room.remoteParticipants.first?.value.videoTracks.first?.track {
                    clientVideoTrack = track as? VideoTrack
                }
                if let track = room.localParticipant.videoTracks.first?.track {
                    providerVideoTrack = track as? VideoTrack
                }
            case .client:
                if let track = room.remoteParticipants.first?.value.videoTracks.first?.track {
                    providerVideoTrack = track as? VideoTrack
                }
                if let track = room.localParticipant.videoTracks.first?.track {
                    clientVideoTrack = track as? VideoTrack
                }
            }
        } catch {
            throw error
        }
    }
    
    
    public func switchCamera() async {
        guard let videoTrack = room.localParticipant.videoTracks.first?.track as? LocalVideoTrack,
              let capturer = videoTrack.capturer as? CameraCapturer else {
            return
        }
        
        do {
            try await capturer.switchCameraPosition()
        } catch {
            print("Failed to switch camera: \(error)")
        }
    }

    private func configurePermissions(isMuted: Bool, isCameraEnabled: Bool) async throws {
        try await room.localParticipant.setMicrophone(enabled: !isMuted)
        try await room.localParticipant.setCamera(enabled: isCameraEnabled)
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
            
        case .client:
            clientVideoTrack = enabled ? (room.localParticipant.videoTracks.first?.track as? VideoTrack) : nil
        }
        
        
    }
    
    
    public func disconnect() async throws {
        await room.disconnect()
        providerVideoTrack = nil
        clientVideoTrack = nil
    }
}
