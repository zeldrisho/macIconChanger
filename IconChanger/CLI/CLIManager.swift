//
//  CLIManager.swift
//  IconChanger
//

import SwiftUI
import Foundation

@MainActor class CLIManager: ObservableObject {
    static let shared = CLIManager()
    
    @Published var isInstalled: Bool = false
    @Published var isInstalling: Bool = false
    @Published var installLocation: String = "\(NSHomeDirectory())/.local/bin/iconchanger"
    @Published var lastError: String? = nil
    
    private let bundledCLIName = "IconChangerCLI"
    
    init() {
        checkInstallation()
    }
    
    func checkInstallation() {
        isInstalled = FileManager.default.fileExists(atPath: installLocation)
    }
    
    /// Installs the bundled CLI at `installLocation` without requesting administrator privileges.
    /// Rejects an existing symbolic link and publishes installation progress or errors.
    func installCLI() {
        isInstalling = true
        lastError = nil

        let cliName = bundledCLIName
        let location = installLocation
        Task.detached {
            do {
                guard let bundlePath = Bundle.main.path(forResource: cliName, ofType: nil) else {
                    throw NSError(domain: "CLIManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "CLI executable not found in application bundle"])
                }

                let sourceURL = URL(fileURLWithPath: bundlePath)
                let destinationURL = URL(fileURLWithPath: location)
                    .standardizedFileURL
                let parentURL = destinationURL.deletingLastPathComponent()
                try FileManager.default.createDirectory(
                    at: parentURL,
                    withIntermediateDirectories: true
                )
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    let attributes = try FileManager.default.attributesOfItem(atPath: destinationURL.path)
                    guard attributes[.type] as? FileAttributeType != .typeSymbolicLink else {
                        throw NSError(domain: "CLIManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Refusing to replace a symbolic link at the CLI install location."])
                    }
                    try FileManager.default.removeItem(at: destinationURL)
                }
                try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
                try FileManager.default.setAttributes(
                    [.posixPermissions: 0o755],
                    ofItemAtPath: destinationURL.path
                )
                
                await MainActor.run {
                    self.isInstalling = false
                    self.checkInstallation()
                }
            } catch {
                await MainActor.run {
                    self.lastError = error.localizedDescription
                    self.isInstalling = false
                }
            }
        }
    }
    
    /// Removes the CLI at `installLocation` without requesting administrator privileges.
    /// Rejects symbolic links and publishes completion or errors.
    func uninstallCLI() {
        isInstalling = true
        lastError = nil

        let location = installLocation
        Task.detached {
            do {
                let destinationURL = URL(fileURLWithPath: location).standardizedFileURL
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    let attributes = try FileManager.default.attributesOfItem(atPath: destinationURL.path)
                    guard attributes[.type] as? FileAttributeType != .typeSymbolicLink else {
                        throw NSError(domain: "CLIManager", code: 3, userInfo: [NSLocalizedDescriptionKey: "Refusing to remove a symbolic link at the CLI install location."])
                    }
                    try FileManager.default.removeItem(at: destinationURL)
                }
                
                await MainActor.run {
                    self.isInstalling = false
                    self.checkInstallation()
                }
            } catch {
                await MainActor.run {
                    self.lastError = error.localizedDescription
                    self.isInstalling = false
                }
            }
        }
    }
}
