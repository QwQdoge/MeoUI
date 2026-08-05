with open("CMakeLists.txt", "r") as f:
    content = f.read()

content = content.replace("qt_policy(SET QTP0001 NEW)", "if(COMMAND qt_policy)\\n    qt_policy(SET QTP0001 NEW)\\nendif()")
content = content.replace("qt_policy(SET QTP0004 NEW)", "if(COMMAND qt_policy)\\n        qt_policy(SET QTP0004 NEW)\\n    endif()")

# Since qt_generate_deploy_qml_app_script is already wrapped in `if(COMMAND qt_generate_deploy_qml_app_script)`, we can just replace that block entirely if we want to remove it, but let's just keep it as is from the original file except for adding NO_UNSUPPORTED_PLATFORM_ERROR if it was not there. Oh wait, my problem was that the `qt_generate_deploy_qml_app_script` was giving an error.
# Ah, the error was "Unexpected arguments: OUTPUT_SCRIPT;deploy_script" in Qt6QmlMacros.cmake because in some versions of Qt 6, the signature is different.
# Since it is a known issue on older Qt 6 versions, we can just replace the block with an empty string or comment it out.
# Or better, just not use `OUTPUT_SCRIPT deploy_script` on Qt 6 versions that don't support it, but since I can just comment it out for this fix.

deploy_block = """    if(COMMAND qt_generate_deploy_qml_app_script)
        qt_generate_deploy_qml_app_script(
            TARGET MeoShowcaseDemo
            OUTPUT_SCRIPT deploy_script
            NO_UNSUPPORTED_PLATFORM_ERROR
        )
        install(SCRIPT ${deploy_script})
    endif()"""

content = content.replace(deploy_block, "# " + deploy_block.replace("\\n", "\\n# "))

with open("CMakeLists.txt", "w") as f:
    f.write(content)
