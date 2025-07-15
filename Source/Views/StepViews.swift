import SwiftCrossUI
import Foundation

// MARK: - Equipment Type Step View

struct EquipmentTypeStepView: View {
    @Binding var equipmentType: String
    let gearboxEnabled: Bool
    @State private var showingComingSoonMessage = false
    @State private var selectedUnsupportedType = ""
    
    private let equipmentTypes = [
        "Motor", "Pump", "Fan", "Compressor", "Gearbox", 
        "Generator", "Pulley", "Crusher", "Mixer", "Other"
    ]
    
    private var supportedEquipmentTypes: [String] {
        if gearboxEnabled {
            return ["Motor", "Pump", "Fan", "Pulley", "Compressor", "Gearbox", "Generator", "Crusher", "Mixer", "Other"]
        } else {
            return ["Motor", "Pump", "Fan", "Pulley", "Compressor", "Generator", "Crusher", "Mixer", "Other"]
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Equipment Type")
                .font(.headline)
                .fontWeight(.bold)
            
            Text("Select the type of equipment you're monitoring:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(equipmentTypes, id: \.self) { type in
                    Button(action: {
                        if supportedEquipmentTypes.contains(type) {
                            equipmentType = type
                        } else {
                            selectedUnsupportedType = type
                            showingComingSoonMessage = true
                        }
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(iconFor(equipmentType: type))
                                    .font(.title2)
                                
                                Spacer()
                                
                                if equipmentType == type {
                                    Text("✓")
                                        .foregroundColor(.blue)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                }
                            }
                            
                            Text(type)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text(descriptionFor(equipmentType: type))
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        .frame(height: 80)
                        .padding()
                        .background(equipmentType == type ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(equipmentType == type ? Color.blue : Color.clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .alert("Feature Coming Soon", isPresented: $showingComingSoonMessage) {
            Button("OK") { }
        } message: {
            Text("\(selectedUnsupportedType) support is coming in a future update.")
        }
    }
    
    private func iconFor(equipmentType: String) -> String {
        switch equipmentType {
        case "Motor": return "⚡"
        case "Pump": return "💧"
        case "Fan": return "🌪️"
        case "Gearbox": return "⚙️"
        case "Compressor": return "🔧"
        case "Generator": return "🔋"
        case "Pulley": return "🔄"
        case "Crusher": return "⚒️"
        case "Mixer": return "🥄"
        case "Other": return "📊"
        default: return "❓"
        }
    }
    
    private func descriptionFor(equipmentType: String) -> String {
        switch equipmentType {
        case "Motor": return "Electric motors and drives"
        case "Pump": return "Centrifugal and positive displacement"
        case "Fan": return "Axial and centrifugal fans"
        case "Gearbox": return "Multi-shaft gear systems"
        case "Compressor": return "Air and gas compressors"
        case "Generator": return "Electrical generators"
        case "Pulley": return "Conveyor and belt systems"
        case "Crusher": return "Material crushing equipment"
        case "Mixer": return "Industrial mixing equipment"
        case "Other": return "General rotating machinery"
        default: return "Select for vibration analysis"
        }
    }
}

// MARK: - Sensor Configuration Step View

struct SensorConfigurationStepView: View {
    @Binding var sensorType: String
    @Binding var mountingMethod: String
    
    private let sensorTypes = ["Accelerometer", "Velocity", "Displacement"]
    private let mountingMethods = ["Stud", "Magnet", "Handheld", "Triaxial"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Sensor Configuration")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text("Configure your vibration sensor settings:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Sensor Type Selection
            VStack(alignment: .leading, spacing: 8) {
                Text("Sensor Type")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 8) {
                    ForEach(sensorTypes, id: \.self) { type in
                        Button(action: {
                            sensorType = type
                        }) {
                            VStack(spacing: 4) {
                                Text(sensorIconFor(type: type))
                                    .font(.title2)
                                
                                Text(type)
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .frame(height: 60)
                            .frame(maxWidth: .infinity)
                            .background(sensorType == type ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(sensorType == type ? Color.blue : Color.clear, lineWidth: 2)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            // Mounting Method Selection
            VStack(alignment: .leading, spacing: 8) {
                Text("Mounting Method")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 8) {
                    ForEach(mountingMethods, id: \.self) { method in
                        Button(action: {
                            mountingMethod = method
                        }) {
                            VStack(spacing: 4) {
                                Text(mountingIconFor(method: method))
                                    .font(.title2)
                                
                                Text(method)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                
                                Text(mountingDescriptionFor(method: method))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(height: 70)
                            .frame(maxWidth: .infinity)
                            .background(mountingMethod == method ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(mountingMethod == method ? Color.blue : Color.clear, lineWidth: 2)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
    
    private func sensorIconFor(type: String) -> String {
        switch type {
        case "Accelerometer": return "📳"
        case "Velocity": return "📏"
        case "Displacement": return "📐"
        default: return "📊"
        }
    }
    
    private func mountingIconFor(method: String) -> String {
        switch method {
        case "Stud": return "🔩"
        case "Magnet": return "🧲"
        case "Handheld": return "✋"
        case "Triaxial": return "📊"
        default: return "🔧"
        }
    }
    
    private func mountingDescriptionFor(method: String) -> String {
        switch method {
        case "Stud": return "Permanent threaded mount"
        case "Magnet": return "Magnetic attachment"
        case "Handheld": return "Manual measurement"
        case "Triaxial": return "Three-axis mounting"
        default: return "Standard mounting"
        }
    }
}

// MARK: - RPM Input Step View

struct RPMInputStepView: View {
    @Binding var rpm: String
    let equipmentType: String
    @State private var isValidRPM = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Operating Speed")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text("Enter the normal operating speed for this \(equipmentType.lowercased()):")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    TextField("Enter RPM (e.g., 1800)", text: $rpm)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .onChange(of: rpm) { newValue in
                            validateRPM(newValue)
                        }
                    
                    Text("RPM")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if !isValidRPM {
                    Text("Please enter a valid RPM between 1 and 50,000")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
                // Show frequency calculation if valid RPM
                if let rpmValue = Double(rpm), rpmValue > 0 {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Calculated Values:")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text("Running Speed: \(String(format: "%.2f", rpmValue / 60.0)) Hz")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 4)
                }
            }
            
            // Common RPM suggestions
            VStack(alignment: .leading, spacing: 8) {
                Text("Common Operating Speeds:")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 8) {
                    ForEach(commonRPMValues(for: equipmentType), id: \.self) { rpmValue in
                        Button(action: {
                            rpm = String(rpmValue)
                        }) {
                            Text("\(rpmValue)")
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
    
    private func validateRPM(_ value: String) {
        if let rpmValue = Double(value) {
            isValidRPM = rpmValue > 0 && rpmValue <= 50000
        } else {
            isValidRPM = !value.isEmpty ? false : true
        }
    }
    
    private func commonRPMValues(for equipmentType: String) -> [Int] {
        switch equipmentType {
        case "Motor":
            return [1800, 3600, 1200, 900]
        case "Pump":
            return [1800, 3600, 1200, 3000]
        case "Fan":
            return [1800, 1200, 900, 600]
        case "Compressor":
            return [1800, 3600, 1200, 900]
        case "Generator":
            return [1800, 3600, 1200, 1500]
        default:
            return [1800, 3600, 1200, 900]
        }
    }
}

// MARK: - Bearing Information Step View

struct BearingInformationStepView: View {
    @Binding var bearingInfoKnown: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Bearing Information")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text("Do you have detailed bearing specifications for this equipment?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 12) {
                Button(action: {
                    bearingInfoKnown = true
                }) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("🔍")
                                .font(.title2)
                            
                            Text("Yes, I have bearing specifications")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            if bearingInfoKnown {
                                Text("✓")
                                    .foregroundColor(.blue)
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                        }
                        
                        Text("I can provide bearing model numbers and specifications for more accurate analysis.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(bearingInfoKnown ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(bearingInfoKnown ? Color.blue : Color.clear, lineWidth: 2)
                    )
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    bearingInfoKnown = false
                }) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("📊")
                                .font(.title2)
                            
                            Text("No, use industry standards")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            if !bearingInfoKnown {
                                Text("✓")
                                    .foregroundColor(.blue)
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                        }
                        
                        Text("Use generic bearing calculations based on industry standards and best practices.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(!bearingInfoKnown ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(!bearingInfoKnown ? Color.blue : Color.clear, lineWidth: 2)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Summary Step View

struct SummaryStepView: View {
    let equipmentType: String
    let sensorType: String
    let mountingMethod: String
    let rpm: String
    let bearingInfoKnown: Bool
    let bearingCount: Int
    let selectedBearings: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Configuration Summary")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 16) {
                SummaryRow(title: "Equipment Type", value: equipmentType, icon: "⚙️")
                SummaryRow(title: "Sensor Type", value: sensorType, icon: "📳")
                SummaryRow(title: "Mounting Method", value: mountingMethod, icon: "🔧")
                SummaryRow(title: "Operating Speed", value: "\(rpm) RPM", icon: "⚡")
                
                if bearingInfoKnown {
                    SummaryRow(title: "Bearing Information", value: "Detailed specifications", icon: "🔍")
                    SummaryRow(title: "Bearing Count", value: "\(bearingCount)", icon: "⚙️")
                    
                    if !selectedBearings.filter({ !$0.isEmpty }).isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("🔍")
                                    .font(.title3)
                                
                                Text("Selected Bearings:")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            
                            ForEach(selectedBearings.prefix(bearingCount).enumerated().map({ $0 }), id: \.offset) { index, bearing in
                                if !bearing.isEmpty {
                                    Text("• \(bearing)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.leading, 24)
                                }
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(8)
                    }
                } else {
                    SummaryRow(title: "Bearing Information", value: "Industry standards", icon: "📊")
                }
            }
            
            Text("Ready to calculate AP Set configurations based on your settings.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top)
        }
    }
}

// MARK: - Summary Row Component

struct SummaryRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Text(icon)
                .font(.title3)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}