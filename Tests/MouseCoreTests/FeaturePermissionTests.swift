import MouseCore

extension MouseCoreTests {
    func testFeaturePermissionRequirements() {
        let none = MousePermissions(inputMonitoring: false, accessibility: false)
        let input = MousePermissions(inputMonitoring: true, accessibility: false)
        let accessOnly = MousePermissions(inputMonitoring: false, accessibility: true)
        let both = MousePermissions(inputMonitoring: true, accessibility: true)
        XCTAssertEqual(none.missing(for: .locate), .inputMonitoring)
        XCTAssertEqual(none.missing(for: .crossing), .inputMonitoring)
        XCTAssertNil(input.missing(for: .locate))
        XCTAssertEqual(input.missing(for: .crossing), .accessibility)
        XCTAssertEqual(accessOnly.missing(for: .locate), .inputMonitoring)
        XCTAssertNil(both.missing(for: .crossing))
    }

    func testPermissionFlowAdvancesOnlyAfterGrant() {
        var flow = FeaturePermissionFlow()
        let none = MousePermissions(inputMonitoring: false, accessibility: false)
        let input = MousePermissions(inputMonitoring: true, accessibility: false)
        let both = MousePermissions(inputMonitoring: true, accessibility: true)
        XCTAssertNil(flow.permissionsChanged(none)) // Launch never prompts.
        XCTAssertEqual(flow.begin(.crossing, permissions: none), .inputMonitoring)
        XCTAssertTrue(flow.isWaiting)
        XCTAssertNil(flow.permissionsChanged(none)) // Denial/polling never loops.
        XCTAssertEqual(flow.permissionsChanged(input), .accessibility)
        XCTAssertNil(flow.permissionsChanged(input))
        XCTAssertNil(flow.permissionsChanged(both))
        XCTAssertFalse(flow.isWaiting)
        XCTAssertNil(flow.permissionsChanged(none)) // Revocation doesn't prompt.
    }

    func testPermissionRetryCancellationAndSharedSetup() {
        var flow = FeaturePermissionFlow()
        let none = MousePermissions(inputMonitoring: false, accessibility: false)
        let input = MousePermissions(inputMonitoring: true, accessibility: false)
        let both = MousePermissions(inputMonitoring: true, accessibility: true)
        XCTAssertEqual(flow.begin(.crossing, permissions: none), .inputMonitoring)
        XCTAssertEqual(flow.begin(.crossing, permissions: none), .inputMonitoring) // Explicit retry.
        flow.cancel(.crossing)
        XCTAssertFalse(flow.isWaiting)
        XCTAssertNil(flow.permissionsChanged(input))
        XCTAssertEqual(flow.begin(.crossing, permissions: none), .inputMonitoring)
        XCTAssertEqual(flow.begin(.locate, permissions: none), .inputMonitoring)
        flow.cancel(.locate)
        XCTAssertEqual(flow.permissionsChanged(input), .accessibility)
        flow.cancel(.crossing)
        XCTAssertNil(flow.permissionsChanged(both))
        XCTAssertNil(flow.begin(.locate, permissions: input))
        XCTAssertFalse(flow.isWaiting)
    }
}
