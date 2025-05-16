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
    
    func login(email: String, password: String, result: @escaping loginResult) {
        loginRepository.login(email: email, password: password) { networkResult in
            switch networkResult {
            case .success(let data):
                result(.success(data))
            case .failure(let error):
                result(.failure(error))
            }
        }
    }
}
