//
//  ContentView.swift
//  Kluch
//
//  Created by Dosi Dimitrov on 14.02.24.
//

import SwiftUI
import WalletConnectModal

struct ContentView: View {
    
    @State private var text = "The data obtained will be written to:"
    @State private var eteryum: [String] = "Ethereum".map{ String($0)}
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State private var couner = 0
    @State private var sendedText : String = ""
    @State private var isSend :  Bool = false

    @State private var projectTitle: String = ""
    
    @StateObject var kluchViewMosel = KluchViewModel(
        projectId: "2f82db81b8adc0310abf6a018ea491f0",
        name: "Kluch",
        description: "WalletConnect to App",
        url: " https://www.walletconnect.com",
        icons: [""],
        supportedChainIds: [
        "eip155": ProposalNamespace(
            chains: [ Blockchain("eip155:11155111")! ],
            methods: [
                   "eth_sendTransaction",
                   "eth_getTransactionCount",
                   "personal_sign"
            ], events: []
        )])
    @State private var screenWidth = UIScreen.main.bounds.width
    @State private var screenHeight =  UIScreen.main.bounds.height * 0.8
    @State private var SelectButton : Bool = true
   
   

    var body: some View {
        ZStack {
            Color.white.opacity(0.5)
                .ignoresSafeArea()
            VStack(spacing: 0) {

                VStack {
                    
                    if SelectButton {
                        Registration
                            .frame(width: screenWidth, height: screenHeight)
                            .transition(.move(edge: .trailing))
                    }
                    else{
                        WorkingArray
                            .frame(width: screenWidth, height: screenHeight)
                            .transition(.move(edge: .leading))
                    }
                }
              
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.linear(duration: 1)){
                            self.SelectButton = true
                        }
                    }) {
                        HStack{
                            Text("💿")
                            
                            Text("Register")
                        }
                        .padding()
                        .font(.system(size: 24))
                        .foregroundColor(Color("GreenLogo"))
                        
                    }
                    .background(
                        !self.SelectButton ?    RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 2) : nil
                    )
                    Spacer()
                    Button(action: {
                        withAnimation(.linear(duration: 1)){
                            self.SelectButton = false
                        }
                    }) {
                        HStack{
                            Text("🔧")
                            
                            Text("Work  ")
                        }
                        .padding()
                        .font(.system(size: 24))
                        .foregroundColor(Color("GreenLogo"))
                        
                       
                    }
                    .background(
                        self.SelectButton ?    RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 2) : nil
                    )
                    Spacer()
                }

            }
        }
}

  
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


