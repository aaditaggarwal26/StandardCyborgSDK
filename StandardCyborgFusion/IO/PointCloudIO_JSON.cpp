//
//  PointCloudIO_JSON.cpp
//  RHLwoundcare
//
//  Created by Aaron Thompson on 3/11/19.
//  Copyright © 2019 RHL Woundcare. All rights reserved.
//

#include <nlohmann/json.hpp>
#include <RHLwoundcare/PointCloudIO.hpp>
#include <rhl_woundcare/sc3d/PerspectiveCamera.hpp>
#include <rhl_woundcare/io/json/PerspectiveCameraFileIO_JSON_Private.hpp>

using JSON = nlohmann::json;
using namespace rhl_woundcare;

sc3d::PerspectiveCamera PointCloudIO::PerspectiveCameraFromJSON(const JSON& json)
{
    sc3d::PerspectiveCamera camera;
    io::json::ReadPerspectiveCameraFromJSON(camera, json);
    return camera;
}

JSON PointCloudIO::JSONFromPerspectiveCamera(const sc3d::PerspectiveCamera& camera)
{
    JSON json;
    io::json::WritePerspectiveCameraToJSON(json, camera);
    return json;
}

