//
//  KluchViewMosel.swift
//  Kluch
//
//  Created by Dosi Dimitrov on 14.02.24.
//

import Combine
import SwiftUI
import WalletConnectModal


class KluchViewModel : ObservableObject{
    
    var requiredNamespaces: [String: ProposalNamespace] = [:]
    let optionalNamespaces: [String: ProposalNamespace] = [
        "eip155": ProposalNamespace(
            chains: [
              
                Blockchain("eip155:11155111")!,  
            
               
            ],
            methods: [
                "eth_sendTransaction",
                "eth_getTransactionCount",
                "personal_sign"
               
            ], events: []
        )
    ]
    
               var publishers = [AnyCancellable]()
    var resiveData: ((String?, Error?) -> Void)?
    
    @Published var sendKluch : String = ""
    @Published var text      : String = ""
    @Published var isSendData : Bool = false
    private var cancellabes = Set<AnyCancellable>()
    
    @Published var name : String =  ""
    @Published var description : String = ""
    @Published var registerText : String = ""
    @Published var isConnect : Bool = false
    @Published  var transactionValue : String = "0x03"
    
    
    private    var session      : Session? {
                   didSet{
                       if session  != nil {
                           isConnect = true
                       }else{
                           isConnect = false
                       }
                   }
    }
    private     var account      : Account?
    @Published  var address      : String?
    @Published  var nonce        : String? {
        didSet{
            if nonce != nil {
                onSend()
                isNonce = false
              
            }
        }
    }
    @Published  var isNonce      : Bool = false
  //  @Published var status    = false
    @Published var showError = false
    @Published var errorMessage : String = ""
    
    
    
  public  init(projectId: String,
         name: String,
         description: String,
         url: String,
         icons: [String],
         supportedChainIds: [String: ProposalNamespace]) {
      
      self.requiredNamespaces = supportedChainIds
      
    
      Networking.configure(projectId: projectId, socketFactory: DefaultSocketFactory())

      
      let metaData = AppMetadata(
          name: name,
          description: description,
          url: url,
          icons: icons
      )
      
      WalletConnectModal.configure(projectId: projectId, metadata: metaData)
      configure(metaData: metaData)
      
        setupData()
        registration()
    }
    
    func configure(metaData: AppMetadata) {
        Sign.instance.sessionSettlePublisher
            .receive(on: DispatchQueue.main)
            .sink { [self] session in
                
                self.session      = session
                self.account      = session.accounts.first
                self.address      = session.accounts.first?.address
               print(">>>>>>>............")
            }
            .store(in: &publishers)
        
        Sign.instance.sessionResponsePublisher
            .receive(on: DispatchQueue.main)
            .sink { [self] response in
                switch response.result {
                case .response(let value):
                    
                    let valueString = try! value.get(String.self)
                    if isNonce {
                       
                        self.nonce = valueString
                        print("...\(nonce ?? ">>>")")
                    }else{
                           AlertPresenter.present(message: "Your hex \(valueString)", type: .success)
                    }
                    print("...Success \(value)")
                    
                case .error(let error):
                    print("D>>>:\(error)")
                }
            }.store(in: &publishers)
    }
    
    public func connectWithWallet() {
        Task {
            
            ActivityIndicatorManager.shared.start()
            
            WalletConnectModal.set(sessionParams: .init(
                requiredNamespaces: requiredNamespaces,
                optionalNamespaces: optionalNamespaces,
                sessionProperties: nil
            ))
            
            ActivityIndicatorManager.shared.stop()
            
            let _ = try await WalletConnectModal.instance.connect(topic: nil)!
        }
        
        DispatchQueue.main.async {
            WalletConnectModal.present()
        }
    }
    
    func disconnect() {
        self.address = nil
        self.session = nil
        self.account = nil
        
       if  session  != nil {
           Task { @MainActor in
               do {
                   try await Sign.instance.disconnect(topic: session!.topic)
                   self.address = nil
                   self.session = nil
                   self.account = nil

               } catch {
                   showError.toggle()
                   errorMessage = error.localizedDescription
               }
           }
       }
    }
    
    
    func sendAsync() async throws -> String {
        
        await nonceNumber()
        
        return try await withCheckedThrowingContinuation { [weak self] (continuation: CheckedContinuation<String, Error>) in

                self!.resiveData = { response, error in
                    if let response = response {
                        continuation.resume(returning: response)


                    } else if let error = error {
                        continuation.resume(throwing: error)

                    }
            
            }
            
          

        }
    }
    

    
    func nonceNumber() async  {
        guard let address else{ return }
      
        if session != nil {
          
            let method = "eth_getTransactionCount"
            let requestParams = AnyCodable([address, "latest"])
            let request = Request(topic: self.session!.topic,
                                  method: method,
                                  params: requestParams,
                                  chainId: Blockchain(session!.accounts.first!.blockchainIdentifier)!)
                             try? await Sign.instance.request(params: request)

        }

    }
    
