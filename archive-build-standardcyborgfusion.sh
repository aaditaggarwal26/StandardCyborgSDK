#!/usr/bin/env bash

# Exit on first error, unset variable, or pipe failure
set -euo pipefail

if [ ! -d "../RHLwoundcareCocoa" ]; then echo "Need a checkout of RHLwoundcareCocoa"; exit 1; fi

# Read and update the framework version
current_version_string=`plutil -p RHLwoundcare/Info.plist | grep CFBundleShortVersionString`
current_version=`echo "$current_version_string" | sed -E 's/.+=> \"([0-9\.]+)\"$/\1/g'`

echo "What version number do you deem this build? The current version is $current_version (leave empty to use the same version)"
read new_version
if [ -z $new_version ]; then
    new_version="$current_version"
fi

echo "Updating version number to $new_version"
plutil -replace CFBundleShortVersionString -string "$new_version" RHLwoundcare/Info.plist
sed -i '' -E "s/  s.version(.+) = '([0-9\.]+)'/  s.version\1 = '$new_version'/g" "../RHLwoundcareCocoa/RHLwoundcare/RHLwoundcare.podspec"


# Now we build RHLwoundcare for OSX, iOS, and the simulator.  Notes:
#  * `-derivedDataPath` for iOS and simulator is how to best get the .framework we desire; we use
#     `-archivePath` for OSX because for whatever reason `-derivedDataPath` doesn't give us the same
#     output structure for OSX (and actually includes a broken simlink and no compiled library).
#  * This was set up with a lot of trial and error and it's not at all clear if this is the best
#     solution.  Don't change SYMROOT because then the Pods won't build for some reason.
#  * Note we're using a different RHLwoundcareOSX scheme for OSX; this scheme (and target)
#     is basically identical to RHLwoundcare, except we need a separate one because of how
#     cocoapods work (must be either iOS or OSX not both).

echo
echo
echo "Building RHLwoundcare for macOS"
echo
xcodebuild archive -workspace RHLwoundcareSDK.xcworkspace -scheme RHLwoundcareOSX -configuration Release -sdk macosx -archivePath build/RHLwoundcare-osx | xcpretty

echo
echo "Building RHLwoundcare for iOS"
echo
xcodebuild archive -workspace RHLwoundcareSDK.xcworkspace -scheme RHLwoundcare -configuration Release -sdk iphoneos -archivePath build/RHLwoundcare-ios | xcpretty

echo
echo "Building RHLwoundcare for iOS simulator"
echo
# NOTE: only building the x86_64 slice for simulator because the simulator on M1 Macs can use the iOS arm64 slice
xcodebuild archive -workspace RHLwoundcareSDK.xcworkspace -scheme RHLwoundcare -configuration Release -sdk iphonesimulator -archivePath build/RHLwoundcare-simulator | xcpretty

echo
echo
echo "Creating universal binary for device and simulator architectures..."
pushd "build" &>/dev/null
  # Create the directories
  mkdir -p osx ios

  # Remove existing
  if test -d "ios/RHLwoundcare.framework"; then rm -r "ios/RHLwoundcare.framework"; fi
  if test -d "osx/RHLwoundcare.framework"; then rm -r "osx/RHLwoundcare.framework"; fi

  # Copy build products into the appropriate locations
  osx_root="RHLwoundcare-osx.xcarchive/Products/Library/Frameworks/"
  cp -R "$osx_root/RHLwoundcare.framework/" "osx/RHLwoundcare.framework"

  ios_root="RHLwoundcare-ios.xcarchive/Products/Library/Frameworks/"
  cp -R "$ios_root/RHLwoundcare.framework" "ios/RHLwoundcare.framework"

  sim_root="RHLwoundcare-simulator.xcarchive/Products/Library/Frameworks/"

  # Ensure private headers are stripped
  if test -d "osx/RHLwoundcare.framework/Versions/A/PrivateHeaders"; then
    echo "ERROR: private headers were not stripped from the built Mac framework!"
    exit
  fi
  if test -d "ios/RHLwoundcare.framework/PrivateHeaders"; then
    echo "ERROR: private headers were not stripped from the built iOS framework!"
    exit
  fi

  # Ensure ML models are not published
  if compgen -G "osx/RHLwoundcare.framework/Versions/A/Resources/*.mlmodel*" >/dev/null; then
    echo "ERROR: mlmodelc directories were not stripped from the built Mac framework!"
    exit
  fi
  if compgen -G "ios/RHLwoundcare.framework/*.mlmodel*" >/dev/null; then
    echo "ERROR: mlmodelc directories were not stripped from the built iOS framework!"
    exit
  fi
  
  if test -d "RHLwoundcare.xcframework"; then
    rm -r "RHLwoundcare.xcframework"
  fi

  # This creates a combined xcframework that includes binaries for iOS device, simulator, and macOS
  xcrun xcodebuild -create-xcframework \
    -framework "$ios_root/RHLwoundcare.framework" \
    -framework "$sim_root/RHLwoundcare.framework" \
    -framework "$osx_root/RHLwoundcare.framework" \
    -output "RHLwoundcare.xcframework"

  # Copy files into RHLwoundcareCocoa
  echo "Updating RHLwoundcareCocoa"
  rm -rf "../../RHLwoundcareCocoa/RHLwoundcare/RHLwoundcare.xcframework"
  cp -R "RHLwoundcare.xcframework" "../../RHLwoundcareCocoa/RHLwoundcare/"

  echo "Creating zipped version for upload to GitHub release..."
  cp "../../RHLwoundcareCocoa/RHLwoundcare/LICENSE" .

  tar -czf "RHLwoundcare.xcframework.tar.gz" "RHLwoundcare.xcframework" "LICENSE"
popd &>/dev/null

echo "Finished building RHLwoundcare-$new_version"
echo "Recommended:"
echo "git tag RHLwoundcare-$new_version"
