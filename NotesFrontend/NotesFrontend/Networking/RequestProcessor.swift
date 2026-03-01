//
//  RequestProcessor.swift
//  NotesFrontend
//
//  Created by Maksim Polovinkin on 01/03/2026.
//

import SwiftyJSON
import Foundation

protocol IRequestProcessor {
    associatedtype ResponceModel: JSONParsable
    func execute(request: URLRequest, completion: @escaping (Result<ResponceModel, NSError>) -> Void)
}

final class RequestProcessor<ResponceModel: JSONParsable>: IRequestProcessor {

    // MARK: - IRequestProcessor

    func execute(request: URLRequest, completion: @escaping (Result<ResponceModel, NSError>) -> Void) {
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error as NSError? {
                completion(.failure(error))
                return
            }

            guard let data else {
                completion(.failure(.init(domain: "", code: 1)))
                return
            }

            do {
                let json = try JSON(data: data)
                let model = ResponceModel.from(json)

                if let model {
                    completion(.success(model))
                } else {
                    completion(.failure(.init(domain: "", code: 1)))
                }
            } catch {
                completion(.failure(error as NSError))
            }
        }.resume()
    }
}

