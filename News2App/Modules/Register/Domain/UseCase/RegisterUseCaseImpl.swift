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
    
    func register(email: String, password: String, result: @escaping registerUseCaseResult) {
        registerRepository.register(email: email, password: password) { networkResult in
            switch networkResult {
            case .success(let data):
                result(.success(data))
            case .failure(let error):
                result(.failure(error))
            }
        }
    }
}
