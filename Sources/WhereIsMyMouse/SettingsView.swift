import SwiftUI
import ServiceManagement

private enum Palette {
    static let ink = Color(red: 0.10, green: 0.20, blue: 0.18)
    static let green = Color(red: 0.12, green: 0.44, blue: 0.34)
    static let muted = Color(red: 0.43, green: 0.49, blue: 0.46)
    static let background = Color(red: 0.97, green: 0.975, blue: 0.96)
    static let border = Color(red: 0.87, green: 0.90, blue: 0.87)
}

struct SettingsView: View {
    @ObservedObject var model: AppModel
    @ObservedObject var settings: Settings
    @ObservedObject var displays: DisplayManager

    init(model: AppModel) { self.model = model; settings = model.settings; displays = model.displays }

    private var locateBinding: Binding<Bool> {
        Binding(get: { settings.locateEnabled }, set: model.setLocateEnabled)
    }
    private var crossingBinding: Binding<Bool> {
        Binding(get: { settings.crossingEnabled }, set: model.setCrossingEnabled)
    }

    var body: some View {
        HStack(spacing: 0) {
            sidebar
            Rectangle().fill(Palette.border).frame(width: 1)
            ScrollView {
                VStack(alignment: .leading, spacing: 23) {
                    switch model.selectedPage {
                    case .overview: overview
                    case .locate: locate
                    case .crossing: crossing
                    case .alignment: alignment
                    case .general: general
                    }
                    if let notice = model.notice {
                        HStack(alignment: .top) {
                            Image(systemName: "info.circle")
                            Text(notice).font(.system(size: 12))
                            Spacer()
                            Button { model.notice = nil } label: { Image(systemName: "xmark") }.buttonStyle(.plain)
                        }.padding(14).background(Color.orange.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
                    }
                }.padding(32).frame(maxWidth: .infinity, alignment: .leading)
            }.background(Palette.background)
        }
        .foregroundStyle(Palette.ink)
        .tint(Palette.green)
        .font(.system(size: 13))
        .frame(minWidth: 900, minHeight: 680)
        .preferredColorScheme(.light)
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12).fill(Palette.green).frame(width: 40, height: 40)
                    Image(systemName: "cursorarrow.rays").font(.system(size: 24)).foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Where is").font(.system(size: 15, weight: .semibold))
                    Text("my mouse?").font(.system(size: 15, weight: .semibold))
                }
            }.padding(.bottom, 38)
            Text("WORKSPACE TOOLS").font(.system(size: 9, weight: .semibold)).tracking(1.5)
                .foregroundStyle(Palette.muted).padding(.horizontal, 10).padding(.bottom, 14)
            ForEach(SettingsPage.allCases) { page in
                Button { model.selectedPage = page } label: {
                    HStack(spacing: 11) {
                        Image(systemName: page.symbol).font(.system(size: 15)).frame(width: 19)
                        Text(page.rawValue).font(.system(size: 12, weight: model.selectedPage == page ? .semibold : .regular))
                        Spacer(minLength: 0)
                    }.padding(.horizontal, 12).padding(.vertical, 12)
                        .foregroundStyle(model.selectedPage == page ? Palette.green : Palette.muted)
                        .background(model.selectedPage == page ? Palette.green.opacity(0.09) : .clear, in: RoundedRectangle(cornerRadius: 9))
                        .contentShape(Rectangle())
                }.buttonStyle(.plain).padding(.bottom, 4)
            }
            Spacer(minLength: 40)
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 7) {
                    Circle().fill(settings.paused ? Color.orange : model.monitoring ? Palette.green : Color.orange).frame(width: 6, height: 6)
                    Text(model.status).font(.system(size: 11, weight: .medium))
                }
                Button(settings.paused ? "Resume helpers" : "Pause helpers") { settings.paused.toggle() }
                    .font(.system(size: 11)).buttonStyle(.plain).foregroundStyle(Palette.muted)
            }.padding(12).frame(maxWidth: .infinity, alignment: .leading)
                .background(.white.opacity(0.65), in: RoundedRectangle(cornerRadius: 10))
            Text("A small utility. A smoother day.")
                .font(.system(size: 9)).foregroundStyle(Palette.muted).padding(.top, 18).padding(.horizontal, 4)
            Text("VERSION \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0")").font(.system(size: 8, weight: .medium)).tracking(1.2)
                .foregroundStyle(Palette.muted.opacity(0.7)).padding(.top, 6).padding(.horizontal, 4)
        }.padding(.horizontal, 17).padding(.top, 34).padding(.bottom, 22)
            .frame(width: 207).background(Color(red: 0.94, green: 0.955, blue: 0.93))
    }

    private var overview: some View {
        VStack(alignment: .leading, spacing: 23) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    eyebrow("GOOD TO HAVE YOU BACK")
                    Text("Find your flow.\nAnd your pointer.").font(.system(size: 31, weight: .semibold, design: .rounded)).tracking(-0.8)
                    Text("Little helpers for a bigger workspace.").foregroundStyle(Palette.muted)
                }
                Spacer()
                Label("\(displays.monitors.count) display\(displays.monitors.count == 1 ? "" : "s")", systemImage: "display.2")
                    .font(.system(size: 10, weight: .medium)).padding(.horizontal, 11).padding(.vertical, 7)
                    .background(.white, in: Capsule()).overlay(Capsule().stroke(Palette.border))
            }
            workspacePreview
            VStack(spacing: 12) {
                featureRow("Locate in a shake", detail: "A circle brings your eyes right to your pointer.", icon: "scope", enabled: locateBinding, page: .locate)
                featureRow("Keep moving", detail: "A gentle hand across mismatched display edges.", icon: "arrow.right.to.line", enabled: crossingBinding, page: .crossing)
                featureRow("Get things lined up", detail: "Guides that help your screens see eye to eye.", icon: "line.3.horizontal", enabled: $settings.guidesVisible, page: .alignment)
            }
            if !model.monitoring && !settings.paused && (settings.locateEnabled || settings.crossingEnabled) {
                Button { model.selectedPage = .general } label: {
                    HStack(spacing: 9) {
                        Image(systemName: "hand.raised")
                        Text("One quick setup to enable mouse helpers").font(.system(size: 11, weight: .medium))
                        Spacer()
                        Text("Set up").font(.system(size: 11, weight: .semibold))
                        Image(systemName: "arrow.right")
                    }.foregroundStyle(Palette.green).padding(14)
                        .background(Palette.green.opacity(0.06), in: RoundedRectangle(cornerRadius: 10))
                }.buttonStyle(.plain)
            }
        }
    }

    private var workspacePreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                eyebrow("YOUR WORKSPACE")
                Spacer()
                Text("A little more connected.").font(.system(size: 10)).foregroundStyle(Palette.muted)
            }
            MonitorDiagram(monitors: displays.monitors, showGuides: settings.guidesVisible, guideCount: settings.guideCount).frame(height: 117)
            HStack {
                HStack(spacing: 6) {
                    Circle().fill(Palette.green).frame(width: 5, height: 5)
                    Text(displays.monitors.count > 1 ? "Displays detected automatically" : "Connect another display to cross and align")
                        .font(.system(size: 10)).foregroundStyle(Palette.muted)
                }
                Spacer()
                Button("Try locator ↗") { model.locate() }.buttonStyle(.plain)
                    .font(.system(size: 11, weight: .semibold)).foregroundStyle(Palette.green)
                    .disabled(settings.paused)
            }
        }.padding(18).background(.white, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Palette.border))
    }

    private func featureRow(_ title: String, detail: String, icon: String, enabled: Binding<Bool>, page: SettingsPage) -> some View {
        HStack(spacing: 13) {
            Image(systemName: icon).font(.system(size: 21, weight: .light)).foregroundStyle(Palette.green)
                .frame(width: 40, height: 40).background(Palette.green.opacity(0.055), in: RoundedRectangle(cornerRadius: 10))
            Button { model.selectedPage = page } label: {
                VStack(alignment: .leading, spacing: 5) {
                    Text(title).font(.system(size: 13, weight: .semibold))
                    Text(detail).font(.system(size: 11)).foregroundStyle(Palette.muted)
                }.frame(maxWidth: .infinity, alignment: .leading).contentShape(Rectangle())
            }.buttonStyle(.plain)
            Toggle(title, isOn: enabled).labelsHidden().toggleStyle(.switch).controlSize(.small)
        }.padding(16).background(.white, in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Palette.border.opacity(0.8)))
    }

    private var locate: some View {
        VStack(alignment: .leading, spacing: 23) {
            heading("Locate pointer", "A shake. A circle. There it is.", subtitle: "Shake your mouse back and forth to find your place.")
            section {
                switchRow("Shake to locate", detail: "The original red–yellow–red ring contracts from the farthest corner of your displays.", value: locateBinding)
                if settings.locateEnabled && !model.locateReady {
                    setupLink("Waiting for Input Monitoring. The feature starts after you grant access.")
                }
                Divider()
                sliderRow("Shake sensitivity", value: $settings.shakeSensitivity, range: 0...1, low: "Deliberate", high: "Light shake")
            }
            ZStack {
                RoundedRectangle(cornerRadius: 14).fill(Palette.green.opacity(0.045))
                LocatorRingPreview()
                Image(systemName: "cursorarrow").font(.system(size: 25)).offset(x: 6, y: 11)
            }.frame(height: 205).accessibilityLabel("The original red–yellow–red locator ring around the pointer")
            HStack {
                Button("Try locator") { model.locate() }.buttonStyle(.borderedProminent).disabled(settings.paused)
                Spacer()
                shortcut("⌃ ⌥ ⌘ L")
            }
            note("The original bright colors and broad gradient band are preserved for visibility. The circle follows your pointer and shrinks over 1.5 seconds. With Reduce Motion enabled in macOS, a small ring fades in place.")
        }
    }

    private var crossing: some View {
        VStack(alignment: .leading, spacing: 23) {
            heading("Cross displays", "Keep your momentum.", subtitle: "No more getting caught on the way to another screen.")
            section {
                switchRow("Help at blocked edges", detail: "Keep pushing gently to cross to the neighboring display.", value: crossingBinding)
                if settings.crossingEnabled && !model.crossingReady {
                    setupLink("Waiting for permissions. Crossing starts after Input Monitoring and Accessibility are enabled.")
                }
                Divider()
                sliderRow("Edge resistance", value: $settings.edgeResistance, range: 0...1, low: "Quick crossing", high: "Deliberate push")
            }
            section {
                switchRow("Make the pointer bigger after crossing", detail: "A larger arrow follows your pointer, then settles back.", value: $settings.enlargeEnabled)
                Divider()
                sliderRow("Pointer size · \(String(format: "%.1f", settings.pointerScale))×", value: $settings.pointerScale, range: 1.5...4, low: "Subtle", high: "Easy to spot")
                Divider()
                sliderRow("Stay enlarged · \(String(format: "%.1f", settings.highlightDuration)) seconds", value: $settings.highlightDuration, range: 0.6...2.5, low: "Brief", high: "A little longer")
                Button("Preview larger pointer") { model.previewPointer() }.buttonStyle(.bordered).disabled(settings.paused)
            }
            note("Works on the left, right, top, and bottom edges of adjoining displays. Your relative position carries over. Dragging and regular crossings stay under your control.")
            if !model.accessibilityAllowed { setupLink("Enable Accessibility to allow assisted crossings.") }
            if displays.monitors.count < 2 { note("Connect a second display to use crossing assistance.") }
        }
    }

    private var alignment: some View {
        VStack(alignment: .leading, spacing: 23) {
            heading("Align monitors", "Everything, on the level.", subtitle: "Use horizontal guides to line up your screens on your desk.")
            section {
                switchRow("Show alignment guides", detail: "Match each colored, numbered line across your displays.", value: $settings.guidesVisible)
                Divider()
                HStack {
                    Text("Guide placement")
                    Spacer()
                    Picker("Guide placement", selection: $settings.guideMode) {
                        ForEach(GuideMode.allCases) { Text($0.rawValue).tag($0) }
                    }.labelsHidden().frame(width: 190)
                }
                HStack {
                    Text("Number of lines")
                    Spacer()
                    Picker("Number of lines", selection: $settings.guideCount) {
                        ForEach(GuideAppearance.counts, id: \.self) { Text("\($0)").tag($0) }
                    }.pickerStyle(.segmented).labelsHidden().frame(width: 225)
                }
                HStack(spacing: 6) {
                    ForEach(0..<settings.guideCount, id: \.self) { index in
                        Text("\(index + 1)").font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color(GuideAppearance.color(for: index)))
                            .frame(maxWidth: .infinity).padding(.vertical, 7)
                            .background(Palette.ink, in: RoundedRectangle(cornerRadius: 5))
                    }
                }.accessibilityLabel("Each numbered guide has its own matching color on every monitor")
                sliderRow("Line thickness · \(Int(settings.guideThickness)) pt", value: $settings.guideThickness, range: 2...10, low: "Thinner", high: "Thicker")
                if settings.guideMode == .physical {
                    sliderRow("Line spacing · \(Int(settings.guideSpacing)) mm", value: $settings.guideSpacing, range: 20...80, low: "Close together", high: "Spread out")
                }
                sliderRow("Vertical offset · \(Int(settings.guideOffset)) \(settings.guideMode == .physical ? "mm" : "pt")", value: $settings.guideOffset, range: -100...100, low: "Up", high: "Down")
                Divider()
                switchRow("Label displays and lines", detail: "Match the same numbered lines on each monitor.", value: $settings.guideLabels)
            }
            HStack {
                Button(settings.guidesVisible ? "Hide guides" : "Show guides") { model.toggleGuides() }.buttonStyle(.borderedProminent)
                Button("Reset offset") { settings.guideOffset = 0 }.buttonStyle(.bordered)
                Spacer()
                shortcut("⌃ ⌥ ⌘ A")
            }
            note(settings.guideMode == .physical
                 ? "Physical alignment spaces lines in millimeters using the sizes reported by your monitors. Move the monitors on your desk until matching lines meet. Center lines align display centers. Incorrect reported sizes can make spacing inaccurate."
                 : "Desktop coordinates draw continuous lines in the arrangement set in macOS. Open System Settings → Displays → Arrange to adjust that arrangement.")
            ForEach(displays.monitors) { monitor in
                HStack {
                    Label("\(monitor.number). \(monitor.name)", systemImage: "display")
                    Spacer()
                    Text(monitor.hasPhysicalSize ? "\(Int(monitor.physicalHeight)) mm tall" : "Size unavailable · spacing estimated")
                        .foregroundStyle(Palette.muted)
                }.font(.system(size: 11))
            }
        }
    }

    private var general: some View {
        VStack(alignment: .leading, spacing: 23) {
            heading("General", "Make yourself at home.", subtitle: "A little setup, then quietly out of your way.")
            section {
                eyebrow("PERMISSIONS")
                permissionRow("Input Monitoring", detail: "Recognizes shaking and continued movement at a blocked edge.", granted: model.inputAllowed, action: model.requestInput)
                Divider()
                permissionRow("Accessibility", detail: "Allows the helper to move your pointer between displays.", granted: model.accessibilityAllowed, action: model.requestAccessibility)
                Text("Enable Where is My Mouse? in System Settings. Access is checked automatically; if macOS asks you to reopen the app, quit and open it again.")
                    .font(.system(size: 11)).foregroundStyle(Palette.muted).fixedSize(horizontal: false, vertical: true)
                HStack {
                    Button("Drag app to Input Monitoring…") { model.showPermissionHelp(.inputMonitoring) }
                    Button("Drag app to Accessibility…") { model.showPermissionHelp(.accessibility) }
                }.buttonStyle(.bordered).controlSize(.small)
                if (model.inputAllowed || model.accessibilityAllowed) && !model.monitoring && !settings.paused && (settings.locateEnabled || settings.crossingEnabled) {
                    Text("Mouse monitoring is inactive. Reopen the app if a feature is enabled and permissions are granted.")
                        .font(.system(size: 11)).foregroundStyle(.orange)
                }
            }
            section {
                eyebrow("STARTUP & MENU BAR")
                switchRow("Launch at login", detail: "Start automatically when you sign in after starting or restarting your Mac.",
                          value: Binding(get: { model.loginEnabled || model.loginNeedsApproval }, set: { model.setLogin($0) }))
                if model.loginNeedsApproval {
                    Text("Waiting for approval in macOS Login Items.").font(.system(size: 11)).foregroundStyle(Palette.muted)
                    Button("Approve in Login Items…") { SMAppService.openSystemSettingsLoginItems() }.buttonStyle(.bordered)
                }
                Divider()
                Label("Lives in your menu bar", systemImage: "menubar.arrow.up.rectangle").font(.system(size: 12, weight: .medium))
                Text("Use the pointer icon at the top of your screen to open Settings or quit. Closing this window keeps the helpers running. Login launches stay in the menu bar, with no Dock icon.")
                    .font(.system(size: 11)).foregroundStyle(Palette.muted).fixedSize(horizontal: false, vertical: true)
            }
            section {
                eyebrow("KEYBOARD SHORTCUTS")
                HStack { Text("Locate pointer"); Spacer(); shortcut("⌃ ⌥ ⌘ L") }
                HStack { Text("Toggle alignment guides"); Spacer(); shortcut("⌃ ⌥ ⌘ A") }
            }
            note("Your mouse stays on your Mac. No accounts, analytics, network requests, or stored movement history. Locator previews and alignment guides work without permissions.")
        }
    }

    private func heading(_ eyebrowText: String, _ title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            eyebrow(eyebrowText.uppercased())
            Text(title).font(.system(size: 29, weight: .semibold, design: .rounded)).tracking(-0.6)
            Text(subtitle).foregroundStyle(Palette.muted)
        }.padding(.bottom, 3)
    }
    private func eyebrow(_ title: String) -> some View {
        Text(title).font(.system(size: 9, weight: .semibold)).tracking(1.5).foregroundStyle(Palette.muted)
    }
    private func section<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 20, content: content).padding(20)
            .frame(maxWidth: .infinity, alignment: .leading).background(.white, in: RoundedRectangle(cornerRadius: 13))
            .overlay(RoundedRectangle(cornerRadius: 13).stroke(Palette.border))
    }
    private func switchRow(_ title: String, detail: String, value: Binding<Bool>) -> some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title).fontWeight(.medium)
                Text(detail).font(.system(size: 11)).foregroundStyle(Palette.muted).fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            Toggle(title, isOn: value).labelsHidden().toggleStyle(.switch).controlSize(.small)
        }
    }
    private func sliderRow(_ title: String, value: Binding<Double>, range: ClosedRange<Double>, low: String, high: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.system(size: 12, weight: .medium))
            Slider(value: value, in: range).accessibilityLabel(title)
            HStack { Text(low); Spacer(); Text(high) }.font(.system(size: 10)).foregroundStyle(Palette.muted)
        }
    }
    private func permissionRow(_ title: String, detail: String, granted: Bool, action: @escaping () -> Void) -> some View {
        HStack(spacing: 18) {
            Image(systemName: granted ? "checkmark.circle.fill" : "lock.circle").font(.system(size: 23))
                .foregroundStyle(granted ? Palette.green : Palette.muted)
            VStack(alignment: .leading, spacing: 6) {
                Text(title).fontWeight(.medium)
                Text(detail).font(.system(size: 11)).foregroundStyle(Palette.muted).fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            if granted { Text("Enabled").font(.system(size: 11, weight: .medium)).foregroundStyle(Palette.green) }
            else { Button("Enable…", action: action).buttonStyle(.bordered) }
        }
    }
    private func shortcut(_ text: String) -> some View {
        Text(text).font(.system(size: 11, weight: .medium, design: .monospaced)).foregroundStyle(Palette.muted)
            .padding(.horizontal, 10).padding(.vertical, 6).background(.white, in: RoundedRectangle(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Palette.border))
    }
    private func note(_ text: String) -> some View {
        Text(text).font(.system(size: 11)).foregroundStyle(Palette.muted).lineSpacing(4).fixedSize(horizontal: false, vertical: true)
    }
    private func setupLink(_ text: String) -> some View {
        Button { model.selectedPage = .general } label: {
            Label(text, systemImage: "hand.raised").font(.system(size: 11)).foregroundStyle(Palette.green)
        }.buttonStyle(.plain)
    }
}

