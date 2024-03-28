import Foundation

//MARK: Task1

// MARK: - Errors
enum NetworkError: Error {
    case wrongURL
    case noData
    case noInthernet(message: String)
    case decodingError
    case numberOfRequestIncreased
    case statusCode
}

struct PostCodes: Codable {
    let message, status: String
    let postOffice: [PostOffice]
    
    enum CodingKeys: String, CodingKey {
        case message = "Message"
        case status = "Status"
        case postOffice = "PostOffice"
    }
}

// MARK: - PostOffice
struct PostOffice: Codable {
    let name: String
    let description: String?
    let branchType: String
    let deliveryStatus: String
    let circle, district, division, region: String
    let state, country: String
    let pincode: String
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case description = "Description"
        case branchType = "BranchType"
        case deliveryStatus = "DeliveryStatus"
        case circle = "Circle"
        case district = "District"
        case division = "Division"
        case region = "Region"
        case state = "State"
        case country = "Country"
        case pincode = "Pincode"
    }
}

//
enum Link {
    case posts
    
    var url: URL {
        switch self {
        case .posts:
            return URL(string: "https://api.postalpincode.in/pincode/110001")!
        }
    }
}

final class NetworkManager {
    
    init() { }
    
    private let baseURL: String = "https://api.postalpincode.in/pincode/110001"
    private let session = URLSession.shared
    var posts = [PostOffice]()
    
    func fetchPosts(completion: @escaping(Result<[PostOffice], NetworkError>) -> Void) {
        
        print("try to fetch")
        
        let request = URLRequest(url: Link.posts.url)
        
        let task = session.dataTask(with: request) { (data, response, error) -> Void in
            if error != nil {
                print("Some error")
                completion(.failure(.noData))
            } else {
                guard let httpResponse = response as? HTTPURLResponse,
                      let data else { return }
                switch httpResponse.statusCode{
                case 200...300:
                    print(200)
                    do {
                        let result = try JSONDecoder().decode([PostCodes].self, from: data)
                        // print(String(data: data, encoding: .utf8))
                        guard let postOffices = result.first?.postOffice else { return }
                        completion(.success(postOffices))
                    } catch {
                        completion(.failure(.decodingError))
                    }
                case 429:
                    print(429)
                    completion(.failure(.numberOfRequestIncreased))
                default:
                    print("default")
                    completion(.failure(.statusCode))
                    
                }
            }
        }
        task.resume()
    }
}

let man = NetworkManager()
man.fetchPosts { result in
    switch result {
    case .success(let success):
        success.forEach {
            
            print( """
            POST:
            name: \($0.name),
            region: \($0.region),
            country: \($0.country),
            pincode: \($0.pincode)
            """)
        }
    case .failure(let failure):
        print(failure.localizedDescription)
    }
}

//MARK: Task2

//import CryptoKit
//
//struct APIResults: Decodable {
//    let code: Int
//    let status: String
//    let data: APICaracters
//}
//
//struct APICaracters: Decodable {
//    let results: [Caracter]
//}
//
//struct Caracter: Decodable {
//    let id: Int
//    let name: String
//    let description: String?
//    let modified: String
//}
//
//func MD5(string: String) -> String {
//    let hash = Insecure.MD5.hash(data: Data(string.utf8))
//    
//    return hash.map {
//        String(format: "%02hhx", $0)
//    }.joined()
//}
//
//final class NetworkManagerMarvel {
//    private enum URLData {
//        enum Paths: String {
//            case characters = "/v1/public/characters"
//            case comics = "/v1/public/comics"
//        }
//        static let scheme = "https"
//        static let host = "gateway.marvel.com"
//        static let port = ":443"
//        static let publicKey = "2956c87f8465a40e730ed3f0234917de"
//        static let privateKey = "ebb15b8cec73e8a4d4c76a1390b2d012df86fad8"
//    }
//    
//    private func createURL(paths: URLData.Paths, queryItems: [URLQueryItem]? = nil) -> URL? {
//        var components = URLComponents()
//        components.scheme = URLData.scheme
//        components.host = URLData.host
//        components.path = paths.rawValue
//        components.queryItems = queryItems
//        
//        return components.url
//    }
//    
//    func createRequest(url: URL?) -> URLRequest? {
//        guard let url else { return nil }
//        var request = URLRequest(url: url)
//        return request
//    }
//    
//    func getCaracters() {
//        let ts = String(Date().timeIntervalSince1970)
//        let hash = MD5(string: "\(ts)\(URLData.privateKey)\(URLData.publicKey)")
//        let fullURL = createURL(paths: .characters, queryItems: [URLQueryItem(name: "ts", value: ts), URLQueryItem(name: "apikey", value: URLData.publicKey), URLQueryItem(name: "hash", value: hash)])
//        
//        guard let request = createRequest(url: fullURL) else { return }
//        
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            guard error == nil else { return }
//            guard let responseObject = response as? HTTPURLResponse else { return }
//            guard responseObject.statusCode == 200 else {
//                print("statuscode = \(responseObject.statusCode)")
//                return }
//            guard let data = data else { return }
//            do {
//                let result = try JSONDecoder().decode(APIResults.self, from: data)
//                print(result.data.results.forEach{print("name: \($0.name)", "description: \($0.description ?? "") ")})
//            } catch {
//                print(error.localizedDescription)
//            }
//        }.resume()
//    }
//}
//
//let manager = NetworkManagerMarvel()
//manager.getCaracters()
//
//
//
