# Gurupia Studio v1.0 - Ready to Use

This directory contains the fully compiled Gurupia Inno Studio IDE and the custom Inno Setup compiler with Zstd/Brotli support.

## 📁 Included Files
- `InnoSetupIDE.exe`: The main .NET User Interface.
- `ISCC.exe`: The Command-Line Compiler (supports Zstd/Brotli).
- `ISCmplr.dll` & `iszstd.dll`: Core compiler components and compression libraries.
- `Default.isl`: Korean/English language resource.

## 🚀 How to Run
1.  Run `InnoSetupIDE.exe`.
2.  Open or create an Inno Setup script (`.iss`).
3.  Select a compression method (e.g., **zstd**) from the toolbar.
4.  Click **Compile** (or press **F9**).
5.  Wait for the sprig-green output in the console to confirm a successful build.

## 🛠 Features
- **Modern Hybrid UI**: Code editing + Visual Designers.
- **Two-Way Sync**: Changes in the PropertyGrid instantly update your code.
- **Zstd Support**: High-performance compression integration.

---
*Developed for Gurupia Installer Project*
