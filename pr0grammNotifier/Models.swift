import Foundation

struct ItemFeed: Codable {
    let atEnd: Bool
    let atStart: Bool
    let error: String?
    let ts : Int
    let cache: String?
    let rt: Int
    let qc: Int
    let items:[Item]
}

struct Item: Codable {
    let id: Int
    let user: String?
    let image: String?
}

struct UpdateModel: Codable {
    let req_version: String
    let features: [String]
}
