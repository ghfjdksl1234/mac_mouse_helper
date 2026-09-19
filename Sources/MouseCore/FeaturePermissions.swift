public enum MouseFeature: Hashable {
    case locate, crossing
}

public enum MousePermission: Equatable {
    case inputMonitoring, accessibility
}

public struct MousePermissions {
    public var inputMonitoring: Bool
    public var accessibility: Bool

    public init(inputMonitoring: Bool, accessibility: Bool) {
        self.inputMonitoring = inputMonitoring
        self.accessibility = accessibility
    }

    public func missing(for feature: MouseFeature) -> MousePermission? {
        if !inputMonitoring { return .inputMonitoring }
        if feature == .crossing && !accessibility { return .accessibility }
        return nil
    }

    fileprivate func allows(_ permission: MousePermission) -> Bool {
        permission == .inputMonitoring ? inputMonitoring : accessibility
    }
}

/// Only a deliberate feature enable starts a setup flow. Polling permissions
/// can advance that flow, but must never repeatedly reopen System Settings.
public struct FeaturePermissionFlow {
    private var features: Set<MouseFeature> = []
    private var presented: MousePermission?
    public var isWaiting: Bool { presented != nil }
    public init() {}

    public mutating func begin(_ feature: MouseFeature, permissions: MousePermissions) -> MousePermission? {
        features.insert(feature)
        return advance(permissions)
    }

    public mutating func cancel(_ feature: MouseFeature) {
        features.remove(feature)
        if features.isEmpty { presented = nil }
    }

    public mutating func permissionsChanged(_ permissions: MousePermissions) -> MousePermission? {
        guard let presented, permissions.allows(presented) else { return nil }
        return advance(permissions)
    }

    private mutating func advance(_ permissions: MousePermissions) -> MousePermission? {
        features = features.filter { permissions.missing(for: $0) != nil }
        let missing = features.compactMap { permissions.missing(for: $0) }
        presented = missing.contains(.inputMonitoring) ? .inputMonitoring : missing.first
        return presented
    }
}
