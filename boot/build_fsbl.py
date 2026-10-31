import os
import vitis

root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
xsa = os.path.join(root, "build", "boot", "ouros.xsa")
workspace = os.path.join(root, "build", "vitis_ws")
if not os.path.isfile(xsa):
    raise FileNotFoundError(f"Missing {xsa}; run Vivado scripts/build_bitstream.tcl first")

print(f"XSA       : {xsa}")
print(f"Workspace : {workspace}")

client = vitis.create_client()
client.set_workspace(path=workspace)

platform = client.create_platform_component(
    name="ouros_platform",
    hw_design=xsa,
    os="standalone",
    cpu="psu_cortexa53_0",
    domain_name="standalone_psu_cortexa53_0",
    generate_dtb=False
)

print("Building platform and boot artifacts...")
platform.build()

print()
print("============================================")
print(" Vitis platform / FSBL build complete")
print("============================================")
