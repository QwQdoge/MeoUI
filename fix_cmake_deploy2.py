with open("CMakeLists.txt", "r") as f:
    content = f.read()

# Try to find the exact block and replace it
import re

pattern = re.compile(r"(\s*)qt_generate_deploy_qml_app_script\(\s*TARGET MeoShowcaseDemo\s*OUTPUT_SCRIPT deploy_script\s*NO_UNSUPPORTED_PLATFORM_ERROR\s*\)\s*install\(SCRIPT \$\{deploy_script\}\)")

def replace_deploy(match):
    indent = match.group(1)
    return indent + "if(COMMAND qt_generate_deploy_qml_app_script)" + match.group(0) + indent + "endif()"

content = pattern.sub(replace_deploy, content)

with open("CMakeLists.txt", "w") as f:
    f.write(content)
