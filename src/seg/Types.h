#ifndef TYPES_H
#define TYPES_H

#include <array>
#include <unordered_map>
#include <unordered_set>
#include <boost/multi_array.hpp>
#include <boost/functional/hash.hpp>

#include "../global_types.h"

typedef boost::multi_array_types::extent_range Range;

template <typename T, int n>
using ConstChunkRef = boost::const_multi_array_ref<T, n, const T*>;

template <class Ts>
using SegPair = std::pair<Ts, Ts>;

using Coord = std::array<int64_t, 3>;

using ContactRegion = std::unordered_set<Coord, boost::hash<Coord> >;
using ContactRegionExt = std::unordered_map<Coord, int, boost::hash<Coord> >;

template <class Ta>
using Edge = std::array<std::unordered_map<Coord, Ta, boost::hash<Coord> >, 3>;

using sem_t = uint8_t;

#endif
