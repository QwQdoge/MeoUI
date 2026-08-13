import subprocess
import time

p = subprocess.Popen(["./build/MeoShowcaseDemo"], env={"QT_QPA_PLATFORM": "offscreen", "XDG_RUNTIME_DIR": "/tmp/runtime-jules"})
time.sleep(2)
if p.poll() is None:
    print("Success! Process started and stayed running.")
    p.kill()
else:
    print("Process exited prematurely.")
