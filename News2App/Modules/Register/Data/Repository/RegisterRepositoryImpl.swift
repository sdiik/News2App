//
//  RegisterRepositoryImpl.swift
//  NewsApp
//
//  Created by ahmad shiddiq on 23/04/25.
//

class RegisterRepositoryImpl: RegisterRepository {
    let authRepositoryProtocol: AuthServiceProtocol
    private let storage: CredentialsStorage
    
    init(
        authRepositoryProtocol: AuthServiceProtocol = AuthService(),
        storage: CredentialsStorage = CredentialsStorage()
    ) {
        self.authRepositoryProtocol = authRepositoryProtocol
        self.storage = storage
    }
    
    func register(email: String, password: String, result: @escaping registerResult) {
        authRepositoryProtocol.register(email: email, password: password) { networkResult in
            switch networkResult {
            case .success(let data):
                self.storage.save(data)
                result(.success(data))
            case .failure(let error):
                result(.failure(error))
            }
        }
    }
}
