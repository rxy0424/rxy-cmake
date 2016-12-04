cmake_minimum_required(VERSION 2.8.2)

set(CMAKE_CXX_FLAGS_DEBUG "$ENV{CXXFLAGS} -O0 -Wall -g2 -ggdb")
project(hell)

add_executable(hell main.cpp)
