import Foundation

struct LikeHateService {
    static let baseURL = "https://api.mapping.kro.kr/api/v2/"
    
    static func likePost(id: Int, accessToken: String, completion: @escaping (Result<Void, Error>) -> Void) {
        sendRequest(endpoint: "memo/like/\(id)", accessToken: accessToken, completion: completion)
    }

    static func hatePost(id: Int, accessToken: String, completion: @escaping (Result<Void, Error>) -> Void) {
        sendRequest(endpoint: "memo/hate/\(id)", accessToken: accessToken, completion: completion)
    }
    
    static func likeComment(id: Int, accessToken: String, completion: @escaping (Result<Void, Error>) -> Void) {
        sendRequest(endpoint: "comment/like/\(id)", accessToken: accessToken, completion: completion)
    }
    
    private static func sendRequest(endpoint: String, accessToken: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("*/*", forHTTPHeaderField: "accept")
        
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            completion(.success(()))
        }
        
        task.resume() // 생성한 작업 시작
    }
}
