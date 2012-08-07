
set(TESTS_SRC
test-load.vala
)

vala_precompile(TESTS_VALA_C
    ${TESTS_SRC}
PACKAGES
    ${AUGEDIT_PACKAGES}
    augedit-static
OPTIONS
    --vapidir=${CMAKE_SOURCE_DIR}/src
    --thread
    --enable-checking
    --fatal-warnings
)

add_executable(test-load ${TESTS_VALA_C})
target_link_libraries(test-load ${DEPS_LIBRARIES} gthread-2.0 augedit-static)

ADD_TEST(test-load ${CMAKE_CURRENT_BINARY_DIR}/test-load)
