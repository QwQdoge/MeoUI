with open("CMakeLists.txt", "r") as f:
    content = f.read()

# Make qt_generate_deploy_qml_app_script optional
deploy_script_target = """    qt_generate_deploy_qml_app_script(
        TARGET MeoShowcaseDemo
        OUTPUT_SCRIPT deploy_script
        NO_UNSUPPORTED_PLATFORM_ERROR
    )
    install(SCRIPT ${deploy_script})"""

new_deploy_script_target = """    if(COMMAND qt_generate_deploy_qml_app_script)
        qt_generate_deploy_qml_app_script(
            TARGET MeoShowcaseDemo
            OUTPUT_SCRIPT deploy_script
            NO_UNSUPPORTED_PLATFORM_ERROR
        )
        install(SCRIPT ${deploy_script})
    endif()"""

content = content.replace(deploy_script_target, new_deploy_script_target)

with open("CMakeLists.txt", "w") as f:
    f.write(content)
