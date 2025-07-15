import SwiftCrossUI
import Foundation

// MARK: - Main Calculator View

struct MainCalculatorView: View {
    @State private var currentStep = 0
    @State private var isCalculating = false
    @State private var showingResults = false
    @State private var calculationResults: [APSetDisplayResult] = []
    
    // Step configuration
    @State private var equipmentType = ""
    @State private var sensorType = "Accelerometer"
    @State private var mountingMethod = "Stud"
    @State private var rpm = ""
    @State private var bearingInfoKnown = false
    @State private var bearingCount = 2
    @State private var selectedBearings: [String] = Array(repeating: "", count: 10)
    
    private let totalSteps = 5
    private let gearboxEnabled = true // Feature flag for gearbox support
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress Bar
                ProgressBarView(currentStep: currentStep, totalSteps: totalSteps)
                
                // Main Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Step Content
                        Group {
                            switch currentStep {
                            case 0:
                                EquipmentTypeStepView(
                                    equipmentType: $equipmentType,
                                    gearboxEnabled: gearboxEnabled
                                )
                            case 1:
                                SensorConfigurationStepView(
                                    sensorType: $sensorType,
                                    mountingMethod: $mountingMethod
                                )
                            case 2:
                                RPMInputStepView(
                                    rpm: $rpm,
                                    equipmentType: equipmentType
                                )
                            case 3:
                                BearingInformationStepView(
                                    bearingInfoKnown: $bearingInfoKnown
                                )
                            case 4:
                                SummaryStepView(
                                    equipmentType: equipmentType,
                                    sensorType: sensorType,
                                    mountingMethod: mountingMethod,
                                    rpm: rpm,
                                    bearingInfoKnown: bearingInfoKnown,
                                    bearingCount: bearingCount,
                                    selectedBearings: selectedBearings
                                )
                            default:
                                EmptyView()
                            }
                        }
                        .padding()
                        .animation(.easeInOut(duration: 0.3), value: currentStep)
                    }
                }
                
                // Navigation Controls
                NavigationControlsView(
                    currentStep: currentStep,
                    totalSteps: totalSteps,
                    canProceed: canProceedToNextStep(),
                    isCalculating: isCalculating,
                    onPrevious: { moveToPreviousStep() },
                    onNext: { moveToNextStep() },
                    onCalculate: { performCalculation() }
                )
            }
            .navigationTitle("VA Calculator - Professional")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingResults) {
            APSetResultsView(results: calculationResults)
        }
    }
    
    // MARK: - Step Navigation
    
    private func canProceedToNextStep() -> Bool {
        switch currentStep {
        case 0: return !equipmentType.isEmpty
        case 1: return !sensorType.isEmpty && !mountingMethod.isEmpty
        case 2: return isValidRPM(rpm)
        case 3: return true // Bearing info is optional
        case 4: return true // Summary is always valid
        default: return false
        }
    }
    
    private func moveToPreviousStep() {
        if currentStep > 0 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep -= 1
            }
        }
    }
    
    private func moveToNextStep() {
        if currentStep < totalSteps - 1 && canProceedToNextStep() {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep += 1
            }
        }
    }
    
    private func isValidRPM(_ value: String) -> Bool {
        guard let rpmValue = Double(value) else { return false }
        return rpmValue > 0 && rpmValue <= 50000
    }
    
    // MARK: - Calculation Logic
    
    private func performCalculation() {
        guard canProceedToNextStep(),
              let rpmValue = Double(rpm) else {
            return
        }
        
        isCalculating = true
        
        // Create configuration for calculation
        let configuration = BuildConfiguration(
            equipmentType: equipmentType,
            sensorType: sensorType,
            mountingMethod: mountingMethod,
            rpm: rpmValue,
            bearingInfoKnown: bearingInfoKnown,
            bearingCount: bearingCount,
            selectedBearings: selectedBearings.prefix(bearingCount).map { $0 }
        )
        
        // Perform calculation on background thread
        DispatchQueue.global(qos: .userInitiated).async {
            let results = calculateAPSetResults(for: configuration)
            
            DispatchQueue.main.async {
                self.calculationResults = results
                self.isCalculating = false
                self.showingResults = true
            }
        }
    }
    
    private func calculateAPSetResults(for configuration: BuildConfiguration) -> [APSetDisplayResult] {
        let calculator = UnifiedCalculationService()
        
        // Prepare bearing data
        let bearings: [BearingData]
        if configuration.bearingInfoKnown {
            bearings = configuration.selectedBearings.compactMap { bearingModel in
                guard !bearingModel.isEmpty else { return nil }
                return BearingLookupEngine.shared.findBearing(byModel: bearingModel)
            }
        } else {
            // Use generic bearing for the equipment type
            bearings = [BearingLookupEngine.shared.getGenericBearing(for: configuration.equipmentType)]
        }
        
        var results: [APSetDisplayResult] = []
        
        // Calculate for each bearing
        for bearing in bearings {
            // Normal calculation
            if let normalResult = calculator.calculateUnifiedShaftBearingResults(
                bearingData: bearing,
                rpm: configuration.rpm,
                analysisType: .normal,
                sensorType: configuration.sensorType,
                mountingMethod: configuration.mountingMethod
            ) {
                results.append(normalResult)
            }
            
            // PeakVue calculation
            if let peakVueResult = calculator.calculateUnifiedShaftBearingResults(
                bearingData: bearing,
                rpm: configuration.rpm,
                analysisType: .peakVue,
                sensorType: configuration.sensorType,
                mountingMethod: configuration.mountingMethod
            ) {
                results.append(peakVueResult)
            }
        }
        
        return results
    }
}

