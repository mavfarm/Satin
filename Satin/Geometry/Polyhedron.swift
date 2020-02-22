//
//  Polyhedron.swift
//  Satin
//
//  Created by Colin Duffy on 2/21/20.
//

import simd

open class Polyhedron: Geometry {
    
    private var originalVertices: [simd_float4]!
    
    public init(_ vertices: [simd_float4], _ indices: [UInt32], _ radius: Float = 1, _ detail: Int = 0) {
        super.init()
        
        self.originalVertices = vertices
        self.indexData = indices
        
        // the subdivision creates the vertex buffer data
        subdivide(detail)
        
        /// No-longer needed, clear reference
        self.originalVertices = []
        
        // all vertices should lie on a conceptual sphere with a given radius
        if radius != 1 {
            applyRadius(radius)
        }

        // finally, create the uv data
        generateUVs()

        if detail == 0 {
            computeVertexNormals() // flat normals
        } else {
            normalizeNormals() // smooth normals
        }
    }
    
    // MARK: - Helper functions
    
    private func subdivide(_ detail: Int) {
        let total = (self.indexData.count / 3) - 1
        var i = 0
        for index in 0...total {
            let ia = i + 0
            let ib = i + 1
            let ic = i + 2
            
            let indexA = Int(self.indexData[ia])
            let indexB = Int(self.indexData[ib])
            let indexC = Int(self.indexData[ic])
            
            let vertexA = self.originalVertices[indexA]
            let vertexB = self.originalVertices[indexB]
            let vertexC = self.originalVertices[indexC]
            
            subdivideFace(vertexA, vertexB, vertexC, detail)
            
            i += 3
        }
    }
    
    private func subdivideFace(_ vertexA: simd_float4, _ vertexB: simd_float4, _ vertexC: simd_float4, _ detail: Int ) {
        let cols: Int = Int( pow(2.0, Float(detail)) )
        
        // we use this multidimensional array as a data structure for creating the subdivision
        var items: [[simd_float4]] = []
        
        // construct all of the vertices for this subdivision
        for i in 0...cols {
            var list: [simd_float4] = []
            
            let progress = Float(i) / Float(cols)
            let aj = simd_make_float4(vertexA).lerp(vertexC, progress)
            let bj = simd_make_float4(vertexB).lerp(vertexC, progress)
            
            let rows = cols - i
            for j in 0...rows {
                if j == 0 && i == cols {
                    list.append(aj)
                } else {
                    let rowProgress: Float = Float(j) / Float(rows)
                    list.append(simd_make_float4(aj).lerp(bj, rowProgress))
                }
            }
            
            items.append(list)
        }
        
        // construct all of the faces
        for i in 0...cols - 1 {
            let limit = 2 * ( cols - i ) - 2
            for j in 0...limit {
                let k: Int = Int(floor(Float(j) / 2.0))
                
                if j % 2 == 0 {
                    pushVertex( items[ i ][ k + 1 ] )
                    pushVertex( items[ i + 1 ][ k ] )
                    pushVertex( items[ i ][ k ] )
                } else {
                    pushVertex( items[ i ][ k + 1 ] )
                    pushVertex( items[ i + 1 ][ k + 1 ] )
                    pushVertex( items[ i + 1 ][ k ] )
                }
            }
        }
    }
    
    private func applyRadius(_ radius: Float) {
        let total = vertexData.count - 1
        for index in 0...total {
            var vertex = vertexData[index].position
            vertex = simd_make_float4(normalize(vertex.xyz()) * radius, 1.0)
            
            // replace previous value
            vertexData[index].position = vertex
        }
    }
    
    // MARK: - UVs
    
    private func generateUVs() {
        let total = self.vertexData.count - 1
        for index in 0...total {
            let vertex = self.vertexData[index].position
            let texU = azimuth(vertex) / 2.0 / Float.pi + 0.5
            let texV = inclination(vertex) / Float.pi + 0.5
            self.vertexData[index].uv = simd_make_float2(texU, 1.0 - texV)
        }
        
        correctUVs()
        correctSeam()
    }
    
