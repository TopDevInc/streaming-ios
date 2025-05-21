//
//  StreamManager.swift
//  StreamingKit
//
//  Created by Alejandro on 5/20/25.
//

import LiveKit
import Observation

@Observable public class StreamManager {
    private var room: Room?
    private var localParticipant: LocalParticipant? { room?.localParticipant }

    enum StreamMode {
        case oneToOne
        case oneToMany
    }

    func connect(to url: String, token: String, mode: StreamMode) async throws {
        let config = RoomOptions(
            defaultCameraCaptureOptions: CameraCaptureOptions(position: .front),
            defaultAudioCaptureOptions: AudioCaptureOptions()
        )
        room = try await LiveKit.connect(url: url, token: token, roomOptions: config)
        
        configurePermissions(for: mode)
    }

    private func configurePermissions(for mode: StreamMode) {
        switch mode {
        case .oneToOne:
            room?.localParticipant?.setMicrophone(enabled: true)
            room?.localParticipant?.setCamera(enabled: true)

        case .oneToMany:
            room?.localParticipant?.setMicrophone(enabled: true)
            room?.localParticipant?.setCamera(enabled: true)

            // Listen for remote joins and disable their publishing
            room?.on(.participantConnected) { participant in
                participant.setMicrophone(enabled: false)
                participant.setCamera(enabled: false)
            }
        }
    }

    func disconnect() {
        try? room?.disconnect()
    }
}
