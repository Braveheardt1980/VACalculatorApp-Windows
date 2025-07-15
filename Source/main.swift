import SwiftCrossUI
import DefaultBackend

// MARK: - VA Calculator App Windows Entry Point

@main
struct VACalculatorApp: App {
    
    init() {
        // Initialize security system
        SecurityManager.shared.initializeSecuritySystem()
    }
    
    var body: some Scene {
        WindowGroup("VA Calculator - Professional Vibration Analysis") {
            AppContentView()
                .frame(minWidth: 1200, minHeight: 800)
        }
    }
}

// MARK: - Main Content View

struct AppContentView: View {
    @State private var showLicenseError = false
    @State private var licenseErrorMessage = ""
    @State private var isLicenseValid = false
    
    var body: some View {
        Group {
            if isLicenseValid {
                SimpleMainCalculatorView()
            } else {
                LicenseValidationView(
                    isValid: $isLicenseValid,
                    errorMessage: $licenseErrorMessage
                )
            }
        }
        .onAppear {
            validateLicense()
        }
        .alert("License Validation Failed", isPresented: $showLicenseError) {
            Button("Exit") {
                // TODO: Implement proper application exit
                print("Application will exit")
            }
        } message: {
            Text(licenseErrorMessage)
        }
    }
    
    private func validateLicense() {
        let validationResult = SecurityManager.shared.validateLicense()
        
        switch validationResult {
        case .success:
            isLicenseValid = true
        case .failure(let error):
            isLicenseValid = false
            licenseErrorMessage = error.localizedDescription
            showLicenseError = true
        }
    }
}

// MARK: - License Validation View

struct LicenseValidationView: View {
    @Binding var isValid: Bool
    @Binding var errorMessage: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "shield.checkered")
                .font(.system(size: 64))
                .foregroundColor(.orange)
            
            Text("VA Calculator")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Professional Vibration Analysis")
                .font(.title2)
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                Text("Validating License...")
                    .font(.headline)
                
                ProgressView()
                    .scaleEffect(1.2)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            
            Text("This application requires a valid license to operate.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxWidth: 500)
    }
}

// MARK: - Placeholder Main Calculator View

struct SimpleMainCalculatorView: View {
    @State private var currentStep = 0
    @State private var equipmentType = ""
    @State private var rpm = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("VA Calculator")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Professional Vibration Analysis - Windows Edition")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Step indicator
                HStack {
                    Text("Step \(currentStep + 1) of 7")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Text("Equipment Setup")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Main content area
                ScrollView {
                    VStack(spacing: 24) {
                        // Equipment Type Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Equipment Type")
                                .font(.headline)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                EquipmentTypeButton(title: "Motor", icon: "⚡", isSelected: equipmentType == "Motor") {
                                    equipmentType = "Motor"
                                }
                                EquipmentTypeButton(title: "Pump", icon: "💧", isSelected: equipmentType == "Pump") {
                                    equipmentType = "Pump"
                                }
                                EquipmentTypeButton(title: "Fan", icon: "🌪️", isSelected: equipmentType == "Fan") {
                                    equipmentType = "Fan"
                                }
                                EquipmentTypeButton(title: "Gearbox", icon: "⚙️", isSelected: equipmentType == "Gearbox") {
                                    equipmentType = "Gearbox"
                                }
                                EquipmentTypeButton(title: "Compressor", icon: "🔧", isSelected: equipmentType == "Compressor") {
                                    equipmentType = "Compressor"
                                }
                                EquipmentTypeButton(title: "Other", icon: "📊", isSelected: equipmentType == "Other") {
                                    equipmentType = "Other"
                                }
                            }
                        }
                        
                        // RPM Input
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Operating Speed (RPM)")
                                .font(.headline)
                            
                            TextField("Enter RPM (e.g., 1800)", text: $rpm)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding()
                }
                
                // Navigation buttons
                HStack {
                    Button("Previous") {
                        if currentStep > 0 {
                            currentStep -= 1
                        }
                    }
                    .disabled(currentStep == 0)
                    
                    Spacer()
                    
                    Button("Next") {
                        if currentStep < 6 {
                            currentStep += 1
                        }
                    }
                    .disabled(equipmentType.isEmpty || rpm.isEmpty)
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
        .navigationTitle("VA Calculator")
    }
}

// MARK: - Equipment Type Button

struct EquipmentTypeButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(icon)
                    .font(.system(size: 32))
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}