//
//  SceneKit+Lines.mm
//  RHLwoundcareData
//
//  Created by Eric Arneback on 5/20/19.
//  Copyright © 2019 RHL Woundcare. All rights reserved.
//

#import "SceneKit+Lines.h"
#import <rhl_woundcare/math/Vec3.hpp>
#import <vector>

using namespace rhl_woundcare;

@implementation SCNNode (RHLwoundcareDataLines)

+ (instancetype)nodeFromLines:(const std::vector<sc3d::Line>&)lines withColors:(const std::vector<math::Vec3>&)colors
{
    std::vector<math::Vec3> positions;
    std::vector<math::Vec3> vcolors;
    std::vector<int> indices;

    int index = 0;
    for(auto line : lines) {
        positions.push_back(line.first);
        positions.push_back(line.second);
        
        vcolors.push_back(colors[index / 2]);
        vcolors.push_back(colors[index / 2]);
        
        index++;
        index++;
    }
    
    SCNGeometrySource *positionSource;
    {
        NSData *data = [NSData dataWithBytes:(const void *)positions.data()
                                      length:positions.size() * sizeof(math::Vec3)];
        
        positionSource =  [SCNGeometrySource geometrySourceWithData:data
                                                           semantic:SCNGeometrySourceSemanticVertex
                                                        vectorCount:positions.size()
                                                    floatComponents:YES
                                                componentsPerVector:3
                                                  bytesPerComponent:sizeof(float)
                                                         dataOffset:0
                                                         dataStride:sizeof(math::Vec3)];
    }
    
    SCNGeometrySource *colorSource;
    {
        NSData *data = [NSData dataWithBytes:(const void *)vcolors.data()
                                      length:vcolors.size() * sizeof(math::Vec3)];
        
        colorSource = [SCNGeometrySource geometrySourceWithData:data
                                                       semantic:SCNGeometrySourceSemanticColor
                                                    vectorCount:vcolors.size()
                                                floatComponents:YES
                                            componentsPerVector:3
                                              bytesPerComponent:sizeof(float)
                                                     dataOffset:0
                                                     dataStride:sizeof(math::Vec3)];
    }
    
    SCNGeometryElement *element;
    {
        element = [SCNGeometryElement geometryElementWithData:nil
                                                primitiveType:SCNGeometryPrimitiveTypeLine
                                               primitiveCount:positions.size() / 2
                                                bytesPerIndex:sizeof(int)];
    }
    
    
    SCNGeometry *scnGeometry = [SCNGeometry geometryWithSources:@[positionSource, colorSource]
                                                       elements:@[element]];
    
    SCNNode *node = [SCNNode nodeWithGeometry:scnGeometry];
    
    return node;
}

@end

