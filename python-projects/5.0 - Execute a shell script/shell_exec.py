import os
import subprocess

# Script execution
script_dir = os.path.dirname(__file__)
script_aboslute_path = os.path.join( script_dir + "dockerinstall_ubuntu_ony.sh")

try:
    result = subprocess.run(['sh', script_aboslute_path], check=True)
    print("Shell script executed successfully!")
except subprocess.CalledProcessError as e:
    print(f"Shell script failed with return code {e.returncode}")
except Exception as e:
    print(f"An error occurred: {e}")