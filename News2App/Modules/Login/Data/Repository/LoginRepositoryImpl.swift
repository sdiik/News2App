//
//  LoginRepositoryImpl.swift
//  NewsApp
//
//  Created by ahmad shiddiq on 23/04/25.
//

class LoginRepositoryImpl: LoginRepository {
    let authRepositoryProtocol: AuthServiceProtocol
    private let storage: CredentialsStorage

    init(
        authRepositoryProtocol: AuthServiceProtocol = AuthService(),
        storage: CredentialsStorage = CredentialsStorage()
    ) {
        self.authRepositoryProtocol = authRepositoryProtocol
        self.storage = storage
    }

    func login(email: String, password: String, result: @escaping LoginResult) {
        authRepositoryProtocol.login(email: email, password: password) { networkResult in
            switch networkResult {
            case let .success(data):
                self.storage.save(data)
                result(.success(data))
            case let .failure(error):
                result(.failure(error))
            }
        }
    }
}