// MARK: - Progress Bar View

struct ProgressBarView: View {
    let currentStep: Int
    let totalSteps: Int
    
    private var progress: Double {
        Double(currentStep + 1) / Double(totalSteps)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Step indicators
            HStack {
                ForEach(0..<totalSteps, id: \.self) { step in
                    Circle()
                        .fill(step <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 12, height: 12)
                    
                    if step < totalSteps - 1 {
                        Rectangle()
                            .fill(step < currentStep ? Color.blue : Color.gray.opacity(0.3))
                            .frame(height: 2)
                    }
                }
            }
            .padding(.horizontal)
            
            // Progress text
            Text("Step \(currentStep + 1) of \(totalSteps)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 12)
        .background(Color.gray.opacity(0.05))
    }
}

// MARK: - Navigation Controls View

struct NavigationControlsView: View {
    let currentStep: Int
    let totalSteps: Int
    let canProceed: Bool
    let isCalculating: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onCalculate: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Previous Button
            Button(action: onPrevious) {
                HStack {
                    Text("←")
                    Text("Previous")
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .background(Color.gray.opacity(0.2))
                .foregroundColor(.primary)
                .cornerRadius(8)
            }
            .disabled(currentStep == 0)
            .opacity(currentStep == 0 ? 0.5 : 1.0)
            
            Spacer()
            
            // Next/Calculate Button
            if currentStep == totalSteps - 1 {
                // Calculate Button
                Button(action: onCalculate) {
                    HStack {
                        if isCalculating {
                            Text("🔄")
                                .rotationEffect(.degrees(isCalculating ? 360 : 0))
                                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isCalculating)
                        }
                        Text(isCalculating ? "Calculating..." : "Calculate AP Sets")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(canProceed && !isCalculating ? Color.blue : Color.gray.opacity(0.3))
                    .foregroundColor(canProceed && !isCalculating ? .white : .secondary)
                    .cornerRadius(8)
                }
                .disabled(!canProceed || isCalculating)
            } else {
                // Next Button
                Button(action: onNext) {
                    HStack {
                        Text("Next")
                        Text("→")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(canProceed ? Color.blue : Color.gray.opacity(0.3))
                    .foregroundColor(canProceed ? .white : .secondary)
                    .cornerRadius(8)
                }
                .disabled(!canProceed)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
    }
}

// MARK: - Build Configuration Model
// BuildConfiguration is now defined in /Source/Models/BuildConfiguration.swift

// MARK: - Content View (App Entry Point)

struct ContentView: View {
    var body: some View {
        MainCalculatorView()
            .preferredColorScheme(.light) // Ensure consistent appearance
    }
}