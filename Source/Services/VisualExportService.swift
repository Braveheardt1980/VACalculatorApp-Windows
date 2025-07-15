import Foundation

// MARK: - Visual Export Service

class VisualExportService {
    
    // MARK: - Singleton
    
    static let shared = VisualExportService()
    
    // MARK: - HTML Report Generation
    
    func generateHTMLReport(
        results: [APSetDisplayResult],
        configuration: BuildConfiguration,
        buildName: String? = nil
    ) -> String {
        
        let css = generateCSS()
        let header = generateHeader(buildName: buildName, configuration: configuration)
        let resultsContent = generateResultsContent(results: results)
        let footer = generateFooter()
        
        return """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>VA Calculator Report - \(buildName ?? "Analysis Results")</title>
            <style>
            \(css)
            </style>
        </head>
        <body>
            <div class="container">
                \(header)
                \(resultsContent)
                \(footer)
            </div>
        </body>
        </html>
        """
    }
    
    // MARK: - Private Methods
    
    private func generateCSS() -> String {
        return """
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            line-height: 1.6;
            color: #333;
            background-color: #f5f5f5;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            background-color: white;
            min-height: 100vh;
        }
        
        .header {
            border-bottom: 3px solid #007AFF;
            padding-bottom: 20px;
            margin-bottom: 30px;
        }
        
        h1 {
            color: #007AFF;
            font-size: 28px;
            margin-bottom: 10px;
        }
        
        h2 {
            color: #333;
            font-size: 22px;
            margin-top: 30px;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 2px solid #e0e0e0;
        }
        
        h3 {
            color: #666;
            font-size: 18px;
            margin-top: 20px;
            margin-bottom: 10px;
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .info-card {
            background-color: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
            border: 1px solid #e0e0e0;
        }
        
        .info-label {
            font-weight: 600;
            color: #666;
            margin-bottom: 5px;
        }
        
        .info-value {
            font-size: 18px;
            color: #333;
        }
        
        .result-section {
            margin-bottom: 40px;
            padding: 20px;
            background-color: #fafafa;
            border-radius: 12px;
            border: 1px solid #e0e0e0;
        }
        
        .normal-section {
            border-left: 4px solid #4CAF50;
        }
        
        .peakvue-section {
            border-left: 4px solid #2196F3;
        }
        
        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .section-title {
            font-size: 20px;
            font-weight: 600;
        }
        
        .normal-title {
            color: #4CAF50;
        }
        
        .peakvue-title {
            color: #2196F3;
        }
        
        .parameters-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
            background-color: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        
        .parameters-table th,
        .parameters-table td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #e0e0e0;
        }
        
        .parameters-table th {
            background-color: #f5f5f5;
            font-weight: 600;
            color: #666;
        }
        
        .parameters-table tr:last-child td {
            border-bottom: none;
        }
        
        .bearing-frequencies {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
            gap: 10px;
            margin-top: 15px;
        }
        
        .bearing-freq-item {
            background-color: white;
            padding: 10px;
            border-radius: 6px;
            text-align: center;
            border: 1px solid #e0e0e0;
        }
        
        .freq-label {
            font-weight: 600;
            color: #666;
            font-size: 14px;
        }
        
        .freq-value {
            color: #2196F3;
            font-weight: 600;
            margin-top: 5px;
        }
        
        .trends-container {
            background-color: white;
            padding: 15px;
            border-radius: 8px;
            margin-top: 15px;
            border: 1px solid #e0e0e0;
        }
        
        .trend-item {
            padding: 8px 0;
            border-bottom: 1px solid #f0f0f0;
        }
        
        .trend-item:last-child {
            border-bottom: none;
        }
        
        .trend-name {
            font-weight: 600;
            color: #333;
        }
        
        .trend-range {
            color: #666;
            font-size: 14px;
            margin-left: 10px;
        }
        
        .footer {
            margin-top: 50px;
            padding-top: 20px;
            border-top: 1px solid #e0e0e0;
            text-align: center;
            color: #666;
            font-size: 14px;
        }
        
        .validation-warning {
            background-color: #fff3cd;
            border: 1px solid #ffeeba;
            color: #856404;
            padding: 10px;
            border-radius: 6px;
            margin-bottom: 15px;
        }
        
        @media print {
            body {
                background-color: white;
            }
            .container {
                padding: 0;
            }
            .result-section {
                page-break-inside: avoid;
            }
        }
        """
    }
    
