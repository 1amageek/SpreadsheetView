//
//  ContentView.swift
//  Spreadsheet
//
//  Created by nori on 2022/03/12.
//

import SwiftUI
import Spreadsheet

struct ContentView: View {

    @State var columns: Int = 4

    @State var rows: Int = 4

    var body: some View {

        VStack {

            Button("Add") {
                columns += 1
                rows += 1
            }

            Spreadsheet(columns, rows) { indexPath in
                Text("\(indexPath.row), \(indexPath.column)")
            }
            .frozon(columns: 2, rows: 2)
            .width { column in
                return 120
            }
            .height { row in
                if row <= 2 {
                    return 100
                }
                return 44
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
