//
//  Spreadsheet.swift
//  
//
//  Created by nori on 2022/03/11.
//

import SwiftUI
import SpreadsheetView

public struct Spreadsheet<Content>: View where Content: View {

    public var matrix: Matrix

    public var content: (IndexPath) -> Content

    public init(_ matrix: Matrix, @ViewBuilder content: @escaping (IndexPath) -> Content) {
        self.matrix = matrix
        self.content = content
    }

    public init(_ matrix: (numberOfRows: Int, numberOfColumns: Int), @ViewBuilder content: @escaping (IndexPath) -> Content) {
        self.matrix = Matrix(matrix.numberOfRows, matrix.numberOfColumns)
        self.content = content
    }

    public init(_ numberOfRows: Int, _ numberOfColumns: Int, @ViewBuilder content: @escaping (IndexPath) -> Content) {
        self.matrix = Matrix(numberOfRows, numberOfColumns)
        self.content = content
    }

    private var widthForColumn: (_ column: Int) -> CGFloat = { _ in 64 }
    private var heightForRow: (_ row: Int) -> CGFloat = { _ in 44 }
    private var frozenColumns: Int = 0
    private var frozenRows: Int = 0

    init(
        _ matrix: Matrix,
        frozenColumns: Int,
        frozenRows: Int,
        widthForColumn: @escaping (_ column: Int) -> CGFloat,
        heightForRow: @escaping (_ row: Int) -> CGFloat,
        @ViewBuilder content: @escaping (IndexPath) -> Content
    ) {
        self.matrix = matrix
        self.frozenColumns = frozenColumns
        self.frozenRows = frozenRows
        self.widthForColumn = widthForColumn
        self.heightForRow = heightForRow
        self.content = content
    }

    public var body: some View {
        Representable(matrix, frozenColumns: frozenColumns, frozenRows: frozenRows, widthForColumn: widthForColumn, heightForRow: heightForRow, content: content)
    }
}

public struct Matrix {

    public var numberOfRows: Int
    
    public var numberOfColumns: Int

    public init(_ numberOfRows: Int, _ numberOfColumns: Int) {
        self.numberOfRows = numberOfRows
        self.numberOfColumns = numberOfColumns
    }
}

extension Spreadsheet {

    public func cellFrame(width: CGFloat? = nil, height: CGFloat? = nil) -> Self {
        return .init(
            matrix,
            frozenColumns: frozenColumns,
            frozenRows: frozenRows,
            widthForColumn: { column in
                return width ?? widthForColumn(column)
            },
            heightForRow: { row in
                return height ?? heightForRow(row)
            },
            content: content)
    }

    public func width(_ widthForColumn: @escaping (_ column: Int) -> CGFloat) -> Self {
        return .init(
            matrix,
            frozenColumns: frozenColumns,
            frozenRows: frozenRows,
            widthForColumn: widthForColumn,
            heightForRow: { row in heightForRow(row) },
            content: content)
    }

    public func height(_ heightForRow: @escaping (_ row: Int) -> CGFloat) -> Self {
        return .init(
            matrix,
            frozenColumns: frozenColumns,
            frozenRows: frozenRows,
            widthForColumn: { column in widthForColumn(column) },
            heightForRow: heightForRow,
            content: content)
    }

    public func frozon(columns: Int? = nil, rows: Int? = nil) -> Self {
        let columns = columns ?? frozenColumns
        let rows = rows ?? frozenRows
        return .init(matrix,
                     frozenColumns: columns,
                     frozenRows: rows,
                     widthForColumn: widthForColumn,
                     heightForRow: heightForRow,
                     content: content)
    }
}

extension Spreadsheet {

#if os(iOS)
    internal typealias ViewRepresentable = UIViewRepresentable
    internal typealias ViewController = UIViewController
#else
    internal typealias ViewRepresentable = NSViewRepresentable
    internal typealias ViewController = NSViewController
#endif

    struct Representable: ViewRepresentable {

        var matrix: Matrix
        var frozenColumns: Int
        var frozenRows: Int
        var widthForColumn: (Int) -> CGFloat
        var heightForRow: (Int) -> CGFloat
        var content: (IndexPath) -> Content

        init(
            _ matrix: Matrix,
            frozenColumns: Int,
            frozenRows: Int,
            widthForColumn: @escaping (Int) -> CGFloat,
            heightForRow: @escaping (Int) -> CGFloat,
            content: @escaping (IndexPath) -> Content
        ) {
            self.matrix = matrix
            self.frozenColumns = frozenColumns
            self.frozenRows = frozenRows
            self.widthForColumn = widthForColumn
            self.heightForRow = heightForRow
            self.content = content
        }

        func makeCoordinator() -> Coordinator {
            Coordinator(matrix, frozenColumns: frozenColumns, frozenRows: frozenRows, widthForColumn: widthForColumn, heightForRow: heightForRow, content: content)
        }

#if os(iOS)
        func makeUIView(context: Context) -> UIView {
            context.coordinator.viewController.view
        }

        func updateUIView(_ rootView: UIView, context: Context) {
            context.coordinator.spreadsheetView.reloadData()
        }
#else
        func makeNSView(context: Context) -> NSView {
            context.coordinator.viewController.view
        }

        func updateNSView(_ rootView: NSView, context: Context) {
            context.coordinator.spreadsheetView.reloadData()
        }
#endif
    }

    class Coordinator: NSObject, SpreadsheetViewDataSource, SpreadsheetViewDelegate {

        var viewController: ViewController = ViewController()
        var spreadsheetView: SpreadsheetView = SpreadsheetView(frame: .zero)
        var matrix: Matrix
        var frozenColumns: Int
        var frozenRows: Int
        var widthForColumn: (Int) -> CGFloat
        var heightForRow: (Int) -> CGFloat
        var content: (IndexPath) -> Content

        init(_ matrix: Matrix,
             frozenColumns: Int,
             frozenRows: Int,
             widthForColumn: @escaping (Int) -> CGFloat,
             heightForRow: @escaping (Int) -> CGFloat,
             content: @escaping (IndexPath) -> Content) {
            self.matrix = matrix
            self.frozenColumns = frozenColumns
            self.frozenRows = frozenRows
            self.widthForColumn = widthForColumn
            self.heightForRow = heightForRow
            self.content = content
            super.init()
            self.viewController.view = spreadsheetView
            spreadsheetView.register(HostingCell<Content>.self, forCellWithReuseIdentifier: "HostingCell")
            spreadsheetView.delegate = self
            spreadsheetView.dataSource = self
        }

        func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "HostingCell", for: indexPath) as! HostingCell<Content>
            cell.parentViewController = viewController
            let contentView: Content = content(indexPath)
            cell.addContentView(contentView)
            return cell
        }

        func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
            return widthForColumn(column)
        }

        func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
            return heightForRow(row)
        }

        func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
            return matrix.numberOfColumns
        }

        func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
            return matrix.numberOfRows
        }

        func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
            return frozenColumns
        }

        func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
            return frozenRows
        }
    }
}

struct Spreadsheet_Previews: PreviewProvider {
    static var previews: some View {
        Spreadsheet(100, 100) { indexPath in
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
