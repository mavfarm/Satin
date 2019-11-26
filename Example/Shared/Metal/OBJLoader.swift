//
//  OBJGeometry.swift
//  Example iOS
//
//  Created by Colin Duffy on 10/21/19.
//  Copyright © 2019 Reza Ali. All rights reserved.
//

import Foundation
import Satin
import Metal
import simd
import SceneKit

struct VertexIndex {
    public var vertex:Int
    public var texCoord:Int
    public var normal:Int
}

struct VertexFace {
    public var vertexA: VertexIndex
    public var vertexB: VertexIndex
    public var vertexC: VertexIndex
}

/**
 * Parses an OBJ file
 *
 * TODO:
 * - Material support (mtl loading/reading)
 */
open class OBJLoader: Geometry {
    
    private var scanner: Scanner = Scanner()
    
    /// Markers
    private let commentMarker = "#"
    private let vertexMarker = "v"
    private let normalMarker = "vn"
    private let textureCoordMarker = "vt"
    private let faceMarker = "f"
    private let objectMarker = "o"
    private let groupMarker = "g"
    
    public init(path:String) {
        super.init()
        
        guard let url = Bundle.main.url(forResource: path, withExtension: "obj") else {
            fatalError("couldnt find model: \(path).obj")
        }
        
        /// Read file
        do {
            let file = try String(contentsOf: url, encoding: .utf8)
            
            scanner = Scanner(string: file)
            scanner.charactersToBeSkipped = .whitespaces
            
            self.read()
        } catch {
            print("Could not read file:", path)
        }
    }
    
    private func read() {
        print("Begin reading...")
        
        var vertices: [simd_float4] = []
        var normals: [simd_float3] = []
        var texCoords: [simd_float2] = []
        var faces: [VertexFace] = []
        
        do {
            while dataAvailable {
                let marker = readMarker()
                
                /// Next Line
                guard let m = marker, m.count > 0 else {
                    moveToNextLine()
                    continue
                }
                
                /// Comments
                if isComment(marker: m) {
                    moveToNextLine()
                    continue
                }
                
                /// Vertex
                if isVertex(marker: m) {
                    let line = readLine() ?? ""
                    let lines = line.split(separator: " ")
                    let x = Float( lines[0] ) ?? 0.0
                    let y = Float( lines[1] ) ?? 0.0
                    let z = Float( lines[2] ) ?? 0.0
                    let vertice = SIMD4<Float>(x, y, z, 1.0)
                    vertices.append(vertice)
                    
                    moveToNextLine()
                    continue
                }
                
                /// Normals
                if isNormal(marker: m) {
                    let line = readLine() ?? ""
                    let lines = line.split(separator: " ")
                    let x = Float( lines[0] ) ?? 0.0
                    let y = Float( lines[1] ) ?? 0.0
                    let z = Float( lines[2] ) ?? 0.0
                    let normal = SIMD3<Float>(x, y, z)
                    normals.append(normal)
                    
                    moveToNextLine()
                    continue
                }
                
                /// UVs
                if isTextureCoord(marker: m) {
                    let line = readLine() ?? ""
                    let lines = line.split(separator: " ")
                    let x = Float( lines[0] ) ?? 0.0
                    let y = Float( lines[1] ) ?? 0.0
                    let uv = SIMD2<Float>(x, y)
                    texCoords.append(uv)
                    
                    moveToNextLine()
                    continue
                }
                
                /// Object
                if isObject(marker: m) {
                    print("> Object:", readLine() ?? "nothing")
                    
                    moveToNextLine()
                    continue
                }
                
                /// Groups
                if isGroup(marker: m) {
                    print("> Group:", readString())
                    
                    moveToNextLine()
                    continue
                }
                
                /// Face
                if isFace(marker: m) {
                    let line = (readLine() ?? "").replacingOccurrences(of: " ", with: "/")
                    let lines = line.split(separator: "/")
                    /// v1/vt1/vn1 v2/vt2/vn2 v3/vt3/vn3
                    let line1 = (Int( String(lines[0]) ) ?? 100) /// v1
                    let line2 = (Int( String(lines[1]) ) ?? 200) /// vt1
                    let line3 = (Int( String(lines[2]) ) ?? 300) /// vn1
                    let line4 = (Int( String(lines[3]) ) ?? 400) /// v2
                    let line5 = (Int( String(lines[4]) ) ?? 500) /// vt2
                    let line6 = (Int( String(lines[5]) ) ?? 600) /// vn2
                    let line7 = (Int( String(lines[6]) ) ?? 700) /// v3
                    let line8 = (Int( String(lines[7]) ) ?? 800) /// vt3
                    let line9 = (Int( String(lines[8]) ) ?? 900) /// vn3
//                    print(line1, line2, line3, line4, line5, line6, line7, line8, line9)
                    
                    faces.append(
                        VertexFace(
                            vertexA: VertexIndex(
                                vertex: line1,
                                texCoord: line2,
                                normal: line3
                            ),
                            vertexB: VertexIndex(
                                vertex: line4,
                                texCoord: line5,
                                normal: line6
                            ),
                            vertexC: VertexIndex(
                                vertex: line7,
                                texCoord: line8,
                                normal: line9
                            )
                        )
                    )
                    
                    moveToNextLine()
                    continue
                }
                
                // Material Lib
                
                // Use Material
                
                moveToNextLine()
            }
        } catch {
            print("Could not read OBJ")
        }
        
        let totalVerts = vertices.count
//        let totalNormals = normals.count
        
        for _ in 0..<totalVerts {
            vertexData.append(Vertex())
        }
        
//        for i in 0..<faces.count {
//            vertexData.append(Vertex())
//        }
        
//        print("Building faces", vertexData.count)
//        print("vertices", totalVerts)
//        print("normals", totalNormals)
//        print("texCoords", texCoords.count)
//        print("faces", faces.count)
//        print(vertices)
//        print(normals)
//        print(texCoords)
//        print(faces)
        
        for i in 0..<faces.count {
            /// v1/vt1/vn1 v2/vt2/vn2 v3/vt3/vn3
            let face = faces[i]
            
            let a = face.vertexA.vertex
            let b = face.vertexB.vertex
            let c = face.vertexC.vertex
            let ua = face.vertexA.texCoord
            let ub = face.vertexB.texCoord
            let uc = face.vertexC.texCoord
            let na = face.vertexA.normal
            let nb = face.vertexB.normal
            let nc = face.vertexC.normal
            
            /// Indices
            let ia = parseVertexIndex(value: a, len: vertices.count)
            let ib = parseVertexIndex(value: b, len: vertices.count)
            let ic = parseVertexIndex(value: c, len: vertices.count)
            let iua = parseUVIndex(value: ua, len: texCoords.count)
            let iub = parseUVIndex(value: ub, len: texCoords.count)
            let iuc = parseUVIndex(value: uc, len: texCoords.count)
            let ina = parseNormalIndex(value: na, len: normals.count)
            let inb = na == nb ? ia : parseNormalIndex(value: nb, len: normals.count)
            let inc = na == nc ? ia : parseNormalIndex(value: nc, len: normals.count)
            
//            print(">>>", a, b, c, ua, ub, uc, na, nb, nc, "new:", ia, ib, ic, iua, iub, iuc, ina, inb, inc)
//            print(
//                ">>> totalVerts:", totalVerts, ":", ia, ib, ic,
//                "texCoords:", texCoords.count, ":", iua, iub, iuc,
//                "normals", totalNormals, ":", ina, inb, inc
//            )
            
            /// Position
            vertexData[ia].position = vertices[ia]
            vertexData[ib].position = vertices[ib]
            vertexData[ic].position = vertices[ic]

            /// UVs
            vertexData[ia].uv = texCoords[iua]
            vertexData[ib].uv = texCoords[iub]
            vertexData[ic].uv = texCoords[iuc]

            /// Normals
            vertexData[ia].normal = normals[ina]
            vertexData[ib].normal = normals[inb]
            vertexData[ic].normal = normals[inc]

            /// Vertex indices
            indexData.append(UInt32(ia))
            indexData.append(UInt32(ib))
            indexData.append(UInt32(ic))
        }
        
        print("Complete")
    }
    
