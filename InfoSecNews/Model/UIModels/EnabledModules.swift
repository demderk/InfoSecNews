//
//  EnabledModules.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 15.04.2025.
//

struct EnabledModules: OptionSet, Hashable, Identifiable {
    let rawValue: Int
    var id: Int { rawValue }
    var isEmpty: Bool { self.rawValue == 0 }
    
    static let securityMedia = EnabledModules(rawValue: 1 << 1)
    static let securityLab = EnabledModules(rawValue: 1 << 2)
    static let antiMalware = EnabledModules(rawValue: 1 << 3)
    
    static let all: EnabledModules = [.securityMedia, .securityLab, .antiMalware]
    static let allCases: [EnabledModules] = [.securityMedia, .securityLab, .antiMalware]
    
    var UIName: String {
        switch self {
        case .securityMedia: "SecurityMedia"
        case .securityLab: "SecurityLab"
        case .antiMalware: "Anti-Malware"
        default: "undefined"
        }
    }
}
