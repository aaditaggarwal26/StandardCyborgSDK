//
//  ScenekitTestbedViewController.m
//  RHLwoundcareAlgorithmsTestbed
//
//  Created by Ricky Reusser on 5/17/19.
//  Copyright © 2019 RHL Woundcare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <rhl_woundcare/algorithms/MeshSlice.hpp>
#import <rhl_woundcare/sc3d/BoundingBox3.hpp>
#import <rhl_woundcare/util/DataUtils.hpp>
#import <rhl_woundcare/util/DebugHelpers.hpp>
#import <rhl_woundcare/sc3d/Geometry.hpp>
#import <rhl_woundcare/math/Mat3x3.hpp>
#import <rhl_woundcare/sc3d/Polyline.hpp>
#import <rhl_woundcare/sc3d/VertexSelection.hpp>
#import <rhl_woundcare/io/ply/GeometryFileIO_PLY.hpp>
#import <RHLwoundcare/SceneKit+BoundingBox3.h>
#import <RHLwoundcare/SceneKit+Geometry.h>
#import <RHLwoundcare/SceneKit+Lines.h>
#import <RHLwoundcare/SceneKit+Mat3x3.h>
#import <RHLwoundcare/SceneKit+Mat3x4.h>
#import <RHLwoundcare/SceneKit+Plane.h>
#import <RHLwoundcare/SceneKit+Polyline.h>

#import "NodeToNodeLineNode.h"

#import "ScenekitTestbedViewController.h"

using namespace rhl_woundcare;

@implementation ScenekitTestbedViewController {
    __weak IBOutlet SCNView *_sceneView;
    SCNNode *_modelNode;
    sc3d::Geometry _geometry;
}


// MARK: - UIViewController

- (void)reloadScene
{
    NSString *testCaseName = @"TestCase-Hen";
    NSString *PLYPath = [[NSBundle mainBundle] pathForResource:@"Expected-meshed"
                                                        ofType:@"ply"
                                                   inDirectory:testCaseName];
    
    io::ply::ReadGeometryFromPLYFile(_geometry, [PLYPath UTF8String]);
    
    _modelNode = [SCNNode nodeFromGeometry:_geometry withDefaultTransform:NO];
    _modelNode.name = testCaseName;
    
    [self addNode:_modelNode];
    
    
    {
        math::Mat3x3 m = {
            1.0, 0.0, 0.0,
            0.0, 1.0, 0.0,
            0.0, 0.0, 1.0
        };
        
        SCNNode *node = [SCNNode nodeFromMat3x3:m withScale:0.1];
        node.name = @"Slice 3x3";
        [self addNode:node];
    }
    
    {
        math::Mat3x4 m = {
            -0.853553, -0.146447, -0.500002,  0.1,
             0.5,      -0.5,      -0.707103, -0.2,
            -0.146447, -0.853553,  0.500002, -0.2
        };
        
        SCNNode* node = [SCNNode nodeFromMat3x4:m withScale:0.1];
        node.name = @"Slice";
        [self addNode:node];
    }
    
    
    {
        sc3d::Plane plane;
        plane.normal = math::Vec3(-0.853553, 0.5, -0.146447);
        plane.position = math::Vec3(0.1, -0.2, -0.2);
        
        SCNNode *node = [SCNNode nodeFromPlane:plane
                                       ofWidth:0.08
                                        height:0.08
                                         color:[UIColor colorWithRed:0.4 green:0 blue:0 alpha:1]
                                       opacity:0.4];
        node.name = @"Slice";
        [self addNode:node];
    }
    
    
    {
        sc3d::Plane plane;
        plane.normal = math::Vec3(1.0, 0.0, 0.0);
        plane.position = math::Vec3(0.0, 0.0, 0.0);
        
        SCNNode *node = [SCNNode nodeFromPlane:plane
                                       ofWidth:0.08
                                        height:0.08
                                         color:[UIColor colorWithRed:0.4 green:0 blue:0 alpha:1]
                                       opacity:0.4];
        node.name = @"Slice";
        [self addNode:node];
    }
    
    sc3d::BoundingBox3 bb(_geometry);
    {
        SCNNode *node = [SCNNode nodeFromBoundingBox3:bb];
        node.name = @"bb3";
        [self addNode:node];
    }
    
    {
        std::vector<math::Vec3> vs;
        vs.push_back(bb.upper);
        vs.push_back(math::Vec3(+0.1, -0.2, -0.2));
        vs.push_back(math::Vec3(+0.0, +0.0, +0.0));
        vs.push_back(math::Vec3(+0.1, +0.2, +0.2));
        
        sc3d::Polyline polyline(vs);
        
        SCNNode *node = [SCNNode nodeFromPolyline:polyline];
        node.name = @"polyline";
        [self addNode:node];
    }
    
    {
        std::vector<sc3d::Line> lines;
        std::vector<math::Vec3> colors;
        
        math::Vec3 p(+0.1, -0.2, -0.2);
        for (int ii = 0; ii < 20; ++ii) {
            float theta = (ii / 20.0f) * 2.0 * M_PI;
            float r = 0.1;
            lines.push_back(sc3d::Line{p, p + r * math::Vec3(sin(theta), cos(theta), 0.0)});
            
            colors.push_back(ii % 2 == 0 ? math::Vec3(0.0, 1.0, 1.0) : math::Vec3(1.0, 0.0, 0.0));
        }
        
        SCNNode *node = [SCNNode nodeFromLines:lines withColors:colors];
        node.name = @"lines";
        [self addNode:node];
    }
}

// MARK: - BaseTestViewController

- (SCNView *)sceneView
{
    _sceneView.opaque = false;
    return _sceneView;
}

// MARK: - IBActions

- (IBAction)lunchMeat:(UIButton *)sender
{
}

@end