    private func correctUVs() {
        let total = self.vertexData.count - 3
        for index in 0...total {
            let posA = self.vertexData[index + 0].position
            let posB = self.vertexData[index + 1].position
            let posC = self.vertexData[index + 2].position
            
            let uvA = self.vertexData[index + 0].uv
            let uvB = self.vertexData[index + 1].uv
            let uvC = self.vertexData[index + 2].uv
            
            let centroid = simd_make_float4(
                (posA.x + posB.x + posC.x) / 3.0,
                (posA.y + posB.y + posC.y) / 3.0,
                (posA.z + posB.z + posC.z) / 3.0,
                1
            )
            
            let azi = azimuth(centroid)
            
            correctUV(uvA, index + 0, posA, azi)
            correctUV(uvB, index + 1, posB, azi)
            correctUV(uvC, index + 2, posC, azi)
        }
    }
    
    private func correctUV(_ uv: simd_float2, _ stride: Int, _ vector: simd_float4, _ azimuth: Float) {
        if azimuth < 0 && uv.x == 1 {
            self.vertexData[stride].uv.x = uv.x - 1.0
        }

        if vector.x == 0 && vector.z == 0 {
            self.vertexData[stride].uv.x = azimuth / 2.0 / Float.pi + 0.5
        }

    }
    
    private func correctSeam() {
        var offset = 0
        let total = (self.vertexData.count / 3) - 1
        for _ in 0...total {
            let uvA = self.vertexData[offset + 0].uv.x
            let uvB = self.vertexData[offset + 1].uv.x
            let uvC = self.vertexData[offset + 2].uv.x
            
            let maxV = max(max(uvA, uvB), uvC)
            let minV = min(min(uvA, uvB), uvC)
            
            if maxV > 0.9 && minV < 0.1 {
                if uvA < 0.2 {
                    self.vertexData[offset + 0].uv.x += 1
                }
                
                if uvB < 0.2 {
                    self.vertexData[offset + 1].uv.x += 1
                }
                
                if uvC < 0.2 {
                    self.vertexData[offset + 2].uv.x += 1
                }
            }
            
            offset += 3
        }
    }
    
    // MARK: - Utils
    
    private func pushVertex(_ position: simd_float4) {
        vertexData.append(
            Vertex(
                position,
                simd_make_float2(0, 0),
                simd_make_float3(0, 0, 1)
            )
        )
    }
    
    private func computeVertexNormals() {
        let total = (self.indexData.count - 1) / 3
        var i = 0
        for index in 0...total {
            let ia = i + 0
            let ib = i + 1
            let ic = i + 2
            
            let vA = Int(self.indexData[ia]) * 3
            let vB = Int(self.indexData[ib]) * 3
            let vC = Int(self.indexData[ic]) * 3
            
            let pA = self.vertexData[vA].position.xyz()
            let pB = self.vertexData[vB].position.xyz()
            let pC = self.vertexData[vC].position.xyz()
            
            var cb = pC - pB
            let ab = pA - pB
            cb = simd_cross(cb, ab)
            
            self.vertexData[vA].normal += cb
            self.vertexData[vB].normal += cb
            self.vertexData[vC].normal += cb
            
            i += 3
        }
        
        normalizeNormals()
    }
    
    private func normalizeNormals() {
        let total = self.vertexData.count - 1
        for index in 0...total {
            let original = self.vertexData[index].normal
            let normalized = normalize(original)
            self.vertexData[index].normal = normalized
        }
    }
    
    // MARK: - Math
    
    /// Angle around the Y axis, counter-clockwise when looking from above
    private func azimuth(_ vector: simd_float4) -> Float {
        return atan2f(vector.z, -vector.x)
    }
    
    /// Angle above the XZ plane
    private func inclination(_ vector: simd_float4) -> Float {
        return atan2f( -vector.y, sqrt((vector.x * vector.x) + (vector.z * vector.z)))
    }
    
}