    private func parseVertexIndex(value:Int, len:Int) -> Int {
//        return ( value >= 0 ? value - 1 : value + len / 3 ) * 3;
        return ( value >= 0 ? value - 1 : value + len / 3 );
    }
    
    private func parseUVIndex(value:Int, len:Int) -> Int {
//        return ( value >= 0 ? value - 1 : value + len / 2 ) * 2;
        return ( value >= 0 ? value - 1 : value + len / 2 );
    }
    
    private func parseNormalIndex(value:Int, len:Int) -> Int {
//        return ( value >= 0 ? value - 1 : value + len / 3 ) * 3;
        return ( value >= 0 ? value - 1 : value + len / 3 );
    }
    
    private func moveToNextLine() {
        scanner.scanUpToCharacters(from: .newlines)
        scanner.scanCharacters(from: .whitespacesAndNewlines)
    }
    
    private func readMarker() -> String? {
        return scanner.scanUpToCharacters(from: .whitespaces)
    }
    
    private func readLine() -> String? {
        return scanner.scanUpToCharacters(from: .newlines)
    }
    
    /// Casting
    
    private func readString() -> String {
        return scanner.scanUpToCharacters(from: .whitespacesAndNewlines)!
    }
    
    /// Helpers
    
    private func isComment(marker: String) -> Bool {
        return marker == commentMarker
    }

    private func isVertex(marker: String) -> Bool {
        return marker.count == 1 && marker == vertexMarker
    }

    private func isNormal(marker: String) -> Bool {
        return marker.count == 2 && marker == normalMarker
    }

    private func isTextureCoord(marker: String) -> Bool {
        return marker.count == 2 && marker == textureCoordMarker
    }

    private func isObject(marker: String) -> Bool {
        return marker.count == 1 && marker == objectMarker
    }

    private func isGroup(marker: String) -> Bool {
        return marker.count == 1 && marker == groupMarker
    }

    private func isFace(marker: String) -> Bool {
        return marker.count == 1 && marker == faceMarker
    }
    
    /// Getters / Setters
    
    var dataAvailable: Bool {
        get {
            return false == scanner.isAtEnd
        }
    }
    
}
