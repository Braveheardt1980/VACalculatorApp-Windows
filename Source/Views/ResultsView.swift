import SwiftCrossUI
import Foundation

// MARK: - AP Set Results View

struct APSetResultsView: View {
    let results: [APSetDisplayResult]
    @State private var showingExportOptions = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(Array(groupedResults.enumerated()), id: \.offset) { index, group in
                        VStack(spacing: 16) {
                            // Equipment Configuration Header
                            EquipmentConfigurationHeader(
                                bearingInfo: group.bearingInfo,
                                index: index
                            )
                            
                            // Normal AP Set Section
                            if let normalResult = group.normalResults.first {
                                NormalAPSetSection(result: normalResult)
                            }
                            
                            // PeakVue AP Set Section
                            if let peakVueResult = group.peakVueResults.first {
                                PeakVueAPSetSection(result: peakVueResult)
                            }
                        }
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(16)
                    }
                }
                .padding()
            }
            .navigationTitle("AP Set Results")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Export") {
                        showingExportOptions = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingExportOptions) {
            ExportOptionsView(results: results)
        }
    }
    
    private var groupedResults: [(bearingInfo: String, normalResults: [APSetDisplayResult], peakVueResults: [APSetDisplayResult])] {
        let grouped = Dictionary(grouping: results) { result in
            // Group by bearing model without "(PeakVue)" suffix
            result.bearingModel.replacingOccurrences(of: " (PeakVue)", with: "")
        }
        
        return grouped.map { key, value in
            let normal = value.filter { !$0.bearingModel.contains("PeakVue") }
            let peakVue = value.filter { $0.bearingModel.contains("PeakVue") }
            return (bearingInfo: key, normalResults: normal, peakVueResults: peakVue)
        }.sorted { $0.bearingInfo < $1.bearingInfo }
    }
}

// MARK: - Equipment Configuration Header

struct EquipmentConfigurationHeader: View {
    let bearingInfo: String
    let index: Int
    
