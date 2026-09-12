"""마링이를 여러 각도에서 렌더링. blend 파일을 열어 카메라를 궤도 회전시킨다.
실행: blender --background output/maring.blend --python render_views.py -- <출력디렉터리>
"""
import bpy
import sys
import math
from mathutils import Vector

argv = sys.argv
argv = argv[argv.index("--") + 1:] if "--" in argv else []
out_dir = argv[0] if argv else "output"

scene = bpy.context.scene
cam = bpy.data.objects.get("Camera")
TARGET = Vector((0, 0, 0.55))
DIST = 2.2

scene.render.resolution_x = 700
scene.render.resolution_y = 700

for label, deg in (("front", 0), ("q34", 35), ("side", 90), ("back", 180)):
    a = math.radians(deg)
    pos = Vector((math.sin(a) * DIST, -math.cos(a) * DIST, 0.58))
    cam.location = pos
    cam.rotation_euler = (TARGET - pos).to_track_quat('-Z', 'Y').to_euler()
    scene.render.filepath = f"{out_dir}/view_{label}.png"
    bpy.ops.render.render(write_still=True)
    print(f"[OK] {label}")
