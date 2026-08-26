import ArgumentParser
import Foundation

struct ConfigureProduction: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Configures the project for a production build.")
    
    func run() async throws {
        try await CI.updateFossSecretsIfAvailable()
        try await CI.run(.name("xcodegen"))
    }
}
