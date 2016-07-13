//
//  Utilities.swift
//  ACC
//
//  Created by kai-hsiang, lien on 2016/7/11.
//  Copyright © 2016年 Hung-Yun Liao. All rights reserved.
//

import Foundation
import Accelerate

class Utilities {

    // exchange x and y;
}

struct Matrix {
    let rows: Int, columns: Int
    var grid: [Double]
    var shape: (Int, Int)
    
    init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        self.shape = (rows, columns)
        grid = Array(count: rows * columns, repeatedValue: 0.0)
    }
    func indexIsValid(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    subscript(row: Int, column: Int) -> Double {
        get {
            return grid[(row * columns) + column]
        }
        set {
            grid[(row * columns) + column] = newValue
        }
    }
    func negate(x: Matrix) -> Matrix {
        var results = x
        vDSP_vnegD(x.grid, 1, &(results.grid), 1, UInt(x.grid.count))
        return results
    }
    func add(x: Matrix, y: Matrix) -> Matrix {
        var results = x
        vDSP_vaddD(x.grid, 1, y.grid, 1, &(results.grid), 1, UInt(x.grid.count))
        return results
    }
    func mul(x: Matrix, y: Matrix) -> Matrix {
        var results = x
        vDSP_vmulD(x.grid, 1, y.grid, 1, &(results.grid), 1, vDSP_Length(x.grid.count))
        return results
    }
    func dot(x: Matrix, y: Matrix) -> Matrix {
        var results = x //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! size change
        vDSP_dotprD(x.grid, 1, y.grid, 1, &(results.grid), UInt(x.grid.count))
        return results
    }
    func transpose(x: Matrix) -> Matrix {
        var results = x
        vDSP_mtransD(x.grid, 1, &(results.grid), 1, vDSP_Length(results.rows), vDSP_Length(results.columns))
        return results
    }
    func inverse(x: Matrix) -> Matrix {
        var results = x
        /*
         dgetrf_(UnsafeMutablePointer<__CLPK_integer>, <#T##UnsafeMutablePointer<__CLPK_integer>#>, <#T##UnsafeMutablePointer<__CLPK_doublereal>#>, <#T##UnsafeMutablePointer<__CLPK_integer>#>, <#T##UnsafeMutablePointer<__CLPK_integer>#>, <#T##UnsafeMutablePointer<__CLPK_integer>#>)
         */
        return results
    }
    func invert(matrix : [Double]) -> [Double] {
        var inMatrix = matrix
        var N = __CLPK_integer(sqrt(Double(matrix.count)))
        var pivots = [__CLPK_integer](count: Int(N), repeatedValue: 0)
        var workspace = [Double](count: Int(N), repeatedValue: 0.0)
        var error : __CLPK_integer = 0
        dgetrf_(&N, &N, &inMatrix, &N, &pivots, &error)
        dgetri_(&N, &inMatrix, &N, &pivots, &workspace, &N, &error)
        return inMatrix
    }
    
    //inverse
}