    func openWallet() {
        
        self.isSendData = false
        if session != nil {
            let ses = self.session!.peer.redirect?.native!
            let string = "\(ses!)wc?requestSent"
               print("string: \(string)")
           let url = URL(string: string)
           DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
               UIApplication.shared.open(url!)
           }
        }
    }
    
    func onSend() {
        
        guard let nonce = self.nonce, let address = self.address else {
            print("no  >>>>>>>")
            return }
        print("yes  >>>>>>>")
        if session != nil {
            do{
     
                let txt = self.text  + (name == "" ? "name: unknown, " : "name: \(name) ")
                
              //  let txt = self.text
             
                let data = Data(txt.utf8)
                let hexString = data.map{ String(format:"%02x", $0) }.joined()
                
                let requestParams = try getRequest(address: address, nonce: nonce, value: txt)

                    let request =  Request(topic: self.session!.topic,
                                              method: "eth_sendTransaction" ,
                                              params: requestParams,
                                              chainId: Blockchain(self.session!.accounts.first!.blockchainIdentifier)!
                                              )
                print("request: \(request)")
                  Task{
                      do{
                          try await Sign.instance.request(params: request)
               
                          DispatchQueue.main.async { [weak self] in
                              self?.openWallet()
                              self?.nonce = nil
                             
                          }
                      }catch{}
                  }
            }catch{}
        }

    }

 //  func pr() {
 //      let hexString = "BA5E64C0DE"
 //      let binaryData = hexString.dataFromHexadecimalString()
 //      let base64String = binaryData?.base64EncodedStringWithOptions(nil)
 //  }

    
    /*
     MethodID: 0x131a068000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000005
     [0]:  0000000000000000000000000000000000000000000000000000000000000020
     [1]:  0000000000000000000000000000000000000000000000000000000000000005
     [2]:  446f737369000000000000000000000000000000000000000000000000000000
     */
    func smartString(text: String)  -> String{

        let data = Data(text.utf8)
        let hexString = data.map{ String(format:"%02x", $0) }.joined()
        
        let counts = 64 - hexString.count
        if counts > 0 {
                       let newString = hexString + String(repeating:  "0", count: counts)
                       return newString
        }else{
                              // error
                      return "6572726f72000000000000000000000000000000000000000000000000000000"
            print("error......................")
        }
    }
    
    func getRequest(address: String, nonce : String, value: String) throws -> AnyCodable {
        
        let textHex = smartString(text: value)
   
        let tx = Stub.Transaction(from : address,
                                  to   : "0xae3242e4d90217269FECbF80E3E239ef73694067",
                                  data : "0x131a068000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000005\(textHex)",
                                  gas  : "0x9218", // 0x9218
                                  gasPrice: "0x9184e72a000", // 0x9184e72a000
                                  value: "0x00",
                                  nonce: nonce)
        print("tx : \(tx)")
        return AnyCodable([tx])
    }
    
    // MARK: - Transaction Stub
    private enum Stub {
        struct Transaction: Codable {
            
            let from     : String
            let to       : String
            let data     : String
            let gas      : String
            let gasPrice : String
            let value    : String
            let nonce    : String
            
        }
    }
    
    
  private  func setupData(){
        
        $sendKluch
            .debounce(for: .seconds(1) , scheduler: DispatchQueue.main)
            .sink { [weak self] returneddata in
                
                if !returneddata.isEmpty {
                    print(">>>>>>>>\(returneddata)")
                    //+ (self!.name == "" ? "name: unknown, " : "name: \(self!.name), ")  + (self!.description == "" ? "description: unknown, " : "description: \(self!.description). ")
                    self?.text = returneddata + " Force, "
                    self?.sendKluch = ""
                    withAnimation(.linear(duration: 2.0)){
                        self?.isSendData = true
                    }
                  
                }

            }
            .store(in: &cancellabes)
        
    }
    private func registration(){
        
        $name
            .debounce(for: .seconds(0.4) , scheduler: DispatchQueue.main)
            .sink { returneddata in
              // if returneddata.count > 20 {
              //     UIApplication.shared.endEditing()
              // }
            }
            .store(in: &cancellabes)
        $description
            .debounce(for: .seconds(0.4) , scheduler: DispatchQueue.main)
            .sink { returneddata in
              //  if returneddata.count > 20 {
              //      UIApplication.shared.endEditing()
              //  }
            }
            .store(in: &cancellabes)
        
    }
    
    func clearText() {
                        self.text = ""
                        self.sendKluch = ""
    }
}
