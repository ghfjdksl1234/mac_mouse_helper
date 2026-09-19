import Carbon

final class HotKeys {
    var onLocate: (() -> Void)?
    var onGuides: (() -> Void)?
    private var references: [EventHotKeyRef] = []
    private var handler: EventHandlerRef?

    func register() -> Bool {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let status = InstallEventHandler(GetApplicationEventTarget(), { _, event, context in
            guard let event, let context else { return OSStatus(eventNotHandledErr) }
            let keys = Unmanaged<HotKeys>.fromOpaque(context).takeUnretainedValue()
            var id = EventHotKeyID()
            guard GetEventParameter(event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID),
                                    nil, MemoryLayout<EventHotKeyID>.size, nil, &id) == noErr else { return OSStatus(eventNotHandledErr) }
            if id.id == 1 { keys.onLocate?() }
            if id.id == 2 { keys.onGuides?() }
            return noErr
        }, 1, &eventType, Unmanaged.passUnretained(self).toOpaque(), &handler)
        guard status == noErr else { return false }
        var success = true
        for (id, code) in [(UInt32(1), UInt32(kVK_ANSI_L)), (UInt32(2), UInt32(kVK_ANSI_A))] {
            var ref: EventHotKeyRef?
            let result = RegisterEventHotKey(code, UInt32(cmdKey | optionKey | controlKey),
                                            EventHotKeyID(signature: 0x574D4D48, id: id),
                                            GetApplicationEventTarget(), 0, &ref)
            if result == noErr, let ref { references.append(ref) } else { success = false }
        }
        return success
    }
    deinit {
        references.forEach { UnregisterEventHotKey($0) }
        if let handler { RemoveEventHandler(handler) }
    }
}
