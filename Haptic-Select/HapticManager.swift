//
//  HapticManager.swift
//  Haptic-Select
//
//  Created by Calum Bird on 2023-08-12.
//

import Foundation
import AppKit

class HapticManager {
    static func triggerFeedback() {
        let feedback = NSHapticFeedbackManager.defaultPerformer
        feedback.perform(.levelChange, performanceTime: .now)
    }
}
