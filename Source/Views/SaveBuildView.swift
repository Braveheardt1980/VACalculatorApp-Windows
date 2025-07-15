import SwiftCrossUI
import Foundation

// MARK: - Save Build View

struct SaveBuildView: View {
    let configuration: BuildConfiguration
    let results: [APSetDisplayResult]
    @Environment(\.dismiss) private var dismiss
    
    @State private var buildName = ""
    @State private var buildNotes = ""
    @State private var showingSaveConfirmation = false
    @State private var showingExportOptions = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Build Name Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Build Name")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    TextField("Enter a name for this build", text: $buildName)
                        .textFieldStyle(.roundedBorder)
                }
                
                // Build Notes
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes (Optional)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
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
                        ConfigurationRow(label: "Equipment", value: configuration.equipmentType)
                        ConfigurationRow(label: "Speed", value: "\(Int(configuration.rpm)) RPM")
                        ConfigurationRow(label: "Sensor", value: "\(configuration.sensorType) - \(configuration.mountingMethod)")
                        ConfigurationRow(label: "Results", value: "\(results.count) AP Sets")
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(8)
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: saveBuild) {
                        HStack {
                            Text("💾")
                            Text("Save Build")
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(buildName.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                        .foregroundColor(buildName.isEmpty ? .secondary : .white)
                        .cornerRadius(8)
                    }
                    .disabled(buildName.isEmpty)
                    
                    Button(action: { showingExportOptions = true }) {
                        HStack {
                            Text("📤")
                            Text("Export Report")
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
            }
            .padding()
            .navigationTitle("Save Build")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Build Saved", isPresented: $showingSaveConfirmation) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your build '\(buildName)' has been saved successfully.")
        }
        .sheet(isPresented: $showingExportOptions) {
            ExportReportView(
                configuration: configuration,
                results: results,
                buildName: buildName
            )
        }
    }
    
    // MARK: - Save Build
    
    private func saveBuild() {
        let savedBuild = SavedBuild(
            name: buildName,
            configuration: configuration,
            results: results,
            notes: buildNotes.isEmpty ? nil : buildNotes
        )
        
        BuildManager.shared.saveBuild(savedBuild)
        showingSaveConfirmation = true
    }
}

// MARK: - Configuration Row

struct ConfigurationRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Export Report View

struct ExportReportView: View {
    let configuration: BuildConfiguration
    let results: [APSetDisplayResult]
    let buildName: String
    
    @Environment(\.dismiss) private var dismiss
    @State private var exportPath = ""
    @State private var showingExportSuccess = false
    @State private var exportError: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Export Report")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Choose export format and location")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                VStack(spacing: 16) {
                    // HTML Export
                    ExportOptionCard(
                        title: "HTML Report",
                        description: "Interactive web report with full styling",
                        icon: "🌐",
                        action: exportAsHTML
                    )
                    
                    // Text Export
                    ExportOptionCard(
                        title: "Text Report",
                        description: "Plain text format for easy sharing",
                        icon: "📄",
                        action: exportAsText
                    )
                    
                    // JSON Export
                    ExportOptionCard(
                        title: "JSON Data",
                        description: "Raw data for integration with other systems",
                        icon: "📊",
                        action: exportAsJSON
                    )
                }
                
                if !exportPath.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Export Location:")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text(exportPath)
                            .font(.caption)
                            .foregroundColor(.blue)
                            .lineLimit(2)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Export Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Export Complete", isPresented: $showingExportSuccess) {
            Button("OK") { }
        } message: {
            Text("Report exported successfully to:\n\(exportPath)")
        }
        .alert("Export Error", isPresented: .constant(exportError != nil)) {
            Button("OK") {
                exportError = nil
            }
        } message: {
            Text(exportError ?? "Unknown error occurred")
        }
    }
    
    // MARK: - Export Methods
    
    private func exportAsHTML() {
        let html = VisualExportService.shared.generateHTMLReport(
            results: results,
            configuration: configuration,
            buildName: buildName
        )
        
        let fileName = "VAReport_\(buildName.replacingOccurrences(of: " ", with: "_"))_\(Date().fileNameString).html"
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsPath.appendingPathComponent(fileName)
        
        do {
            try VisualExportService.shared.saveHTMLReport(html: html, to: filePath.path)
            exportPath = filePath.path
            showingExportSuccess = true
        } catch {
            exportError = "Failed to export HTML: \(error.localizedDescription)"
        }
    }
    
    private func exportAsText() {
        let savedBuild = SavedBuild(
            name: buildName,
            configuration: configuration,
            results: results
        )
        
        let text = BuildManager.shared.exportBuildAsText(savedBuild)
        
        let fileName = "VAReport_\(buildName.replacingOccurrences(of: " ", with: "_"))_\(Date().fileNameString).txt"
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsPath.appendingPathComponent(fileName)
        
        do {
            try text.write(to: filePath, atomically: true, encoding: .utf8)
            exportPath = filePath.path
            showingExportSuccess = true
        } catch {
            exportError = "Failed to export text: \(error.localizedDescription)"
        }
    }
    
    private func exportAsJSON() {
        let savedBuild = SavedBuild(
            name: buildName,
            configuration: configuration,
            results: results
        )
        
        guard let jsonData = BuildManager.shared.exportBuildAsJSON(savedBuild) else {
            exportError = "Failed to encode JSON data"
            return
        }
        
        let fileName = "VAData_\(buildName.replacingOccurrences(of: " ", with: "_"))_\(Date().fileNameString).json"
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsPath.appendingPathComponent(fileName)
        
        do {
            try jsonData.write(to: filePath)
            exportPath = filePath.path
            showingExportSuccess = true
        } catch {
            exportError = "Failed to export JSON: \(error.localizedDescription)"
        }
    }
}

// MARK: - Export Option Card

struct ExportOptionCard: View {
    let title: String
    let description: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Text(icon)
                    .font(.title)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("→")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}