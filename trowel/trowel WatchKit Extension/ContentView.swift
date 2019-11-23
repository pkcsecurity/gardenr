//
//  ContentView.swift
//  trowel WatchKit Extension
//
//  Created by Nate Hatcher on 11/22/19.
//  Copyright © 2019 PKC. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        
        // prepare json data
        let json: [String: Any] = [ "authenticate": ["userid": "kylecbrodie@gmail.com","brand-s": "N","language-s": "en_US","password": "hDs$m]+Lku3D3oN2","country": "US"]]

        let jsonData = try? JSONSerialization.data(withJSONObject: json)

        // create post request
        let url = URL(string: "https://icm.infinitiusa.com/NissanLeafProd/rest/auth/authenticationForAAS")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // insert json data to the request
        request.httpBody = jsonData
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("f950a00e-73a5-11e7-8cf7-a6006ad3dba0", forHTTPHeaderField: "API-Key")
        
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                //print(responseJSON) //All Output
                print("yeah")
                for dic in responseJSON{
                    if (dic.key == "vehicles") {
                        let a = dic.value as! NSArray
                        
                        let b = a[0] as! NSDictionary
                        
                        print(b["extcolor"]!)
                        
                    }
                }
            }
        }

        task.resume()
        
        
        let number = arc4random_uniform(7)
        return Text("Hello: \(number)")
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

