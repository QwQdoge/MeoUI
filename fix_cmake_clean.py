with open("CMakeLists.txt", "r") as f:
    content = f.read()

content = content.replace("if(COMMAND qt_policy)\n        qt_policy(SET QTP0004 NEW)\n    endif()", "qt_policy(SET QTP0004 NEW)")

with open("CMakeLists.txt", "w") as f:
    f.write(content)
