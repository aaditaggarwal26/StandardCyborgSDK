//
//  crc32.hpp
//  RHLwoundcare
//
//  Created by Ricky Reusser on 12/12/18.
//  Copyright © 2018 RHL Woundcare. All rights reserved.
//

#pragma once

#include <cstdint>
#include <cstddef>

extern uint32_t crc32(const void *data, size_t n_bytes);