extension ContentView {
    
    
    
    
    private var WorkingArray : some View {
        
        ZStack {
            Color.white.opacity(0.5)
                .ignoresSafeArea()
            VStack{
                Text(kluchViewMosel.nonce ?? "...")
                    .font(.system(size: 10))
                    .onAppear(){
                        print(";;;;;;;;;;")
                    }
                Spacer()
                logoTitle
                Spacer()
                if !self.kluchViewMosel.isSendData {
                    stackImage
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                }else{
                    stackText
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                }
                Spacer()
            }
        }
        .onChange(of:kluchViewMosel.text, perform: { kluch in
            print(">>>>>\(kluch)")
           
            self.kluchViewMosel.transactionValue = String(format: "%02X" ,  Int(kluch) ?? "0x01" )
                    self.projectTitle = kluch
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                if kluchViewMosel.sendKluch == "" && !projectTitle.isEmpty {
                  //  self.projectTitle = self.projectTitle +  (kluchViewMosel.name == "" ? "name: unknown, " : "name: \(kluchViewMosel.name), ")  + (kluchViewMosel.description == "" ? "description: unknown, " : "description: \(kluchViewMosel.description). ")
                   //  saveToEt()
                 //   Task{
                 //                 kluchViewMosel.isNonce = true
                 //         await   kluchViewMosel.nonceNumber()
                 //   }
                 
                }
            }
        })
        .onReceive(timer, perform: { _ in
            withAnimation(.spring()){
                let lastIndex = eteryum.count - 1
                if couner == lastIndex{
                    couner = 0
                }else{
                    couner += 1
                }
            }
        })
        
    }
    
    private var Registration : some View {
        ZStack {
            Color.white.opacity(0.5)
                .ignoresSafeArea()
            VStack{
                Image("BCRL")
                    .resizable()
                    .frame(width: screenWidth, height: 200)
                Section{
                    HStack(spacing: 0){
                        TextField("Name ... ", text: $kluchViewMosel.name )
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 5).stroke(Color("ArdaColor") ,style: StrokeStyle(lineWidth: 2)))
                            .padding()
                        Spacer()
                        
                        Button(action: {
                            UIApplication.shared.endEditing()
                            kluchViewMosel.name = ""
                        }) {
                            
                            Text(kluchViewMosel.name == "" ? "" :  "⌫")
                            
                                .font(.system(size: 32))
                                .foregroundColor(Color("GreenLogo"))
                        }
                        .frame(width: 40, height: 40, alignment: .leading)
                        .padding(.vertical, 15.0)
                    }

                    HStack(spacing: 0) {
                        TextField("Description ...", text: $kluchViewMosel.description)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 5).stroke(Color("ArdaColor") ,style: StrokeStyle(lineWidth: 2)))
                            .padding()
                        Spacer()
                        Button(action: {
                            UIApplication.shared.endEditing()
                            kluchViewMosel.description = ""
                        }) {
                            
                            Text(kluchViewMosel.description == "" ? "" :  "⌫")
                            
                                .font(.system(size: 32))
                                .foregroundColor(Color("GreenLogo"))
                        }
                        .frame(width: 40, height: 40, alignment: .leading)
                        .padding(.vertical, 15.0)
                    }
                    
                    Text("address: \(kluchViewMosel.address ?? "")")
                        .padding()
                       .font(.system(size: 12))
                       .frame(maxWidth: .infinity, alignment: .leading)

                    
                    Button {
                        
                        if kluchViewMosel.isConnect {
                                           kluchViewMosel.disconnect()
                        }else{
                                           kluchViewMosel.connectWithWallet()
                        }

                    } label: {
                        Text(kluchViewMosel.isConnect ? "Disconnect" : "Connect To Wallet")
                            .padding()
                            .foregroundColor(.white)
                            .background(RoundedRectangle(cornerRadius: 20).fill(kluchViewMosel.isConnect ?  Color.green : Color.red))
                    }
                    .padding(.vertical, 30)
                }
                Spacer()
            }
           
        }
    }
    
    
    private var logoTitle : some View {
        
        VStack{
            Text(text)
                .foregroundColor(Color("GreenLogo"))
            HStack{
                ForEach(eteryum.indices) { index in
                    Text(eteryum[index])
                        .font(.headline)
                        .fontWeight(.heavy)
                        .foregroundColor(Color("GreenLogo"))
                        .offset(y: couner == index ? 10 : 0)
                }
            }
            .offset(y: 10)
        }
    }
    
    private var  stackImage :  some View {
        
        ZStack(alignment: .bottom) {
            Image("kluch")
                .scaleEffect()
                .frame(width: UIScreen.main.bounds.width * 0.8)
            
            HStack(alignment: .bottom){
                TextField(" Waiting ...", text: $kluchViewMosel.sendKluch)
                    .padding(.vertical,6)
                    .background(Color.white)
                    .background(RoundedRectangle(cornerRadius: 1).stroke(Color("ArdaColor") ,style: StrokeStyle(lineWidth: 3)))
            }
            .frame( height: 70, alignment: .center)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray).padding(.top, 15))
            .padding(.horizontal)
            
                
        }
       .frame(width: UIScreen.main.bounds.width)
       
        .background( RoundedRectangle(cornerRadius: 10).fill(Color.gray).padding(.horizontal, 8))
    }
    
    private var  stackText :  some View {
        ZStack {
            HStack{
                VStack(spacing: 0){
                    Text("nonce:\(kluchViewMosel.nonce ?? "...")")
                        .font(.system(size: 8))
                   Text("The data is being send ....")
                        .foregroundColor(Color("GreenLogo"))
                        .font(.caption)
                        .multilineTextAlignment(.trailing)
                    VStack(spacing: 0){
                        Text(kluchViewMosel.text)
                        Text(kluchViewMosel.name == ""  ? " unknown " : kluchViewMosel.name)
                        Text(kluchViewMosel.description == "" ? " unknown " : kluchViewMosel.description)
                    }
                    .font(.system(size: 14))
                    .foregroundColor(Color("ArdaColor"))
                    .multilineTextAlignment(.leading)
              
                    Text("please wait ...\(kluchViewMosel.nonce ?? "")")
                            .foregroundColor(Color("GreenLogo"))
                            .font(.caption)
                            .multilineTextAlignment(.trailing)

                }
           
               Button(action: {
                   Task{
                     //  let text = kluchViewMosel.text + " " + kluchViewMosel.name + " " + kluchViewMosel.description
                                 kluchViewMosel.isNonce = true
                         await   kluchViewMosel.nonceNumber()
                   }
             
               }, label: {
                   Text("send")
                       .font(.system(size: 14))
                       .foregroundColor(Color("ArdaColor"))
               })
                if kluchViewMosel.isNonce {
                     ProgressView()
                         .scaleEffect(2)
                         .padding(.horizontal, 30)
                }

                
            }

        }
        .frame(width: UIScreen.main.bounds.width, height: 130)
        .background( RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 3)
                    .fill(Color.gray) .padding(.horizontal, 8))

    }
    

    
    private var addClear : some View {
        VStack{
            Text( kluchViewMosel.isSendData ? " The data\n \(kluchViewMosel.text) \nsend to Eteriyum " : "enter data ...." )
                .padding()
                .font(.system(size: 21))
                .foregroundColor(.red.opacity(0.8))
            
                .onChange(of:kluchViewMosel.text, perform: { kluch in
                    
                    print(">>>>>\(kluch)")

                            self.projectTitle = kluch
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        if kluchViewMosel.sendKluch == "" && !projectTitle.isEmpty {
                          //  saveToEt()
                            print(">>>>>>>>>>>>> \(projectTitle) >>>>>>>>>>>>>>>>>>")
                        }
                    }
                })
        }
    }
    


}


extension UIApplication {
    
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
