//
//  File.swift
//  StreamingKit
//
//  Created by Alejandro on 7/2/25.
//

import Foundation
import AVFoundation

public enum CameraPosition: String, CaseIterable {
    case front = "FRONT"
    case back = "BACK"
    
    
    var devicePosition: AVCaptureDevice.Position {
        switch self {
        case .front:
            return .front
        case .back:
            return .back
        }
    }
    
    var displayName: String {
        switch self {
        case .front:
            return "Front"
        case .back:
            return "Back"
        }
    }
    
}