    var body: some View {
        HStack(alignment: .center) {
            Text(bearingInfo)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text("⚙️")
                .font(.title2)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Normal AP Set Section

struct NormalAPSetSection: View {
    let result: APSetDisplayResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack {
                Text("Normal AP Set")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                
                Spacer()
                
                Text(result.isValid ? "✅" : "⚠️")
                    .font(.title2)
            }
            
            // Validation Status
            if !result.isValid && !result.validationMessages.isEmpty {
                ValidationStatusView(messages: result.validationMessages)
            }
            
            // Main Parameters
            VStack(spacing: 12) {
                // Headers
                HStack {
                    Text("Parameter")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Value")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .foregroundColor(.secondary)
                
                Divider()
                
                // Parameter rows
                ParameterRow(title: "Fmax", value: "\(String(format: "%.0f", result.fmax)) orders")
                ParameterRow(title: "LOR", value: "\(result.lor)")
                ParameterRow(title: "Shaft Revolutions", value: String(format: "%.1f", result.shaftRevolutions))
                
                if let calculatedFmax = result.calculatedFmax {
                    ParameterRow(title: "Calculated Fmax", value: String(format: "%.1f", calculatedFmax), isCalculated: true)
                }
            }
            .padding()
            .background(Color.green.opacity(0.05))
            .cornerRadius(8)
            
            // Bearing Analysis
            if result.scaledBPFI > 0 || result.scaledBPFO > 0 {
                BearingAnalysisView(result: result)
            }
            
            // Trend Recommendations
            if !result.trendRecommendations.isEmpty {
                let normalTrends = result.trendRecommendations.filter { $0.analysisType == .normal }
                if !normalTrends.isEmpty {
                    TrendRecommendationsView(
                        title: "Recommended Trends",
                        trends: normalTrends,
                        color: .green
                    )
                }
            }
        }
        .padding()
        .background(Color.green.opacity(0.02))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - PeakVue AP Set Section

struct PeakVueAPSetSection: View {
    let result: APSetDisplayResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack {
                Text("PeakVue AP Set")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Text(result.isValid ? "✅" : "⚠️")
                    .font(.title2)
            }
            
            // Validation Status
            if !result.isValid && !result.validationMessages.isEmpty {
                ValidationStatusView(messages: result.validationMessages)
            }
            
            // Main Parameters
            VStack(spacing: 12) {
                // Headers
                HStack {
                    Text("Parameter")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Value")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .foregroundColor(.secondary)
                
                Divider()
                
                // Parameter rows
                ParameterRow(title: "Fmax", value: "\(String(format: "%.0f", result.fmax)) orders")
                ParameterRow(title: "LOR", value: "\(result.lor)")
                ParameterRow(title: "Shaft Revolutions", value: String(format: "%.1f", result.shaftRevolutions))
                
                if let hpFilter = result.peakVueHPFilter {
                    ParameterRow(title: "HP Filter", value: "\(String(format: "%.0f", hpFilter)) Hz")
                }
                
                if let calculatedFmax = result.peakVueCalculatedFmax {
                    ParameterRow(title: "Calculated Fmax", value: String(format: "%.1f", calculatedFmax), isCalculated: true)
                }
            }
            .padding()
            .background(Color.blue.opacity(0.05))
            .cornerRadius(8)
            
            // Trend Recommendations
            if !result.trendRecommendations.isEmpty {
                let peakVueTrends = result.trendRecommendations.filter { $0.analysisType == .peakVue }
                if !peakVueTrends.isEmpty {
                    TrendRecommendationsView(
                        title: "Recommended PeakVue Trends",
                        trends: peakVueTrends,
                        color: .blue
                    )
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.02))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Supporting Views

struct ValidationStatusView: View {
    let messages: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Validation Issues:")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.orange)
            
            ForEach(messages, id: \.self) { message in
                HStack(alignment: .top, spacing: 8) {
                    Text("⚠️")
                        .font(.caption)
                    
                    Text(message)
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
    }
}

struct ParameterRow: View {
    let title: String
    let value: String
    let isCalculated: Bool
    
    init(title: String, value: String, isCalculated: Bool = false) {
        self.title = title
        self.value = value
        self.isCalculated = isCalculated
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(isCalculated ? .secondary : .primary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isCalculated ? .secondary : .primary)
        }
    }
}

struct BearingAnalysisView: View {
    let result: APSetDisplayResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bearing Fault Frequencies")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                if result.scaledBPFI > 0 {
                    BearingFrequencyItem(
                        title: "BPFI",
                        orderValue: result.orderBPFI,
                        hzValue: result.scaledBPFI
                    )
                }
                
                if result.scaledBPFO > 0 {
                    BearingFrequencyItem(
                        title: "BPFO",
                        orderValue: result.orderBPFO,
                        hzValue: result.scaledBPFO
                    )
                }
                
                if result.scaledBSF > 0 {
                    BearingFrequencyItem(
                        title: "BSF",
                        orderValue: result.orderBSF,
                        hzValue: result.scaledBSF
                    )
                }
                
                if result.scaledFTF > 0 {
                    BearingFrequencyItem(
                        title: "FTF",
                        orderValue: result.orderFTF,
                        hzValue: result.scaledFTF
                    )
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

struct BearingFrequencyItem: View {
    let title: String
    let orderValue: Double
    let hzValue: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            if orderValue > 0 {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(String(format: "%.3f", orderValue))×")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                    
                    Text("(\(String(format: "%.1f", hzValue)) Hz)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("\(String(format: "%.1f", hzValue)) Hz")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
        }
        .padding(8)
        .background(Color.blue.opacity(0.05))
        .cornerRadius(6)
    }
}

struct TrendRecommendationsView: View {
    let title: String
    let trends: [TrendRecommendation]
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(color)
            
            LazyVStack(alignment: .leading, spacing: 4) {
                ForEach(trends.prefix(5), id: \.id) { trend in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .font(.caption)
                            .foregroundColor(color)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(trend.name)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            if let frequencyRange = trend.frequencyRangeOrders ?? trend.frequencyRangeHz {
                                Text("(\(frequencyRange))")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        // Priority indicator
                        Text(priorityIcon(for: trend.priority))
                            .font(.caption2)
                    }
                }
                
                if trends.count > 5 {
                    Text("... and \(trends.count - 5) more trends")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.leading, 16)
                }
            }
        }
        .padding()
        .background(color.opacity(0.05))
        .cornerRadius(8)
    }
    
    private func priorityIcon(for priority: TrendPriority) -> String {
        switch priority {
        case .critical: return "🔴"
        case .high: return "🟠"
        case .medium: return "🔵"
        case .low: return "⚪"
        }
    }
}

// MARK: - Export Options View

struct ExportOptionsView: View {
    let results: [APSetDisplayResult]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Export Results")
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack(spacing: 12) {
                    ExportOptionButton(
                        title: "Copy to Clipboard",
                        description: "Copy results as formatted text",
                        icon: "📋"
                    ) {
                        copyToClipboard()
                    }
                    
                    ExportOptionButton(
                        title: "Save as Text File",
                        description: "Export results to a text file",
                        icon: "📄"
                    ) {
                        saveAsTextFile()
                    }
                    
                    ExportOptionButton(
                        title: "Generate Report",
                        description: "Create a comprehensive analysis report",
                        icon: "📊"
                    ) {
                        generateReport()
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func copyToClipboard() {
        let text = formatResultsAsText()
        // TODO: Implement clipboard functionality for Windows
        print("📋 Copying to clipboard: \(text.prefix(100))...")
        dismiss()
    }
    
    private func saveAsTextFile() {
        let text = formatResultsAsText()
        // TODO: Implement file saving for Windows
        print("💾 Saving as text file: \(text.prefix(100))...")
        dismiss()
    }
    
    private func generateReport() {
        // TODO: Implement comprehensive report generation
        print("📊 Generating comprehensive report...")
        dismiss()
    }
    
    private func formatResultsAsText() -> String {
        var text = "VA Calculator Results\n"
        text += "Generated: \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short))\n\n"
        
        for result in results {
            text += result.toClipboardText()
            text += "\n---\n\n"
        }
        
        return text
    }
}

struct ExportOptionButton: View {
    let title: String
    let description: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(icon)
                    .font(.title2)
                
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
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}