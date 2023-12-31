set_source_group(SOURCES "Source Files" dwarf_abbrev.c 
dwarf_alloc.c dwarf_crc.c dwarf_crc32.c dwarf_arange.c 
dwarf_debug_sup.c
dwarf_debugaddr.c 
dwarf_debuglink.c dwarf_die_deliv.c 
dwarf_debugnames.c dwarf_dsc.c
dwarf_elf_load_headers.c 
dwarf_elfread.c 
dwarf_elf_rel_detector.c 
dwarf_error.c 
dwarf_fill_in_attr_form.c
dwarf_find_sigref.c dwarf_fission_to_cu.c
dwarf_form.c dwarf_form_class_names.c
dwarf_frame.c dwarf_frame2.c
dwarf_gdbindex.c dwarf_global.c 
dwarf_gnu_index.c dwarf_groups.c 
dwarf_harmless.c dwarf_generic_init.c dwarf_init_finish.c 
dwarf_leb.c 
dwarf_line.c dwarf_loc.c 
dwarf_loclists.c
dwarf_locationop_read.c
dwarf_machoread.c dwarf_macro.c dwarf_macro5.c
dwarf_memcpy_swap.c
dwarf_names.c
dwarf_object_read_common.c dwarf_object_detector.c
dwarf_peread.c 
dwarf_query.c dwarf_ranges.c 
dwarf_rnglists.c
dwarf_safe_arithmetic.c
dwarf_safe_strcpy.c
dwarf_secname_ck.c
dwarf_setup_sections.c
dwarf_string.h dwarf_string.c
dwarf_stringsection.c
dwarf_tied.c 
dwarf_str_offsets.c
dwarf_tsearchhash.c dwarf_util.c 
dwarf_xu_index.c
dwarf_print_lines.c )

set_source_group(HEADERS "Header Files" dwarf.h dwarf_abbrev.h
dwarf_alloc.h dwarf_arange.h dwarf_base_types.h 
dwarf_debugaddr.h
dwarf_debuglink.h dwarf_die_deliv.h 
dwarf_debugnames.h dwarf_dsc.h 
dwarf_elf_access.h dwarf_elf_defines.h dwarf_elfread.h 
dwarf_elf_rel_detector.h 
dwarf_elfstructs.h 
dwarf_error.h dwarf_frame.h 
dwarf_gdbindex.h dwarf_global.h dwarf_harmless.h 
dwarf_gnu_index.h 
dwarf_line.h dwarf_loc.h 
dwarf_machoread.h dwarf_macro.h dwarf_macro5.h 
dwarf_object_detector.h dwarf_opaque.h 
dwarf_pe_descr.h dwarf_peread.h
dwarf_reading.h
dwarf_rnglists.h
dwarf_safe_arithmetic.h
dwarf_safe_strcpy.h
dwarf_tied_decls.h 
dwarf_tsearch.h 
dwarf_setup_sections.h
dwarf_str_offsets.h
dwarf_universal.h 
dwarf_util.h 
dwarf_xu_index.h libdwarf_private.h
dwarf_macho_loader.h
dwarf_memcpy_swap.h)

set_source_group(CONFIGURATION_FILES "Configuration Files" 
    ${PROJECT_SOURCE_DIR}/cmake/config.h.cmake 
    ${PROJECT_BINARY_DIR}/config.h)

# The -DPIC is so we find the right DW_API value in libdwarf.h
# with cmake with Linux.
# Dwarfgen requires all symbols in .so to be visible, so
# do not say hidden on libdwarf in that case.
if (BUILD_SHARED)
    if(NOT BUILD_DWARFGEN)
      set(CMAKE_C_VISIBILITY_PRESET hidden)
    endif()
    set(DEFS LIBDWARF_BUILD PIC)
else()
    set(DEFS LIBDWARF_STATIC)
endif()

if (PIC_ALWAYS)
  set(CMAKE_POSITION_INDEPENDENT_CODE ON)
  list(APPEND DEFS PIC)
endif()

include(GNUInstallDirs)
	
list(LENGTH DWARF_TARGETS targetCount)
math(EXPR targetCount "${targetCount} - 1")
list(APPEND DWARF_LIBS ${LIBELF_LIBRARIES})
if (DW_FZLIB)
    list(APPEND DWARF_LIBS z)
endif()
if (DW_FZSTD)
    list(APPEND DWARF_LIBS zstd)
endif()
foreach(i RANGE ${targetCount})
	list(GET DWARF_TARGETS ${i} target)
	list(GET DWARF_TYPES ${i} type)
	add_library(${target} ${type} ${SOURCES} ${HEADERS}
            ${GENNAMES_OUTPUT} ${CONFIGURATION_FILES})

    add_library(libdwarf::${target} ALIAS ${target})
    
	set_folder(${target} src/lib/libdwarf)
    target_compile_options(${target} PRIVATE ${COMPILER_FLAGS}
            ${DW_FWALL})
	msvc_posix(${target})
    
    target_compile_definitions(${target} PUBLIC ${DEFS})
    
  target_include_directories(
    ${target}
    PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
  )

	target_link_libraries(${target} PUBLIC  ${DW_FZLIB} ${DW_FZSTD} ) 
	
	set_target_properties(${target} PROPERTIES OUTPUT_NAME dwarf)

	set(SUFFIX $<$<EQUAL:${CMAKE_SIZEOF_VOID_P},8>:64>)
	set(LIBDIR lib${SUFFIX})
	set(BINDIR bin${SUFFIX})

	install(TARGETS ${target}
		RUNTIME DESTINATION ${BINDIR}		
		LIBRARY DESTINATION ${LIBDIR}
		ARCHIVE DESTINATION ${LIBDIR})
endforeach()

configure_file(libdwarf.pc.cmake libdwarf.pc @ONLY )

# The install has to be here, not in
# another CMakeLists.txt  to make install work properly
# for cmake before cmake 3.13. This also works
# for newer cmake.
add_custom_target(dd DEPENDS ${DWARF_TARGETS} dwarfdump)
install(TARGETS ${DWARF_TARGETS} EXPORT libdwarfTargets
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    INCLUDES DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")
install(EXPORT libdwarfTargets
    FILE libdwarf-targets.cmake
    NAMESPACE libdwarf::
    DESTINATION lib/cmake/libdwarf
)
install(
    FILES cmake/libdwarf-config.cmake
    DESTINATION lib/cmake/libdwarf
)
install(
    FILES ${CMAKE_CURRENT_SOURCE_DIR}/libdwarf.h
    DESTINATION include/libdwarf)
install(
    FILES ${CMAKE_CURRENT_SOURCE_DIR}/dwarf.h
    DESTINATION include/libdwarf)
install( FILES ${PROJECT_BINARY_DIR}/src/lib/libdwarf/libdwarf.pc
    DESTINATION lib/pkgconfig
)
