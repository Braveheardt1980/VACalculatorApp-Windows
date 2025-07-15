# Simplest Way to Get Your Portable EXE

## What You Need:
1. Access to ONE Windows PC with Swift installed (just for building)
2. 5 minutes

## Steps on the Windows Build PC:

### 1. Copy your project folder to Windows

### 2. Open Command Prompt and run:
```cmd
cd VACalculatorApp-Windows

swift build -c release --static-swift-stdlib
```

### 3. Find your exe:
```
.build\release\VACalculatorApp-Windows.exe
```

### 4. Create portable folder:
```cmd
mkdir VACalculator-Portable
copy .build\release\VACalculatorApp-Windows.exe VACalculator-Portable\
```

## That's it! 

The `VACalculator-Portable` folder now contains a standalone EXE that works on ANY Windows PC without Swift installed.

Just copy this folder to any Windows machine and double-click the .exe file.

## File size: ~30-50 MB (includes embedded Swift runtime)

---

## Don't have access to Windows?

Ask a friend/colleague with Windows to:
1. Install Swift for Windows (one time)
2. Run the build command above
3. Send you the resulting .exe file

Or use a Windows VM/cloud service for 30 minutes to build it once.