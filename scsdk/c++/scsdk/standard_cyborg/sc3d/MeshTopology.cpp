/*
Copyright 2020 Standard Cyborg

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

#include "standard_cyborg/sc3d/MeshTopology.hpp"
#include "standard_cyborg/util/AssertHelper.hpp"
#include <iostream>
#include <unordered_map>
#include <algorithm>

namespace standard_cyborg {
namespace sc3d {
namespace MeshTopology {

MeshTopology::MeshTopology(const std::vector<Edge>& edges,
                           const std::vector<FaceEdges>& faceEdges,
                           const std::vector<VertexEdges>& vertexEdges) :
    _edges(edges),
    _faceEdges(faceEdges),
    _vertexEdges(vertexEdges)
{}


MeshTopology::MeshTopology(const std::vector<Face3>& faces)
{
    compute(faces);
}

// Helper to identify an edge by its vertices
struct EdgeKey {
    int v1;
    int v2;
    
    EdgeKey(int vert1, int vert2) {
        // Ensure v1 is always the smaler index
        if (vert1 < vert2) {
            v1 = vert1;
            v2 = vert2;
        } else {
            v1 = vert2;
            v2 = vert1;
        }
    }
    
    bool operator==(const EdgeKey& other) const {
        return v1 == other.v1 && v2 == other.v2;
    }
};

// Hash function for EdgeKey
struct EdgeKeyHash {
    std::size_t operator()(const EdgeKey& key) const {
        return std::hash<int>()(key.v1) ^ (std::hash<int>()(key.v2) << 1);
    }
};

// New class to track face adjacency information to fix any issues
struct FaceAdjacency {
    int faceCount;
    std::vector<int> faces;
    
    FaceAdjacency() : faceCount(0) {
        faces.reserve(2);
    }
    
    void addFace(int faceId) {
        faces.push_back(faceId);
        faceCount++;
    }
    
    bool isManifold() const {
        return faceCount <= 2;
    }
};

void MeshTopology::compute(const std::vector<Face3>& faces)
{
    int numFaces = static_cast<int>(faces.size());
    
    // We don't know in advance how many vertices there will be. Instead, we assume vertex
    // numbering starts at zero and check as we iterate through the face data.
    //
    // We reserve a reasonable amount of space for per-vertex edges lists to reduce incremental
    // resizing. The Euler characteristic of a surface relates the number of faces to the number
    // of edges and vertices. For a triangular mesh (see:
    // https://math.stackexchange.com/questions/425968/eulers-formula-for-triangle-mesh ):
    //
    //   > The number of triangles is twice the number of vertices F ~ 2V
    //
    // Since it's not *exactly* half, we overestimate just a little to prevent resizing a large
    // array of vertex data right before we're done.
    _vertexEdges.reserve(static_cast<int>(numFaces * 0.52));
    
    _faceEdges.resize(numFaces);
    
    std::unordered_map<EdgeKey, FaceAdjacency, EdgeKeyHash> edgeToFaces;
    
    for (int faceId = 0; faceId < numFaces; faceId++) {
        Face3 face = faces[faceId];

        int vertexA = face[0];
        int vertexB = face[1];
        int vertexC = face[2];
        
        // Create edge keys and update adjacency
        EdgeKey keyAB(vertexA, vertexB);
        EdgeKey keyBC(vertexB, vertexC);
        EdgeKey keyCA(vertexC, vertexA);
        
        edgeToFaces[keyAB].addFace(faceId);
        edgeToFaces[keyBC].addFace(faceId);
        edgeToFaces[keyCA].addFace(faceId);
    }
    
    // Count non-manifold edges
    int nonManifoldCount = 0;
    for (const auto& entry : edgeToFaces) {
        if (!entry.second.isManifold()) {
            nonManifoldCount++;
        }
    }
    
    if (nonManifoldCount > 0) {
        std::cout << "Detected " << nonManifoldCount << " non-manifold edges. Repairing mesh..." << std::endl;
    }
    
    // Resize vertex edges array based on the maximum vertex index
    int maxVertexId = 0;
    for (const Face3& face : faces) {
        maxVertexId = std::max({maxVertexId, face[0], face[1], face[2]});
    }
    _vertexEdges.resize(maxVertexId + 1);
    
    // Second pass: create edges with intelligent repair
    for (int faceId = 0; faceId < numFaces; faceId++) {
        Face3 face = faces[faceId];

        int vertexA = face[0];
        int vertexB = face[1];
        int vertexC = face[2];
        
        // The main task in this code is to find the edge indices:
        int edgeAB = -1;
        int edgeBC = -1;
        int edgeCA = -1;
        
        // Get edge keys
        EdgeKey keyAB(vertexA, vertexB);
        EdgeKey keyBC(vertexB, vertexC);
        EdgeKey keyCA(vertexC, vertexA);
        
        // Find existing edges if they're already created
        for (auto edgeIndex : _vertexEdges[vertexA]) {
            Edge& edge = _edges[edgeIndex];

            // Check for an edge that matches either AB or BA
            if ((edge.vertex0 == vertexA && edge.vertex1 == vertexB) || 
                (edge.vertex0 == vertexB && edge.vertex1 == vertexA)) {
                // Only use this edge if it's not already connected to two faces
                if (edge.face1 == -1) {
                    edgeAB = edgeIndex;
                }
                if (edgeCA != -1) break;
            }
            
            // Similarly, check for an edge matching AC or CA
            if ((edge.vertex0 == vertexA && edge.vertex1 == vertexC) || 
                (edge.vertex0 == vertexC && edge.vertex1 == vertexA)) {
                // Only use this edge if it's not already connected to two faces
                if (edge.face1 == -1) {
                    edgeCA = edgeIndex;
                }
                if (edgeAB != -1) break;
            }
        }
        
        for (auto edgeIndex : _vertexEdges[vertexB]) {
            Edge& edge = _edges[edgeIndex];

            // Check for an edge that matches either BC or CB
            if ((edge.vertex0 == vertexB && edge.vertex1 == vertexC) || 
                (edge.vertex0 == vertexC && edge.vertex1 == vertexB)) {
                // Only use this edge if it's not already connected to two faces
                if (edge.face1 == -1) {
                    edgeBC = edgeIndex;
                }
                break;
            }
        }
        
        // Either create new edges or set the second face of an existing edge based on what was found
        if (edgeAB == -1) {
            edgeAB = static_cast<int>(_edges.size());
            _edges.push_back({vertexA, vertexB, faceId, -1});
        } else {
            _edges[edgeAB].face1 = faceId;
        }
        
        if (edgeBC == -1) {
            edgeBC = static_cast<int>(_edges.size());
            _edges.push_back({vertexB, vertexC, faceId, -1});
        } else {
            _edges[edgeBC].face1 = faceId;
        }
        
        if (edgeCA == -1) {
            edgeCA = static_cast<int>(_edges.size());
            _edges.push_back({vertexC, vertexA, faceId, -1});
        } else {
            _edges[edgeCA].face1 = faceId;
        }
        
        // Set the three edges for this face
        _faceEdges[faceId][0] = edgeAB;
        _faceEdges[faceId][1] = edgeBC;
        _faceEdges[faceId][2] = edgeCA;
        
        // Add these edges to vertexEdges' adjacency lists
        _vertexEdges[vertexA].insert(edgeCA);
        _vertexEdges[vertexA].insert(edgeAB);
        
        _vertexEdges[vertexB].insert(edgeAB);
        _vertexEdges[vertexB].insert(edgeBC);
        
        _vertexEdges[vertexC].insert(edgeBC);
        _vertexEdges[vertexC].insert(edgeCA);
    }
    
    // Validate the final topology
    validateTopology();
}

// This is a new helper method to validte the final mesh topology
void MeshTopology::validateTopology() {
    bool isValid = true;
    int nonManifoldEdges = 0;
    
    for (const Edge& edge : _edges) {
        // Checsk if we have more than 2 faces connected to this edge
        if (edge.face0 != -1 && edge.face1 != -1) {
            // Checks if there are any other edges that connect the same vertices and also have faces assigned to them
            int v0 = edge.vertex0;
            int v1 = edge.vertex1;
            
            for (auto edgeIndex : _vertexEdges[v0]) {
                Edge& otherEdge = _edges[edgeIndex];
                if (&otherEdge != &edge && 
                    ((otherEdge.vertex0 == v0 && otherEdge.vertex1 == v1) ||
                     (otherEdge.vertex0 == v1 && otherEdge.vertex1 == v0))) {
                    if (otherEdge.face0 != -1) {
                        nonManifoldEdges++;
                        isValid = false;
                        break;
                    }
                }
            }
        }
    }
    
    if (!isValid) {
        std::cout << "Warning: Mesh topology validation found " << nonManifoldEdges 
                  << " non-manifold edges. This should not happen with properly repaired mesh." << std::endl;
    } else {
        std::cout << "Mesh topology validation successful. All edges are properly manifold." << std::endl;
    }
}

const std::vector<Edge> MeshTopology::getEdges() const
{
    return _edges;
}

const std::vector<FaceEdges> MeshTopology::getFaceEdges() const
{
    return _faceEdges;
}

const std::vector<VertexEdges> MeshTopology::getVertexEdges() const
{
    return _vertexEdges;
}

int MeshTopology::getNumEdges() const
{
    return static_cast<int>(_edges.size());
}

int MeshTopology::getNumFaceEdges() const
{
    return static_cast<int>(_faceEdges.size());
}

int MeshTopology::getNumVertexEdges() const
{
    return static_cast<int>(_vertexEdges.size());
}

} // namespace standard_cyborg::MeshTopology
} // namespace sc3d
} // namespace standard_cyborg