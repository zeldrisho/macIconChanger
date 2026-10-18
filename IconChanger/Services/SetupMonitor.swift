//
//  SetupMonitor.swift
//  IconChanger
//

import Combine
import Foundation

extension Notification.Name {
    static let setupHealthDidChange = Notification.Name("IconChanger.setupHealthDidChange")
}

@MainActor
final class SetupMonitor: ObservableObject {
    static let shared = SetupMonitor()

    @Published private(set) var health: SetupHealth = .checking
    private var checkGeneration = 0

    private init() {}

    /// Checks folder access and optional helper health, then publishes the latest result.
    /// Missing or unavailable helpers select manual mode; legacy grants require cleanup.
    /// The completion runs on the main queue only if this check is still current.
    func check(
        source: DiagnosticsSource = .system,
        completion: ((SetupHealth) -> Void)? = nil
    ) {
#if DEBUG
        if ProcessInfo.processInfo.environment["ICONCHANGER_PREVIEW_MANUAL_MODE"] == "1" {
            publish(.manualMode)
            completion?(.manualMode)
            return
        }
#endif
        checkGeneration += 1
        let generation = checkGeneration
        let diagnosticsContext = DiagnosticsContext(
            operation: .setup,
            source: source
        )
        let timer = DiagnosticsTimer()
        DiagnosticsLogger.shared.log(
            .operation,
            phase: "setup_health_check.start",
            context: diagnosticsContext,
            details: [
                "folder_permission_count": String(FolderPermission.shared.permissions.count)
            ]
        )
        publish(.checking)

        guard FolderPermission.shared.hasPermission else {
            DiagnosticsLogger.shared.log(
                .failure,
                phase: "setup_health_check.folder_permission_missing",
                context: diagnosticsContext,
                durationMilliseconds: timer.elapsedMilliseconds
            )
            finish(.needsFolderPermission, generation: generation, completion: completion)
            return
        }

        DispatchQueue.global(qos: .utility).async {
            let iconManager = IconManager.shared
            let setupStatus = iconManager.checkSetupStatus(
                diagnosticsContext: diagnosticsContext
            )
            let result: SetupHealth
            let details = [
                "setup_status": Self.setupStatusName(setupStatus)
            ]

            switch setupStatus {
            case .completed:
                // Let macOS enforce App Management consent when an operation actually needs it.
                result = .ready
            case .helperFilesMissing(_), .helperFilesOutdated, .sudoersPermissionMissing:
                // Browsing and user-writable app changes do not require the privileged helper.
                // Keep background automation paused until the optional helper is healthy.
                result = .manualMode
            case .legacySudoersPermissionPresent:
                // A stale user-writable NOPASSWD helper can grant persistent root access.
                // Require cleanup before proceeding, even for current-user operations.
                result = .needsLegacyPermissionCleanup
            case .unknownError(let message):
                result = .error(message)
            }

            DispatchQueue.main.async {
                DiagnosticsLogger.shared.log(
                    result.needsAttention ? .failure : .operation,
                    phase: "setup_health_check.completed",
                    context: diagnosticsContext,
                    durationMilliseconds: timer.elapsedMilliseconds,
                    details: details
                )
                self.finish(result, generation: generation, completion: completion)
            }
        }
    }

    private func finish(
        _ result: SetupHealth,
        generation: Int,
        completion: ((SetupHealth) -> Void)?
    ) {
        guard generation == checkGeneration else { return }
        publish(result)
        completion?(result)
    }

    private func publish(_ newHealth: SetupHealth) {
        guard health != newHealth else { return }
        health = newHealth
        NotificationCenter.default.post(name: .setupHealthDidChange, object: self)
    }

    nonisolated private static func setupStatusName(_ status: SetupStatus) -> String {
        switch status {
        case .completed:
            return "completed"
        case .helperFilesMissing:
            return "helper_files_missing"
        case .helperFilesOutdated:
            return "helper_files_outdated"
        case .sudoersPermissionMissing:
            return "sudoers_permission_missing"
        case .legacySudoersPermissionPresent:
            return "legacy_sudoers_permission_present"
        case .unknownError:
            return "unknown_error"
        }
    }

}
