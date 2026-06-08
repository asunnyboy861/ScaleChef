import SwiftUI

struct PanCalculatorView: View {
    @State private var viewModel = PanCalculatorViewModel()
    @Environment(PurchaseService.self) private var purchaseService
    @State private var showPaywall = false

    var body: some View {
        ScrollView {
            VStack(spacing: SCSpace.lg) {
                originalPanSection
                newPanSection
                calculateButton
                resultSection
            }
            .padding(.horizontal, SCSpace.md)
            .padding(.top, SCSpace.md)
        }
        .background(Color.scBackground)
        .navigationTitle("Pan Calculator")
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    private var originalPanSection: some View {
        VStack(alignment: .leading, spacing: SCSpace.sm) {
            Text("Original Pan")
                .font(SCFont.title2)
                .foregroundStyle(Color.scTextPrimary)

            Picker("Shape", selection: $viewModel.originalShape) {
                ForEach(PanShape.allCases, id: \.self) { shape in
                    Text(shape.rawValue).tag(shape)
                }
            }
            .pickerStyle(.segmented)

            HStack {
                VStack(alignment: .leading) {
                    Text(viewModel.originalShape == .round ? "Diameter (in)" : "Length (in)")
                        .font(SCFont.caption)
                        .foregroundStyle(Color.scTextSecondary)
                    TextField("9", value: $viewModel.originalDim1, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                }

                if viewModel.needsOriginalDim2 {
                    VStack(alignment: .leading) {
                        Text("Width (in)")
                            .font(SCFont.caption)
                            .foregroundStyle(Color.scTextSecondary)
                        TextField("13", value: $viewModel.originalDim2, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.decimalPad)
                    }
                }
            }
        }
        .padding(SCSpace.md)
        .background(Color.scSurface)
        .cornerRadius(16)
    }

    private var newPanSection: some View {
        VStack(alignment: .leading, spacing: SCSpace.sm) {
            Text("New Pan")
                .font(SCFont.title2)
                .foregroundStyle(Color.scTextPrimary)

            Picker("Shape", selection: $viewModel.newShape) {
                ForEach(PanShape.allCases, id: \.self) { shape in
                    Text(shape.rawValue).tag(shape)
                }
            }
            .pickerStyle(.segmented)

            HStack {
                VStack(alignment: .leading) {
                    Text(viewModel.newShape == .round ? "Diameter (in)" : "Length (in)")
                        .font(SCFont.caption)
                        .foregroundStyle(Color.scTextSecondary)
                    TextField("8", value: $viewModel.newDim1, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                }

                if viewModel.needsNewDim2 {
                    VStack(alignment: .leading) {
                        Text("Width (in)")
                            .font(SCFont.caption)
                            .foregroundStyle(Color.scTextSecondary)
                        TextField("8", value: $viewModel.newDim2, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.decimalPad)
                    }
                }
            }
        }
        .padding(SCSpace.md)
        .background(Color.scSurface)
        .cornerRadius(16)
    }

    private var calculateButton: some View {
        Button(action: {
            if !purchaseService.isPremium {
                showPaywall = true
            } else {
                viewModel.calculate()
            }
        }) {
            Text("Calculate Scale Factor")
                .font(SCFont.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(SCSpace.md)
                .background(Color.scPrimary)
                .cornerRadius(12)
        }
    }

    private var resultSection: some View {
        Group {
            if viewModel.calculatedFactor != 1.0 {
                VStack(spacing: SCSpace.md) {
                    Text("Scale Factor")
                        .font(SCFont.headline)
                        .foregroundStyle(Color.scTextSecondary)

                    Text(String(format: "%.2fx", viewModel.calculatedFactor))
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(Color.scPrimary)

                    HStack(spacing: SCSpace.xl) {
                        VStack {
                            Text(String(format: "%.0f sq in", viewModel.originalArea))
                                .font(SCFont.headline)
                                .foregroundStyle(Color.scTextPrimary)
                            Text("Original")
                                .font(SCFont.caption)
                                .foregroundStyle(Color.scTextSecondary)
                        }
                        Image(systemName: "arrow.right")
                            .foregroundStyle(Color.scPrimary)
                        VStack {
                            Text(String(format: "%.0f sq in", viewModel.newArea))
                                .font(SCFont.headline)
                                .foregroundStyle(Color.scTextPrimary)
                            Text("New")
                                .font(SCFont.caption)
                                .foregroundStyle(Color.scTextSecondary)
                        }
                    }
                }
                .padding(SCSpace.lg)
                .background(Color.scSurface)
                .cornerRadius(16)
            }
        }
    }
}
