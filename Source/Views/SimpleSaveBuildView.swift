import SwiftCrossUI
import Foundation

// MARK: - Simplified Save Build View for SwiftCrossUI

struct SimpleSaveBuildView: View {
    let configuration: BuildConfiguration
    let results: [APSetDisplayResult]
    @State private var buildName = ""
    @State private var buildNotes = ""
    @State private var showingSuccessMessage = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Save Build")
                .font(.title2)
                .fontWeight(.bold)
            
            // Build Name Input
            VStack(alignment: .leading, spacing: 8) {
                Text("Build Name")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextField("Enter a name for this build", text: $buildName)
                    .textFieldStyle(.roundedBorder)
            }
            
            // Build Notes
            VStack(alignment: .leading, spacing: 8) {
                Text("Notes (Optional)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextEditor(text: $buildNotes)
                    .frame(minHeight: 100)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            
            // Configuration Summary
            VStack(alignment: .leading, spacing: 16) {
                Text("Configuration Summary")
                    .font(.headline)
                    .fontWeight(.bold)
                
                VStack(spacing: 12) {
                    SimpleConfigurationRow(label: "Equipment", value: configuration.equipmentType)
                    SimpleConfigurationRow(label: "Speed", value: "\(Int(configuration.rpm)) RPM")
                    SimpleConfigurationRow(label: "Sensor", value: "\(configuration.sensorType) - \(configuration.mountingMethod)")
                    SimpleConfigurationRow(label: "Results", value: "\(results.count) AP Sets")
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(8)
            }
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: 16) {
                Button(action: {
                    // Cancel - would normally dismiss
                    print("Cancel save build")
                }) {
                    Text("Cancel")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(8)
                }
                
                Button(action: saveBuild) {
                    Text("Save Build")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(buildName.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                        .foregroundColor(buildName.isEmpty ? Color.gray : .white)
                        .cornerRadius(8)
                }
                .disabled(buildName.isEmpty)
            }
        }
        .padding()
        .alert("Build Saved", isPresented: $showingSuccessMessage) {
            Button("OK") { }
        } message: {
            Text("Your build '\(buildName)' has been saved successfully.")
        }
    }
    
    private func saveBuild() {
        let savedBuild = SavedBuild(
            name: buildName,
            configuration: configuration,
            results: results,
            notes: buildNotes.isEmpty ? nil : buildNotes
        )
        
        BuildManager.shared.saveBuild(savedBuild)
        showingSuccessMessage = true
    }
}

// MARK: - Simple Configuration Row

struct SimpleConfigurationRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
}