//
//  ContentView.swift
//  Squircle_Demo_Tweak
//
//  Created by Rajan Panchal on 21/02/25.
//

import SwiftUI
import CoreGraphics
import Squircle

struct SquircleConfigView: View {
    @State private var config = SquircleConfiguration.default
    @State private var width: CGFloat = 150
    @State private var height: CGFloat = 150
    @State private var showCodeSheet = false
    @State private var selectedTab = 0
    
    // Color states
    @State private var fillColor: Color = .blue
    @State private var useGradient = false
    @State private var gradientStartColor: Color = .blue
    @State private var gradientEndColor: Color = .purple
    @State private var showStroke = false
    @State private var strokeColor: Color = .black
    @State private var strokeWidth: CGFloat = 2
    
    private let tabs = ["Basic", "Style", "Effects"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Preview
                ZStack {
                    if useGradient {
                        Rectangle()
                            .squircle(config)
                            .frame(width: width, height: height)
                    } else {
                        Rectangle()
                            .squircle(config)
                            .frame(width: width, height: height)
                    }
                }
                .padding()
                
                Picker("Configuration", selection: $selectedTab) {
                    ForEach(0..<tabs.count, id: \.self) { index in
                        Text(tabs[index]).tag(index)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 16) {
                        switch selectedTab {
                        case 0:
                            basicControls
                        case 1:
                            styleControls
                        case 2:
                            effectsControls
                        default:
                            EmptyView()
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Squircle Config")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showCodeSheet = true }) {
                        Image(systemName: "doc.text")
                    }
                }
            }
            .sheet(isPresented: $showCodeSheet) {
                CodeSheetView(code: generatedCode)
            }
        }
    }
    
    private var basicControls: some View {
        Group {
            HStack {
                CustomSlider(value: $width, range: 100...250, title: "Width")
                CustomSlider(value: $height, range: 100...250, title: "Height")
            }
            
            CustomSlider(value: $config.cornerRadiusFactor, range: 0...0.5, title: "Corner Radius")
            CustomSlider(value: $config.smoothFactor, range: 0...0.5, title: "Smoothness")
            CustomSlider(value: $config.edgeCurvatureMultiplier, range: 0.1...1, title: "Edge Curve")
        }
    }
    
    private var styleControls: some View {
        Group {
            Toggle("Use Gradient", isOn: $useGradient)
                .opacity(0.5)
                .disabled(true) // Gradient not supported yet
                .onChange(of: useGradient) { newValue in
                    if newValue {
                        config.gradient = LinearGradient(
                            colors: [gradientStartColor, gradientEndColor],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        config.fillColor = nil
                    } else {
                        config.gradient = nil
                        config.fillColor = fillColor
                    }
                }
            
            if useGradient {
                ColorPicker("Start Color", selection: $gradientStartColor)
                    .onChange(of: gradientStartColor) { _ in
                        updateGradient()
                    }
                ColorPicker("End Color", selection: $gradientEndColor)
                    .onChange(of: gradientEndColor) { _ in
                        updateGradient()
                    }
            } else {
                ColorPicker("Fill Color", selection: $fillColor)
                    .onChange(of: fillColor) { newValue in
                        config.fillColor = newValue
                    }
            }
            
            Toggle("Show Stroke", isOn: $showStroke)
                .onChange(of: showStroke) { newValue in
                    config.strokeColor = newValue ? strokeColor : nil
                    config.strokeWidth = newValue ? strokeWidth : nil
                }
            
            if showStroke {
                ColorPicker("Stroke Color", selection: $strokeColor)
                    .onChange(of: strokeColor) { newValue in
                        config.strokeColor = newValue
                    }
                
                CustomSlider(value: $strokeWidth, range: 1...10, title: "Stroke Width")
                    .onChange(of: strokeWidth) { newValue in
                        config.strokeWidth = newValue
                    }
            }
        }
    }
    
    private var effectsControls: some View {
        Group {
            Toggle("Enable Shadow", isOn: $config.shadow)
            
            if config.shadow {
                ColorPicker("Shadow Color", selection: $config.shadowColor)
                CustomSlider(value: $config.shadowRadius, range: 0...20, title: "Shadow Radius")
                
                VStack(alignment: .leading) {
                    Text("Shadow Offset")
                    HStack {
                        CustomSlider(value: .init(
                            get: { config.shadowOffset.width },
                            set: { config.shadowOffset.width = $0 }
                        ), range: -20...20, title: "X")
                        
                        CustomSlider(value: .init(
                            get: { config.shadowOffset.height },
                            set: { config.shadowOffset.height = $0 }
                        ), range: -20...20, title: "Y")
                    }
                }
            }
        }
    }
    
    private func updateGradient() {
        config.gradient = LinearGradient(
            colors: [gradientStartColor, gradientEndColor],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var generatedCode: String {
        var code = """
        var config = SquircleConfiguration(
            cornerRadiusFactor: \(String(format: "%.2f", config.cornerRadiusFactor)),
            smoothFactor: \(String(format: "%.2f", config.smoothFactor)),
            edgeCurvatureMultiplier: \(String(format: "%.2f", config.edgeCurvatureMultiplier))
        """

        var properties: [String] = []

        if useGradient {
            properties.append("""
            gradient: LinearGradient(
                colors: [.\(gradientStartColor.description), .\(gradientEndColor.description)],
                startPoint: .leading,
                endPoint: .trailing
            )
            """)
        } else if let fillColor = config.fillColor {
            properties.append("fillColor: .\(fillColor.description)")
        }

        if let strokeColor = config.strokeColor {
            properties.append("strokeColor: .\(strokeColor.description)")
            properties.append("strokeWidth: \(String(format: "%.1f", config.strokeWidth ?? 0))")
        }

        if config.shadow {
            properties.append("shadow: true")
            properties.append("shadowRadius: \(String(format: "%.1f", config.shadowRadius))")
            properties.append("shadowColor: .\(config.shadowColor.description)")
            properties.append("shadowOffset: CGSize(width: \(String(format: "%.1f", config.shadowOffset.width)), height: \(String(format: "%.1f", config.shadowOffset.height)))")
        }

        if !properties.isEmpty {
            code += ",\n    " + properties.joined(separator: ",\n    ")
        }

        code += "\n)"

        return code + "\n\n// Apply to any view:\n.squircle(config)"
    }

}

struct CustomSlider: View {
    @Binding var value: CGFloat
    let range: ClosedRange<CGFloat>
    let title: String
    
    var body: some View {
        VStack(spacing: 2) {
            HStack {
                Text(title)
                    .font(.caption2)
                Spacer()
                Text(String(format: "%.2f", value))
                    .font(.caption2)
                    .monospacedDigit()
            }
            Slider(value: $value, in: range)
        }
    }
}

struct CodeSheetView: View {
    @Environment(\.dismiss) private var dismiss
    let code: String
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text(code)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .textSelection(.enabled)
                
                HStack(spacing: 16) {
                    Button(action: {
                        UIPasteboard.general.string = code
                    }) {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                    
                    Button(action: {
                        print("\n=== Squircle Extension Code ===")
                        print(code)
                        print("===========================\n")
                    }) {
                        Label("Print", systemImage: "printer")
                    }
                }
                .buttonStyle(.bordered)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Generated Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

