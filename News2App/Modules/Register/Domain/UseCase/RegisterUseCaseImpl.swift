//
//  RegisterUseCaseImpl.swift
//  NewsApp
//
//  Created by ahmad shiddiq on 23/04/25.
//

class RegisterUseCaseImpl: RegisterUseCase {
    let registerRepository: RegisterRepository

    init(registerRepository: RegisterRepository = RegisterRepositoryImpl()) {
        self.registerRepository = registerRepository
    }

    func register(email: String, password: String, result: @escaping RegisterUseCaseResult) {
        registerRepository.register(email: email, password: password) { networkResult in
            switch networkResult {
            case let .success(data):
                result(.success(data))
            case let .failure(error):
                result(.failure(error))
            }
        }
    }
}
