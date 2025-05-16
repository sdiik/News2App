//
//  LoginUseCaseImpl.swift
//  NewsApp
//
//  Created by ahmad shiddiq on 23/04/25.
//

class LoginUseCaseImpl: LoginUseCase {
    let loginRepository: LoginRepository

    init(loginRepository: LoginRepository = LoginRepositoryImpl()) {
        self.loginRepository = loginRepository
    }

    func login(email: String, password: String, result: @escaping LoginResult) {
        loginRepository.login(email: email, password: password) { networkResult in
            switch networkResult {
            case let .success(data):
                result(.success(data))
            case let .failure(error):
                result(.failure(error))
            }
        }
    }
}
