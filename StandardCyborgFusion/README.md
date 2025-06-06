# RHLwoundcare

Framework that implements our 3D reconstruction algorithm PBFusion, that takes
depth and color frames as input, and reconstructs a 3D pointcloud from it. 

The public API of the framework is everything in `RHLwoundcare/Public`. 

`RHLwoundcare/Algorithm` contains algorithms that are only ever used in our PBFusion, or 
are using mac-specific stuff, and thus cannot be used in our pure C++ algorithms library `rhl_woundcare::algorithm`.
The same applies for `RHLwoundcare/IO` and `rhl_woundcare::io`.

The class `SCReconstructionManager` can be used to perform real-time reconstruction, using
frames obtained from the device. The class `SCOfflineReconstructionManager` is used for off-line
reconstruction, using a sequence of `bply` files as input. 

The class `MetalDepthProcessor` is a central class in PBFusion. As input, it takes raw depth and color
frames acquired from the device, as well as the camera settings, and as output it spits out the 
unprojected point cloud of that depth frame. And every point is assigned a color and normal, as well other miscellenous
values that are used in PBFusion.
