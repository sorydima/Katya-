#----------------------------------------------------------------
# Generated CMake target import file for configuration "Debug".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "Olm::Olm" for configuration "Debug"
set_property(TARGET Olm::Olm APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
set_target_properties(Olm::Olm PROPERTIES
  IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/lib/libolm.so"
  IMPORTED_SONAME_DEBUG "libolm.so"
  )

list(APPEND _IMPORT_CHECK_TARGETS Olm::Olm )
list(APPEND _IMPORT_CHECK_FILES_FOR_Olm::Olm "${_IMPORT_PREFIX}/lib/libolm.so" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
