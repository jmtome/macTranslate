//
//  Model.swift
//  BarTranslate
//
//  Created by Juan Manuel Tome on 24/07/2020.
//  Copyright © 2020 Juan Manuel Tome. All rights reserved.
//

import Foundation

protocol ModelDelegate {
    func dataFetched(_ data: Translation?)
}

struct Constants {
    
}

class Model {
    
    let headers = [
        "x-rapidapi-host": "google-translate1.p.rapidapi.com",
        "x-rapidapi-key": Constants.API_KEY1,
        "accept-encoding": "application/gzip",
        "content-type": "application/x-www-form-urlencoded"
    ]
    
    var request: String?
    var translation: String?
    var from: Language?
    var to: Language?
    
    let jsonData = """
    {
    "data": {
        "translations": [
            {
                "translatedText": "¡Hola Mundo!"
            }
        ]
    }
    }
    """.data(using: .utf8)
    
    var delegate: ModelDelegate?
    
    func translate(query: String, from: Language, to: Language, completion: ((String) -> ())? = nil) {
        
        print(from.rawValue)
        
        let url = URL(string: "https://google-translate1.p.rapidapi.com/language/translate/v2")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(Constants.API_KEY1, forHTTPHeaderField: "x-rapidapi-key")
        
        request.httpMethod = "POST"
//        let parameters: [String: Any] = [
//            "target": "es",
//            "source": "en",
//            "q": "Hello, World"
//        ]
        let parameters: [String: Any] = [
            "target": to.rawValue,
            "source": from.rawValue,
            "q": query
        ]
        request.httpBody = parameters.percentEncoded()
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {                                              // check for fundamental networking error
                    print("error", error ?? "Unknown error")
                    return
            }
            
            guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")

                self.delegate?.dataFetched(nil)
                return
            }
            
            
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
            
            //completion(responseString!)
            
            let decoder = JSONDecoder()
            
            do {
                let response = try decoder.decode(Response.self, from: data)
                if let translations = response.data?.translations {
                    let translation = translations[0]
                    DispatchQueue.main.async {
                        self.delegate?.dataFetched(translation)
                    }
                }
            } catch {
                print("some error")
            }
        }
        
        task.resume()
        
        
        
        //to test with jeyzzon
        //        let decoder = JSONDecoder()
        //        do {
        //            let response = try decoder.decode(Response.self, from: jsonData!)
        //
        //            let text = response.data?.translations![0].translatedText
        //            print(text!)
        //            if let translation = response.data?.translations?[0] {
        //                self.delegate?.dataFetched(translation)
        //            }
        //        } catch {
        //            print("some error")
        //        }
        
    }
    
}



extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}




class Translation: Decodable {
    var translatedText: String?
    
    enum CodingKeys: String, CodingKey {
        case translatedText = "translatedText"
    }
    
    required init(from decoder: Decoder) throws {
        
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.translatedText = try container.decode(String.self, forKey: .translatedText)
        } catch let error {
            print(error)
        }
    }
    
}

class Translations: Decodable {
    var translations: [Translation]?
    
    
    enum CodingKeys: String, CodingKey {
        case translations = "translations"
    }
    
    required init(from decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.translations = try container.decode([Translation].self, forKey: .translations)
        } catch let error {
            print(error)
        }
    }
}

class Response: Decodable {
    
    var data: Translations?
    
    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
    
    required init(from decoder: Decoder) throws {
        
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.data = try container.decode(Translations.self, forKey: .data)
        } catch let error {
            print(error)
        }
        
    }
}


//{
//    "data":   {
//                      "translations": [
//                           {
//                              "translatedText": "¡Hola Mundo!"
//                           }
//                      ]
//    }
//}
