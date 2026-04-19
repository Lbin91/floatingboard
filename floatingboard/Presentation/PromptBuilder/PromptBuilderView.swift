import SwiftUI

struct PromptBuilderView: View {
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Prompt Builder")
                        .font(.title2.weight(.semibold))
                    Text("Phase 1 skeleton")
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button("Close") {
                    onClose()
                }
            }

            Divider()

            Text("The project has been restructured away from the template app. Next steps will add taxonomy loading, prompt assembly, and the real builder UI.")
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
        .padding(24)
        .frame(minWidth: 560, minHeight: 320)
    }
}
