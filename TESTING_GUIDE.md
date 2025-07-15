# Testing Guide - VA Calculator Windows

## 🧪 Current Testing Options

### Option 1: Test on macOS (Immediate)
The app can run on macOS using SwiftCrossUI's cross-platform capabilities:

```bash
# Run from project directory
./.build/debug/VACalculatorApp-Windows
```

This will launch a window where you can:
- Enter RPM values (e.g., 1800)
- Click bearing type to cycle through options (Generic → 6205 → 6309)
- Click "Calculate AP Sets" to see results
- View Normal and PeakVue calculation results

### Option 2: Build & Test on Windows

#### Prerequisites on Windows:
1. **Install Swift for Windows:**
   - Download from: https://www.swift.org/download/
   - Choose "Windows 10/11" installer
   - Run installer with admin privileges

2. **Install Visual Studio Build Tools:**
   - Required for Windows development
   - Download from Microsoft

3. **Install GTK for Windows (optional):**
   - If using GTK backend: `winget install gnome.gtk`

#### Build Steps on Windows:
```powershell
# 1. Navigate to project directory
cd VACalculatorApp-Windows

# 2. Resolve dependencies
swift package resolve

# 3. Build release version
swift build --configuration release

# 4. Run the executable
.\.build\release\VACalculatorApp-Windows.exe
```

### Option 3: Test Core Calculations Only

For quick testing without UI:

```bash
# Create a test script
swift Source/main_minimal.swift
```

This runs the calculation engine directly and outputs results to console.

## 📋 Test Scenarios

### Basic Functionality Test:
1. **Launch Application**
   - Verify window opens with title "VA Calculator - Professional Vibration Analysis"
   - Check initial UI loads correctly

2. **Input Validation**
   - Enter RPM: 1800
   - Verify Calculate button becomes enabled
   - Clear RPM field
   - Verify Calculate button disables

3. **Bearing Selection**
   - Click bearing type button
   - Verify it cycles: Generic → 6205 → 6309 → Generic

4. **Calculation Test**
   - Set RPM: 1800
   - Set Bearing: 6205
   - Click Calculate
   - Verify results show:
     - Normal Analysis (Fmax: 25.9 orders, LOR: 800)
     - PeakVue Analysis (Fmax: 9.9 orders, LOR: 400)
     - Core Service validation results

### Advanced Testing:
1. **Different RPM Values**
   - Test with: 900, 1200, 1800, 3600 RPM
   - Verify calculations scale correctly

2. **All Bearing Types**
   - Test Generic, 6205, and 6309
   - Verify bearing-specific frequencies appear for non-generic

3. **Edge Cases**
   - Enter 0 or negative RPM
   - Enter very high RPM (10000+)
   - Enter non-numeric values

## 🎯 Expected Results

### For 1800 RPM with 6205 Bearing:
```
📊 Normal Analysis Results:
   • Fmax: 25.9 orders
   • LOR: 800
   • Shaft Revolutions: 26.67
   • Calculated Fmax: 777.0 Hz
   • BPFI: 238.2 Hz
   • BPFO: 151.8 Hz

⚡ PeakVue Analysis Results:
   • Fmax: 9.9 orders
   • LOR: 400
   • HP Filter: 1000 Hz
   • Calculated Fmax: 297.0 Hz
```

## 🚀 Quick Start Testing

**Fastest way to test right now on macOS:**
```bash
cd /Users/willemdebeer/Desktop/VACalculatorApp-Windows
./.build/debug/VACalculatorApp-Windows
```

The app will launch with a simple UI where you can immediately test the calculation engine!