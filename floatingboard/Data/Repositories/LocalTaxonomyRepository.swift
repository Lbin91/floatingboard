import Foundation

enum LocalTaxonomyRepositoryError: Error {
    case missingResource(String)
    case invalidTopicID(String)
}

struct LocalTaxonomyRepository: TaxonomyRepository {
    private let resourceURL: URL?
    private let bundle: Bundle

    init(resourceURL: URL? = nil, bundle: Bundle = .main) {
        self.resourceURL = resourceURL
        self.bundle = bundle
    }

    func loadTaxonomy() throws -> PromptTaxonomy {
        let url = try resourceURL ?? bundledTaxonomyURL()
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let dto = try decoder.decode(TaxonomyDTO.self, from: data)
        return try dto.toDomain()
    }

    private func bundledTaxonomyURL() throws -> URL {
        if let url = bundle.url(forResource: "coding", withExtension: "json") {
            return url
        }

        throw LocalTaxonomyRepositoryError.missingResource("coding.json")
    }
}
