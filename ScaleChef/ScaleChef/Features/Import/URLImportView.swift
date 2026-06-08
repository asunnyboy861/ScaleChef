import SwiftUI

struct URLImportView: View {
    let onImport: (ParsedRecipe) -> Void
    @State private var viewModel = URLImportViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: SCSpace.lg) {
                VStack(alignment: .leading, spacing: SCSpace.sm) {
                    Text("Recipe URL")
                        .font(SCFont.headline)
                        .foregroundStyle(Color.scTextPrimary)

                    TextField("https://example.com/recipe", text: $viewModel.urlText)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .keyboardType(.URL)
                        .font(SCFont.body)

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(SCFont.caption)
                            .foregroundStyle(Color.scError)
                    }
                }

                Button(action: {
                    Task { await viewModel.importRecipe() }
                }) {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        }
                        Text(viewModel.isLoading ? "Importing..." : "Import Recipe")
                            .font(SCFont.headline)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(SCSpace.md)
                    .background(viewModel.urlText.isEmpty ? Color.scPrimary.opacity(0.5) : Color.scPrimary)
                    .cornerRadius(12)
                }
                .disabled(viewModel.urlText.isEmpty || viewModel.isLoading)

                Spacer()

                VStack(alignment: .leading, spacing: SCSpace.sm) {
                    Text("Supported Sites")
                        .font(SCFont.headline)
                        .foregroundStyle(Color.scTextPrimary)
                    Text("Works with most recipe sites that use structured data (Schema.org). Results may vary for sites without structured recipe markup.")
                        .font(SCFont.caption)
                        .foregroundStyle(Color.scTextSecondary)
                }
            }
            .padding(SCSpace.md)
            .background(Color.scBackground)
            .navigationTitle("Import from URL")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onChange(of: viewModel.importedRecipe) { _, newValue in
                if let recipe = newValue {
                    dismiss()
                    onImport(recipe)
                }
            }
        }
    }
}
