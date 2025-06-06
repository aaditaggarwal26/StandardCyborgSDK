/*
Copyright 2020 RHL Woundcare

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
#pragma once


#include "rhl_woundcare/sc3d/Plane.hpp"
#include "rhl_woundcare/sc3d/VertexSelection.hpp"

#include <memory>
#include <vector>

namespace rhl_woundcare {

namespace math {
struct Vec3;
}

namespace algorithms {

struct EstimatePlaneResult {
    rhl_woundcare::sc3d::Plane plane;
    bool converged = false;
    float rmsProjectedDistance = 0.0;
    std::unique_ptr<rhl_woundcare::sc3d::VertexSelection> planeVertices = std::make_unique<rhl_woundcare::sc3d::VertexSelection>();
};

EstimatePlaneResult estimatePlane(const std::vector<rhl_woundcare::math::Vec3>& positions,
                                  const rhl_woundcare::sc3d::VertexSelection& initialVertexSet = rhl_woundcare::sc3d::VertexSelection(),
                                  int maxIterations = 20,
                                  float outlierStandardDeviationThreshold = 5.0,
                                  float relativeConvergenceTolerance = 1e-4,
                                  float absoluteConvergenceTolerance = 1e-7);


}

} // namespace RHLwoundcare
