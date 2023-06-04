//
//  deletethis.swift
//  ProjectH
//
//  Created by Shivam Rawat on 05/06/23.
//

import SwiftUI

struct MyObject {
    var array: [Int]
}

struct ContentView: View {
    @State var myObject = MyObject(array: [1, 2, 3])

    var body: some View {
        VStack {
            ForEach(myObject.array, id: \.self) { number in
                Text("\(number)")
            }
            Button("Update Array") {
                myObject.array.append(4)
            }
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
