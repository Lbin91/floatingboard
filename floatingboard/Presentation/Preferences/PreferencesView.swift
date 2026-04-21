import SwiftUI

struct PreferencesView: View {
    private let keychainRepository: KeychainRepository

    init(keychainRepository: KeychainRepository) {
        self.keychainRepository = keychainRepository
    }

    var body: some View {
        TabView {
            VStack(alignment: .leading, spacing: 12) {
                Text("일반 설정")
                    .font(.title2.weight(.semibold))
                Text("일반 설정은 추후 구현 예정입니다.")
                    .foregroundStyle(.secondary)
            }
            .padding(24)
            .frame(minWidth: 420, minHeight: 220)
            .tabItem {
                Label("일반", systemImage: "gearshape")
            }

            AISettingsView(keychainRepository: keychainRepository)
                .tabItem {
                    Label("AI", systemImage: "brain")
                }

            VStack(alignment: .leading, spacing: 12) {
                Text("참고 문서 설정")
                    .font(.title2.weight(.semibold))
                Text("참고 문서 설정은 Phase 4에서 구현 예정입니다.")
                    .foregroundStyle(.secondary)
            }
            .padding(24)
            .frame(minWidth: 420, minHeight: 220)
            .tabItem {
                Label("문서", systemImage: "doc.text")
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("단축키 설정")
                    .font(.title2.weight(.semibold))
                Text("단축키 설정은 추후 구현 예정입니다.")
                    .foregroundStyle(.secondary)
            }
            .padding(24)
            .frame(minWidth: 420, minHeight: 220)
            .tabItem {
                Label("단축키", systemImage: "keyboard")
            }
        }
        .frame(width: 600, height: 500)
        .tabViewStyle(.automatic)
    }
}
