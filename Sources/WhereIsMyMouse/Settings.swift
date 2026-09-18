import AppKit
import Combine

enum GuideMode: String, CaseIterable, Identifiable {
    case physical = "Physical alignment"
    case desktop = "Desktop coordinates"
    var id: String { rawValue }
}

final class Settings: ObservableObject {
    private let defaults = UserDefaults.standard
    @Published var locateEnabled: Bool { didSet { save() } }
    @Published var crossingEnabled: Bool { didSet { save() } }
    @Published var enlargeEnabled: Bool { didSet { save() } }
    @Published var shakeSensitivity: Double { didSet { save() } }
    @Published var edgeResistance: Double { didSet { save() } }
    @Published var pointerScale: Double { didSet { save() } }
    @Published var highlightDuration: Double { didSet { save() } }
    @Published var guideCount: Int { didSet { save() } }
    @Published var guideThickness: Double { didSet { save() } }
    @Published var guideSpacing: Double { didSet { save() } }
    @Published var guideOffset: Double { didSet { save() } }
    @Published var guideMode: GuideMode { didSet { save() } }
    @Published var guideLabels: Bool { didSet { save() } }
    @Published var guidesVisible = false
    @Published var paused = false

    init() {
        defaults.register(defaults: ["locate": true, "crossing": true, "enlarge": true,
            "sensitivity": 0.5, "resistance": 0.5, "pointerScale": 2.8, "highlightDuration": 1.2,
            "guideCount": GuideAppearance.defaultCount, "guideSpacing": GuideAppearance.defaultSpacing,
            "guideThickness": GuideAppearance.defaultThickness, "guideOffset": 0.0,
            "guideMode": GuideMode.physical.rawValue, "guideLabels": true])
        // Adopt the requested denser guides once for existing installations.
        // Subsequent launches preserve the user's chosen count and spacing.
        if !defaults.bool(forKey: "colorGuidesIntroduced") {
            defaults.set(max(GuideAppearance.defaultCount, defaults.integer(forKey: "guideCount")), forKey: "guideCount")
            if defaults.double(forKey: "guideSpacing") == 45 {
                defaults.set(GuideAppearance.defaultSpacing, forKey: "guideSpacing")
            }
            defaults.set(true, forKey: "colorGuidesIntroduced")
        }
        locateEnabled = defaults.bool(forKey: "locate")
        crossingEnabled = defaults.bool(forKey: "crossing")
        enlargeEnabled = defaults.bool(forKey: "enlarge")
        shakeSensitivity = defaults.double(forKey: "sensitivity")
        edgeResistance = defaults.double(forKey: "resistance")
        pointerScale = defaults.double(forKey: "pointerScale")
        highlightDuration = defaults.double(forKey: "highlightDuration")
        let count = defaults.integer(forKey: "guideCount")
        guideCount = GuideAppearance.counts.contains(count) ? count : GuideAppearance.defaultCount
        guideThickness = min(10, max(2, defaults.double(forKey: "guideThickness")))
        guideSpacing = defaults.double(forKey: "guideSpacing")
        guideOffset = defaults.double(forKey: "guideOffset")
        guideMode = GuideMode(rawValue: defaults.string(forKey: "guideMode") ?? "") ?? .physical
        guideLabels = defaults.bool(forKey: "guideLabels")
    }

    private func save() {
        let values: [String: Any] = ["locate": locateEnabled, "crossing": crossingEnabled,
            "enlarge": enlargeEnabled, "sensitivity": shakeSensitivity, "resistance": edgeResistance,
            "pointerScale": pointerScale, "highlightDuration": highlightDuration, "guideCount": guideCount,
            "guideThickness": guideThickness,
            "guideSpacing": guideSpacing, "guideOffset": guideOffset, "guideMode": guideMode.rawValue,
            "guideLabels": guideLabels]
        for (key, value) in values { defaults.set(value, forKey: key) }
    }
}