    private func generateHeader(buildName: String?, configuration: BuildConfiguration) -> String {
        let title = buildName ?? "VA Calculator Analysis Report"
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let currentDate = dateFormatter.string(from: Date())
        
        return """
        <div class="header">
            <h1>\(title)</h1>
            <p>Generated: \(currentDate)</p>
        </div>
        
        <div class="info-grid">
            <div class="info-card">
                <div class="info-label">Equipment Type</div>
                <div class="info-value">\(configuration.equipmentType)</div>
            </div>
            <div class="info-card">
                <div class="info-label">Operating Speed</div>
                <div class="info-value">\(Int(configuration.rpm)) RPM</div>
            </div>
            <div class="info-card">
                <div class="info-label">Sensor Type</div>
                <div class="info-value">\(configuration.sensorType)</div>
            </div>
            <div class="info-card">
                <div class="info-label">Mounting Method</div>
                <div class="info-value">\(configuration.mountingMethod)</div>
            </div>
        </div>
        """
    }
    
    private func generateResultsContent(results: [APSetDisplayResult]) -> String {
        var content = "<h2>AP Set Results</h2>"
        
        // Group results by bearing
        let grouped = Dictionary(grouping: results) { result in
            result.bearingModel.replacingOccurrences(of: " (PeakVue)", with: "")
        }
        
        for (bearingInfo, bearingResults) in grouped.sorted(by: { $0.key < $1.key }) {
            content += "<h3>\(bearingInfo)</h3>"
            
            // Normal results
            if let normalResult = bearingResults.first(where: { !$0.bearingModel.contains("PeakVue") }) {
                content += generateNormalSection(result: normalResult)
            }
            
            // PeakVue results
            if let peakVueResult = bearingResults.first(where: { $0.bearingModel.contains("PeakVue") }) {
                content += generatePeakVueSection(result: peakVueResult)
            }
        }
        
        return content
    }
    
    private func generateNormalSection(result: APSetDisplayResult) -> String {
        var section = """
        <div class="result-section normal-section">
            <div class="section-header">
                <span class="section-title normal-title">Normal AP Set</span>
                <span>\(result.isValid ? "✅ Valid" : "⚠️ Check Parameters")</span>
            </div>
        """
        
        if !result.isValid && !result.validationMessages.isEmpty {
            section += """
            <div class="validation-warning">
                <strong>Validation Issues:</strong><br>
                \(result.validationMessages.joined(separator: "<br>"))
            </div>
            """
        }
        
        section += """
        <table class="parameters-table">
            <tr>
                <th>Parameter</th>
                <th>Value</th>
            </tr>
            <tr>
                <td>Fmax</td>
                <td>\(String(format: "%.0f", result.fmax)) orders</td>
            </tr>
            <tr>
                <td>LOR</td>
                <td>\(result.lor)</td>
            </tr>
            <tr>
                <td>Shaft Revolutions</td>
                <td>\(String(format: "%.1f", result.shaftRevolutions))</td>
            </tr>
        """
        
        if let calculatedFmax = result.calculatedFmax {
            section += """
            <tr>
                <td>Calculated Fmax</td>
                <td>\(String(format: "%.1f", calculatedFmax)) Hz</td>
            </tr>
            """
        }
        
        section += "</table>"
        
        // Bearing frequencies if available
        if result.scaledBPFI > 0 || result.scaledBPFO > 0 {
            section += """
            <h4>Bearing Fault Frequencies</h4>
            <div class="bearing-frequencies">
            """
            
            if result.scaledBPFI > 0 {
                section += """
                <div class="bearing-freq-item">
                    <div class="freq-label">BPFI</div>
                    <div class="freq-value">\(String(format: "%.3f", result.orderBPFI))×</div>
                    <div>(\(String(format: "%.1f", result.scaledBPFI)) Hz)</div>
                </div>
                """
            }
            
            if result.scaledBPFO > 0 {
                section += """
                <div class="bearing-freq-item">
                    <div class="freq-label">BPFO</div>
                    <div class="freq-value">\(String(format: "%.3f", result.orderBPFO))×</div>
                    <div>(\(String(format: "%.1f", result.scaledBPFO)) Hz)</div>
                </div>
                """
            }
            
            if result.scaledBSF > 0 {
                section += """
                <div class="bearing-freq-item">
                    <div class="freq-label">BSF</div>
                    <div class="freq-value">\(String(format: "%.3f", result.orderBSF))×</div>
                    <div>(\(String(format: "%.1f", result.scaledBSF)) Hz)</div>
                </div>
                """
            }
            
            if result.scaledFTF > 0 {
                section += """
                <div class="bearing-freq-item">
                    <div class="freq-label">FTF</div>
                    <div class="freq-value">\(String(format: "%.3f", result.orderFTF))×</div>
                    <div>(\(String(format: "%.1f", result.scaledFTF)) Hz)</div>
                </div>
                """
            }
            
            section += "</div>"
        }
        
        // Trends
        let normalTrends = result.trendRecommendations.filter { $0.analysisType == .normal }
        if !normalTrends.isEmpty {
            section += """
            <div class="trends-container">
                <h4>Recommended Trends</h4>
            """
            
            for trend in normalTrends.prefix(5) {
                let range = trend.frequencyRangeOrders ?? trend.frequencyRangeHz ?? ""
                section += """
                <div class="trend-item">
                    <span class="trend-name">\(trend.name)</span>
                    <span class="trend-range">\(range)</span>
                </div>
                """
            }
            
            if normalTrends.count > 5 {
                section += """
                <div class="trend-item">
                    <span class="trend-name">... and \(normalTrends.count - 5) more trends</span>
                </div>
                """
            }
            
            section += "</div>"
        }
        
        section += "</div>"
        return section
    }
    
