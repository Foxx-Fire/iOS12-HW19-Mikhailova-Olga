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


