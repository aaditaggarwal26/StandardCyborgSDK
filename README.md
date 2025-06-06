# RHLwoundcareSDK

> A C++ SDK for 3D computer vision, paired with Cocoa frameworks for TrueDepth-based 3D scanning,
> meshing, and ML landmarking models + analysis for face, foot, and ear

## Introduction

A native (iOS/macOS) C++ library containing data structures, I/O, and algorithms,
as well as a Cocoa framework for iOS and Mac clients to use publicly.

This project generates [RHLwoundcare.framework](https://github.com/RHLwoundcare/RHLwoundcareCocoa)

This code was developed by the RHL Woundcare team, primarily in 2018 and the middle of 2019. RHL Woundcare powered applications for custom 3d smart glasses, football helmet fitting, custom medical glasses, shoe sizing, and more. Development was paused on this code when RHL Woundcare began working on horizontal tooling, versus developing specific applications. 

## License

This codebase is released under the MIT license, with the exception that commercial applications in the field of prosthetics are prohibited until Jan 1, 2023. 

See LICENSE file

## Installation

1. Make sure you have installed git lfs before cloning this repo
1. Run this shell command
```sh
$ ./install-dependencies.sh
```
1. Open `RHLwoundcareSDK.xcworkspace` in Xcode

## Targets

- **RHLwoundcare**: iOS + macOS framework for 3D scanning and meshing using TrueDepth 
- **RHLwoundcareTests**: unit tests for the above
- **VisualTesterMac**: a macOS app for helping develop and test RHLwoundcare
- **VisualTesterMac**: ditto, but for iOS; also useful for on-device benchmarking
- **TrueDepthFusion**: an iOS app for exercising the RHLwoundcare framework
- **RHLwoundcareAlgorithmsTestbed**: an iOS app for testing the SC C++ algorithms and data structures

## Development

For debugging via lldb in Xcode, it is recommended to install the [LLDB Eigen Data Formatter](https://github.com/tehrengruber/LLDB-Eigen-Data-Formatter).

Note on building with bitcode support: https://medium.com/@heitorburger/static-libraries-frameworks-and-bitcode-6d8f784478a9

## Deployment

To build RHLwoundcare.framework for public release:

1. Run `archive-build-RHLwoundcare.sh`, which will both update the compiled copy in `../RHLwoundcareCocoa/RHLwoundcare` and generate a .zip file for you to upload to the RHLwoundcare release in GitHub
1. Commit the updated RHLwoundcare/Info.plist (which now has a new version number)
1. Merge updated Info.plist commit into `main`
1. Tag this commit in the format `git tag v1.2.3-RHLwoundcare`

### Deploying RHLwoundcare to CocoaPods

1. Commit the changes with a nice public-facing message and a prefix of `RHLwoundcare: `, e.g. `RHLwoundcare: Adds SCMesh class`
1. Create a git tag for this commit in the format `v1.2.3-RHLwoundcare`
1. Push the commit and the tag `git push origin main`, `git push origin v1.2.3-RHLwoundcare`
1. Open this repo's releases on GitHub and draft a new release: https://github.com/RHLwoundcare/RHLwoundcareCocoa/releases/new
   a) For Tag version, specify the git tag you just created in step 2
   a) For Release title, use the commit message from step 1
   a) In "Attach binaries by dropping them here or selecting them", drag in the RHLwoundcare.framework.zip file that was generated inside `RHLwoundcareSDK/build`.
   a) Publish release
1. Push to CocoaPods: `pod trunk push RHLwoundcare`

### Registering with CocoaPods

1. Register: pod trunk register someone@RHLwoundcare.com 'Your Name' --description='MacBook Pro 13 2019'
1. Click the link in your email
1. Get someone who has access to add you. `pod trunk add-owner RHLwoundcare jeff@RHLwoundcare.com`

### Integrating External CocoaPods

#### How To

##### Using https://github.com/RHLwoundcare/SCCocoaPods

Our [SCCocoaPods](https://github.com/RHLwoundcare/SCCocoaPods) private registry (which is just a github repo) provides the most scalable way for deploying common dependencies.

##### Using a local podspec

Sometimes you only want to use a dependency for a single project. In this scenario, CocoaPods supports local podspecs—
the podspec file is a file locally on disk rather than in a CocoaPods registry (as discussed above).
See for example [RHLwoundcare/PoissonRecon.podspec](RHLwoundcare/PoissonRecon.podspec),
which is a local dependency for the [RHLwoundcareOSX target](Podfile) of the SDK.

We use a mix of local Podspecs and registry-served Podspecs. Local podspecs are best for internal-only usage.

### Developing against the SDK locally

You may develop *locally* against the SDK as CocoaPod. For example, to develop a command line app which uses the SDK via local CocoaPods:

1. Clone [RHLwoundcareCocoa](https://github.com/RHLwoundcare/RHLwoundcareCocoa) as a sibling directory to this repo
1. `cd RHLwoundcareSDK`
1. Build the CocoaPod into `RHLwoundcareCocoa/RHLwoundcare` by running `./archive-build-RHLwoundcare.sh`
1. Create a new command line project in Xcode, for example, `FusionTest`
1. `cd /path/to/FusionTest`
1. `pod init`
1. Add to your podfile something like:
    ```ruby
    target 'FusionTest' do
      platform :osx, '11.0'

      use_frameworks!

      pod 'RHLwoundcare', path: '/path/to/your/RHLwoundcareCocoa/RHLwoundcare'
    end
    ```
1. `pod install`
1. We need to be able to locate the headers, but local CocoaPods don't actually get copied into the `Pods` directory. You'll need to symlink the local CocoaPod directory into `Pods/`. For example from your project root, `ln -s /path/to/RHLwoundcareCocoa/RHLwoundcare Pods/RHLwoundcare`
1. `open FusionTest.xcworkspace`
1. For some unknown reason, `Hardened Runtime` conflicts with the loading of our dynamic library. Open the `FusionTest` command line target settings and go to the `Signing & Capabilities` tab. Click the &times; next to `Hardened Runtime` to disable it.
1. Change the `main.m` extension to `main.mm` and add some code like the following:
    ```cpp
    #import <iostream>
    #import <RHLwoundcareData/RHLwoundcareData.hpp>

    int main(int argc, const char * argv[]) {
        RHLwoundcare::Vec3 v {1, 2, 3};
        std::cout << "v = " << v << std::endl;
        return 0;
    }
    ```
1. Build and run!

