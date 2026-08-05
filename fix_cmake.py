with open("CMakeLists.txt", "r") as f:
    content = f.read()

content = content.replace("qt_policy(SET QTP0001 NEW)", "if(COMMAND qt_policy)\n    qt_policy(SET QTP0001 NEW)\nendif()")

with open("CMakeLists.txt", "w") as f:
    f.write(content)
