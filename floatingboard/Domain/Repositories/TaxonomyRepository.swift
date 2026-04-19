import Foundation

protocol TaxonomyRepository {
    func loadTaxonomy() throws -> PromptTaxonomy
}
