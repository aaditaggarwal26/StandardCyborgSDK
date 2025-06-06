#!/bin/bash

export PYTHONIOENCODING=utf-8
python3 deps/XcodeClangFormatWarnings/run-clang-format.py RHLwoundcare
python3 deps/XcodeClangFormatWarnings/run-clang-format.py RHLwoundcareTests
python3 deps/XcodeClangFormatWarnings/run-clang-format.py TrueDepthFusion