    private func generatePeakVueSection(result: APSetDisplayResult) -> String {
        var section = """
        <div class="result-section peakvue-section">
            <div class="section-header">
                <span class="section-title peakvue-title">PeakVue AP Set</span>
                <span>\(result.isValid ? "✅ Valid" : "⚠️ Check Parameters")</span>
            </div>
        """
        
        section += """
        <table class="parameters-table">
            <tr>
                <th>Parameter</th>
                <th>Value</th>
            </tr>
            <tr>
                <td>Fmax</td>
                <td>\(String(format: "%.0f", result.fmax)) orders</td>
            </tr>
            <tr>
                <td>LOR</td>
                <td>\(result.lor)</td>
            </tr>
            <tr>
                <td>Shaft Revolutions</td>
                <td>\(String(format: "%.1f", result.shaftRevolutions))</td>
            </tr>
        """
        
        if let hpFilter = result.peakVueHPFilter {
            section += """
            <tr>
                <td>HP Filter</td>
                <td>\(String(format: "%.0f", hpFilter)) Hz</td>
            </tr>
            """
        }
        
        if let calculatedFmax = result.peakVueCalculatedFmax {
            section += """
            <tr>
                <td>Calculated Fmax</td>
                <td>\(String(format: "%.1f", calculatedFmax)) Hz</td>
            </tr>
            """
        }
        
        section += "</table>"
        
        // PeakVue Trends
        let peakVueTrends = result.trendRecommendations.filter { $0.analysisType == .peakVue }
        if !peakVueTrends.isEmpty {
            section += """
            <div class="trends-container">
                <h4>Recommended PeakVue Trends</h4>
            """
            
            for trend in peakVueTrends.prefix(5) {
                let range = trend.frequencyRangeOrders ?? trend.frequencyRangeHz ?? ""
                section += """
                <div class="trend-item">
                    <span class="trend-name">\(trend.name)</span>
                    <span class="trend-range">\(range)</span>
                </div>
                """
            }
            
            if peakVueTrends.count > 5 {
                section += """
                <div class="trend-item">
                    <span class="trend-name">... and \(peakVueTrends.count - 5) more trends</span>
                </div>
                """
            }
            
            section += "</div>"
        }
        
        section += "</div>"
        return section
    }
    
    private func generateFooter() -> String {
        return """
        <div class="footer">
            <p>VA Calculator Professional - Windows Edition</p>
            <p>© 2025 - Professional Vibration Analysis Software</p>
        </div>
        """
    }
    
    // MARK: - File Export
    
    func saveHTMLReport(
        html: String,
        to path: String
    ) throws {
        guard let data = html.data(using: .utf8) else {
            throw ExportError.encodingFailed
        }
        
        let url = URL(fileURLWithPath: path)
        try data.write(to: url)
    }
    
    // MARK: - Error Types
    
    enum ExportError: Error {
        case encodingFailed
        case writeFailed
        
        var localizedDescription: String {
            switch self {
            case .encodingFailed:
                return "Failed to encode HTML content"
            case .writeFailed:
                return "Failed to write file to disk"
            }
        }
    }
}