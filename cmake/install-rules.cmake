install(
    TARGETS image-buster_exe
    RUNTIME COMPONENT image-buster_Runtime
)

if(PROJECT_IS_TOP_LEVEL)
  include(CPack)
endif()
