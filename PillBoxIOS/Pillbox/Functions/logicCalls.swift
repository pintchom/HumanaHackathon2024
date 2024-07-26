//
//  logicCalls.swift
//  Pillbox
//
//  Created by Max Pintchouk on 7/26/24.
//

import Foundation

class Logic {
    static let shared = Logic()
    
    private init() {}
    
    func getUserData(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let url = URL(string: "http://127.0.0.1:5000/get-data") else {
            completion(.failure(NSError(domain: "InvalidURL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["userId": "1"]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: 0, userInfo: nil)))
                return
            }
            
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    completion(.success(jsonResult))
                } else {
                    completion(.failure(NSError(domain: "InvalidJSON", code: 0, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    func addMedication(name: String, dailySchedule: [String], dosage: String, instructions: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "http://127.0.0.1:5000/add-medication") else {
            completion(.failure(NSError(domain: "InvalidURL", code: 0, userInfo: nil)))
            return
        }
        
        let payload: [String: Any] = [
            "userId": "1",
            "name": name,
            "daily-schedule": dailySchedule,
            "dosage": dosage,
            "instructions": instructions
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            completion(.failure(NSError(domain: "JSONSerializationError", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "InvalidResponse", code: 0, userInfo: nil)))
                return
            }
            
            completion(.success(()))
        }.resume()
    }
    
    func resetSchedule(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let url = URL(string: "http://127.0.0.1:5000/reset-schedule") else {
            completion(.failure(NSError(domain: "InvalidURL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["userId": "1"]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: 0, userInfo: nil)))
                return
            }
            
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    completion(.success(jsonResult))
                } else {
                    completion(.failure(NSError(domain: "InvalidJSON", code: 0, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    func takeMed(index: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "http://127.0.0.1:5000/take-med") else {
            completion(.failure(NSError(domain: "InvalidURL", code: 0, userInfo: nil)))
            return
        }
        
        let payload: [String: Any] = [
            "userId": "1",
            "index": index
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            completion(.failure(NSError(domain: "JSONSerializationError", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "InvalidResponse", code: 0, userInfo: nil)))
                return
            }
            
            completion(.success(()))
        }.resume()
    }
    func requestRefill(name: String, dailySchedule: [String], dosage: String, instructions: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "http://127.0.0.1:5000/request-refill") else {
            completion(.failure(NSError(domain: "InvalidURL", code: 0, userInfo: nil)))
            return
        }
        
        let payload: [String: Any] = [
            "userId": "1",
            "name": name,
            "daily-schedule": dailySchedule,
            "dosage": dosage,
            "instructions": instructions
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            completion(.failure(NSError(domain: "JSONSerializationError", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "InvalidResponse", code: 0, userInfo: nil)))
                return
            }
            
            completion(.success(()))
        }.resume()
    }
}