private struct MonitorDiagram: View {
    let monitors: [Monitor]
    let showGuides: Bool
    let guideCount: Int
    var body: some View {
        Canvas { context, size in
            guard let first = monitors.first else { return }
            let union = monitors.dropFirst().reduce(first.display.bounds) { $0.union($1.display.bounds) }
            let scale = min((size.width - 60) / union.width, (size.height - 22) / union.height)
            let offset = CGPoint(x: (size.width - union.width * scale) / 2, y: 4)
            var frames: [CGRect] = []
            for monitor in monitors {
                let b = monitor.display.bounds
                let frame = CGRect(x: offset.x + (b.minX - union.minX) * scale + 2,
                                   y: offset.y + (b.minY - union.minY) * scale + 2,
                                   width: b.width * scale - 4, height: b.height * scale - 4)
                frames.append(frame)
                let path = Path(roundedRect: frame, cornerRadius: 5)
                context.fill(path, with: .linearGradient(Gradient(colors: [Color(red: 0.88, green: 0.94, blue: 0.89), Color(red: 0.95, green: 0.97, blue: 0.93)]), startPoint: frame.origin, endPoint: CGPoint(x: frame.maxX, y: frame.maxY)))
                context.stroke(path, with: .color(Palette.green.opacity(0.4)), lineWidth: 1.5)
                context.draw(Text("\(monitor.number)").font(.system(size: 10, weight: .medium)).foregroundColor(Palette.green), at: CGPoint(x: frame.minX + 12, y: frame.minY + 13))
                context.draw(Text(monitor.name).font(.system(size: 8)).foregroundColor(Palette.muted), at: CGPoint(x: frame.midX, y: frame.maxY + 12))
                if showGuides {
                    for index in 0..<guideCount {
                        let fraction = CGFloat(index + 1) / CGFloat(guideCount + 1)
                        var line = Path(); let y = frame.minY + frame.height * fraction
                        line.move(to: CGPoint(x: frame.minX, y: y)); line.addLine(to: CGPoint(x: frame.maxX, y: y))
                        context.stroke(line, with: .color(.black.opacity(0.6)), lineWidth: 2.5)
                        context.stroke(line, with: .color(Color(GuideAppearance.color(for: index))), lineWidth: 1.5)
                    }
                }
            }
            if let frame = frames.last {
                let point = CGPoint(x: frame.midX + 10, y: frame.midY)
                context.withCGContext { cgContext in
                    LocatorAppearance.draw(in: cgContext, center: point, radius: 28)
                }
                context.draw(Image(systemName: "cursorarrow").resizable(), in: CGRect(x: point.x, y: point.y, width: 12, height: 17))
            }
        }.accessibilityLabel("Arrangement of \(monitors.count) connected displays")
    }
}

/// The settings preview uses the production renderer, so its colors and band
/// proportions cannot drift from the actual multi-display overlay.
private struct LocatorRingPreview: NSViewRepresentable {
    func makeNSView(context: Context) -> LocatorRingPreviewView { LocatorRingPreviewView() }
    func updateNSView(_ view: LocatorRingPreviewView, context: Context) { view.needsDisplay = true }
}

private final class LocatorRingPreviewView: NSView {
    override var isFlipped: Bool { true }
    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        LocatorAppearance.draw(in: context, center: CGPoint(x: bounds.midX, y: bounds.midY),
                               radius: min(bounds.width, bounds.height) / 2 - 16)
    }
}
