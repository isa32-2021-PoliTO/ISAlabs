#cmake_minimum_required(VERSION 3.17.3)
project(DaddaTreeGen)

#set(CMAKE_LEGACY_CYGWIN_WIN32 0)
set(CMAKE_CXX_STANDARD 17)

add_executable(DaddaTreeGen main.cpp Logics.cpp Logics.h DaddaTree.cpp DaddaTree.h)