"""
마링(Maring) 3D 캐릭터 생성 — 레퍼런스(maring_img/) 기반

핵심 접근:
- 몸통은 노이즈 디스플레이스가 아니라 **메타볼 클러스터**. 동글동글한 방울들이
  부드럽게 융합돼 레퍼런스의 "뭉게뭉게 거품 덩어리" 실루엣이 나온다.
- 눈/볼/입/하트는 몸통 표면에 레이캐스트해서 정확히 밀착 배치한다.
- 눈은 어두운 베이스 + 보라 홍채 + 흰 하이라이트 2개 구조 (검은 구멍처럼 보이지 않게).

실행:
  blender --background --python build_maring.py -- --out output/maring.glb --blend output/maring.blend
"""
import bpy
import sys
import math
import os
from mathutils import Vector

# ---------- CLI ----------
argv = sys.argv
argv = argv[argv.index("--") + 1:] if "--" in argv else []
out_glb, out_blend = "output/maring.glb", "output/maring.blend"
_i = 0
while _i < len(argv):
    if argv[_i] == "--out" and _i + 1 < len(argv):
        out_glb = argv[_i + 1]; _i += 2
    elif argv[_i] == "--blend" and _i + 1 < len(argv):
        out_blend = argv[_i + 1]; _i += 2
    else:
        _i += 1

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene

# ---------- 치수 (레퍼런스 이미지 비율에서 측정) ----------
BODY_W, BODY_D, BODY_H = 1.00, 0.95, 1.00
BODY_Z = BODY_H / 2.0        # 바닥이 z=0 에 오도록 몸통 중심을 올림
HALF_H = BODY_H / 2.0
GRAD_POW = 0.68     # <1 이라야 위쪽 흰 영역이 넓어진다

# ---------- 팔레트 ----------
def srgb(hexstr):
    """레퍼런스에서 스포이드로 딴 sRGB 색을 Blender 가 쓰는 선형 색으로 변환."""
    h = hexstr.lstrip("#")
    out = []
    for i in (0, 2, 4):
        c = int(h[i:i + 2], 16) / 255.0
        out.append(c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4)
    return tuple(out) + (1.0,)


# maring_img/ 레퍼런스에서 직접 추출한 값 (추측 금지)
COL_BODY_TOP = srgb("#F3DFF0")   # 정수리
COL_BODY_BOT = srgb("#9895E5")   # 바닥 (페리윙클)
COL_EYE      = srgb("#100C34")
COL_IRIS     = srgb("#8878D8")
COL_BROW     = srgb("#BCB0E2")
COL_BLUSH    = srgb("#F2A0C0")
COL_MOUTH    = srgb("#2A2050")
COL_HEART    = srgb("#FFF2FA")
COL_HALO     = srgb("#C9A8EE")


# ================= 유틸 =================
def set_in(bsdf, name, value):
    if name in bsdf.inputs:
        bsdf.inputs[name].default_value = value


def make_material(name, color, roughness=0.5, emission=None, emission_strength=0.0,
                  alpha=1.0, sss=0.0, matte=False):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    if alpha < 1.0:
        mat.blend_method = 'BLEND'
        mat.show_transparent_back = False
    bsdf = mat.node_tree.nodes["Principled BSDF"]
    set_in(bsdf, "Base Color", color)
    set_in(bsdf, "Roughness", roughness)
    set_in(bsdf, "Alpha", alpha)
    if sss > 0.0:
        set_in(bsdf, "Subsurface Weight", sss)
        set_in(bsdf, "Subsurface Radius", (0.5, 0.35, 0.6))
        set_in(bsdf, "Subsurface Scale", 0.12)
    if matte:
        # 스페큘러가 남아 있으면 방울 하나하나가 젖은 것처럼 번들거려 징그러워진다
        set_in(bsdf, "Specular IOR Level", 0.06)
        set_in(bsdf, "Specular Tint", (1, 1, 1, 1))
    if emission:
        set_in(bsdf, "Emission Color", emission)
        set_in(bsdf, "Emission Strength", emission_strength)
    return mat, bsdf


def shade_smooth(obj):
    for p in obj.data.polygons:
        p.use_smooth = True


def convert_to_mesh(obj):
    """--background 에서는 bpy.ops.object.convert 가 UI 컨텍스트를 요구하므로
    depsgraph 로 평가된 지오메트리를 뽑아 새 메시 오브젝트로 교체한다."""
    bpy.context.view_layer.update()
    dg = bpy.context.evaluated_depsgraph_get()
    new_mesh = bpy.data.meshes.new_from_object(obj.evaluated_get(dg))
    name, mw, old_data, old_type = obj.name, obj.matrix_world.copy(), obj.data, obj.type
    bpy.data.objects.remove(obj, do_unlink=True)
    if old_type == 'CURVE':
        bpy.data.curves.remove(old_data)
    elif old_type == 'META':
        bpy.data.metaballs.remove(old_data)
    new_obj = bpy.data.objects.new(name, new_mesh)
    new_obj.matrix_world = mw
    bpy.context.collection.objects.link(new_obj)
    bpy.context.view_layer.objects.active = new_obj
    return new_obj


def normalize_mesh(obj, target_w, target_d, target_h):
    """메시를 원점 중심으로 옮기고 목표 치수에 맞춰 스케일 (버텍스 직접 조작)."""
    vs = obj.data.vertices
    xs = [v.co.x for v in vs]; ys = [v.co.y for v in vs]; zs = [v.co.z for v in vs]
    cx, cy, cz = (max(xs) + min(xs)) / 2, (max(ys) + min(ys)) / 2, (max(zs) + min(zs)) / 2
    sx = target_w / (max(xs) - min(xs))
    sy = target_d / (max(ys) - min(ys))
    sz = target_h / (max(zs) - min(zs))
    for v in vs:
        v.co.x = (v.co.x - cx) * sx
        v.co.y = (v.co.y - cy) * sy
        v.co.z = (v.co.z - cz) * sz


# ================= 몸통: 메타볼 클러스터 =================
bpy.ops.object.metaball_add(type='BALL', radius=0.1, location=(0, 0, 0))
mb_obj = bpy.context.active_object
mb_obj.name = "Maring_Body"
mb = mb_obj.data
mb.resolution = 0.016
mb.render_resolution = 0.016
mb.threshold = 0.60

elements = []

# 코어 — 반드시 "하나". 메타볼 필드는 합산되므로 코어를 여러 개 쌓으면
# 필드가 부풀어 로브를 통째로 삼켜 매끈한 물방울이 돼버린다.
# BALL 요소의 실제 표면 반경 ≈ radius * 0.575 (stiffness 2, threshold 0.6).
CORE_R = 0.80                      # → 표면 반경 약 0.46
elements += [((0.00, 0.00, 0.00), CORE_R)]

# 로브(방울) — 코어 표면 근처에 얹어 잔잔한 융기를 만든다
LOBE_N = 104
LOBE_R = 0.126
ELL = (0.47, 0.45, 0.45)          # 로브가 배치되는 타원체 반경
GOLDEN = math.pi * (3.0 - math.sqrt(5.0))
for k in range(LOBE_N):
    zz = 1.0 - (k / (LOBE_N - 1.0)) * 2.0
    rr = math.sqrt(max(0.0, 1.0 - zz * zz))
    phi = k * GOLDEN
    dx, dy, dz = math.cos(phi) * rr, math.sin(phi) * rr, zz
    # 얼굴 정중앙은 눈/입이 앉을 자리라 매끈하게 남긴다
    if dy < -0.74 and -0.50 < dz < 0.30:
        continue
    elements.append(((dx * ELL[0], dy * ELL[1], 0.01 + dz * ELL[2]), LOBE_R))

# 팔·발은 메타볼에 넣으면 필드에 녹아 실루엣에서 사라진다.
# 레퍼런스처럼 또렷한 방울로 보이도록 아래에서 별도 오브젝트로 만든다.

mb.elements[0].co = Vector(elements[0][0])
mb.elements[0].radius = elements[0][1]
for co, r in elements[1:]:
    el = mb.elements.new(type='BALL')
    el.co = Vector(co)
    el.radius = r

body = convert_to_mesh(mb_obj)
normalize_mesh(body, BODY_W, BODY_D, BODY_H)
body.location = (0, 0, BODY_Z)
shade_smooth(body)

# 위→아래 그라데이션을 버텍스 컬러로 (GLB 로도 그대로 나감)
attr = body.data.color_attributes.new(name="Col", type='FLOAT_COLOR', domain='POINT')
for idx, v in enumerate(body.data.vertices):
    t = min(1.0, max(0.0, (v.co.z + HALF_H) / BODY_H))
    t = t ** GRAD_POW
    attr.data[idx].color = tuple(
        COL_BODY_BOT[c] + (COL_BODY_TOP[c] - COL_BODY_BOT[c]) * t for c in range(3)
    ) + (1.0,)

body_mat, body_bsdf = make_material("Body", COL_BODY_TOP, roughness=0.90, sss=0.32, matte=True)
_nt = body_mat.node_tree
_attr_node = _nt.nodes.new("ShaderNodeAttribute")
_attr_node.attribute_type = 'GEOMETRY'
_attr_node.attribute_name = "Col"
_nt.links.new(_attr_node.outputs["Color"], body_bsdf.inputs["Base Color"])
body.data.materials.append(body_mat)


# ================= 표면 배치 헬퍼 =================
def front_surface(x, z_world):
    """정면(-Y)에서 몸통으로 레이캐스트해 표면 위치·법선을 얻는다(월드 좌표)."""
    origin = Vector((x, -3.0, z_world - BODY_Z))
    hit, loc, nrm, _ = body.ray_cast(origin, Vector((0, 1, 0)))
    if not hit:
        raise RuntimeError(f"표면을 찾지 못함: x={x}, z={z_world}")
    return Vector((loc.x, loc.y, loc.z + BODY_Z)), nrm.normalized()


def place(obj, x, z_world, offset=0.0):
    """오브젝트를 표면에 밀착시키고 법선 방향으로 정렬. (위치, 법선, 회전) 반환."""
    pos, nrm = front_surface(x, z_world)
    quat = Vector((0, -1, 0)).rotation_difference(nrm)
    obj.rotation_mode = 'QUATERNION'
    obj.rotation_quaternion = quat
    obj.location = pos + nrm * offset
    return pos + nrm * offset, nrm, quat


# ================= 팔·발 (별도 방울) =================
def body_color_at(z_world):
    """몸통 그라데이션과 같은 색을 해당 높이에서 뽑아 팔·발에 쓴다."""
    t = min(1.0, max(0.0, z_world / BODY_H)) ** GRAD_POW
    return tuple(COL_BODY_BOT[c] + (COL_BODY_TOP[c] - COL_BODY_BOT[c]) * t
                 for c in range(3)) + (1.0,)


for side in (-1, 1):
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.116, segments=40, ring_count=24,
                                         location=(0.452 * side, -0.06, 0.392))
    arm = bpy.context.active_object
    arm.name = f"Maring_Arm_{'R' if side > 0 else 'L'}"
    arm.scale = (1.0, 0.95, 1.05)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    shade_smooth(arm)
    arm.data.materials.append(
        make_material(f"Arm{side}", body_color_at(0.400), roughness=0.90, sss=0.32, matte=True)[0])

for side in (-1, 1):
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.092, segments=36, ring_count=20,
                                         location=(0.150 * side, -0.19, 0.048))
    foot = bpy.context.active_object
    foot.name = f"Maring_Foot_{'R' if side > 0 else 'L'}"
    foot.scale = (1.30, 1.0, 0.55)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    shade_smooth(foot)
    foot.data.materials.append(
        make_material(f"Foot{side}", body_color_at(0.230), roughness=0.90, sss=0.32, matte=True)[0])


# ================= 눈 =================
# 레퍼런스 눈을 확대해 보면 '검은 타원 + 흰 점'이 아니라 부드럽게 블렌딩된
# 그라데이션이다. 이걸 딱딱한 원판으로 쌓으면 눈이 반쯤 뒤집힌 것처럼 보여
# 캐릭터가 섬뜩해진다. → 버텍스 컬러로 매끄럽게 칠한다.
#   바깥 남보라(#1A0C4C) · 중앙 동공(#060438) · 아래쪽 글로우(#BD99D2)
# 그 위에 흰 테두리 링과 하이라이트 2개만 별도 지오메트리로 얹는다.
EYE_X, EYE_Z = 0.155, 0.522
EYE_R = 0.106
EYE_FLAT = 0.22          # 법선 방향 납작함 (표면에 붙은 스티커처럼)
EYE_ASPECT = 1.05        # 거의 정원 — 세로로 길면 인상이 사나워진다

EYE_OUTER = srgb("#1A0C4C")
EYE_PUPIL = srgb("#060438")
EYE_GLOW  = srgb("#BD99D2")

rim_mat, _ = make_material("EyeRim", srgb("#FFFFFF"), roughness=0.45)
hl_mat, _ = make_material("EyeHL", srgb("#F7F6FB"), roughness=0.06,
                          emission=srgb("#FFFFFF"), emission_strength=0.25)


def clamp01(v):
    return 0.0 if v < 0.0 else (1.0 if v > 1.0 else v)


def smoothstep(e0, e1, x):
    t = clamp01((x - e0) / (e1 - e0))
    return t * t * (3.0 - 2.0 * t)


def apply_vertex_colors(obj, color_fn, mat_name, **mat_kw):
    """정점 위치별로 색을 칠하고 Attribute 노드로 연결. GLB 로도 그대로 나간다."""
    attr = obj.data.color_attributes.new(name="Col", type='FLOAT_COLOR', domain='POINT')
    for i, v in enumerate(obj.data.vertices):
        attr.data[i].color = tuple(color_fn(v.co)[:3]) + (1.0,)
    mat, bsdf = make_material(mat_name, (1, 1, 1, 1), **mat_kw)
    nt = mat.node_tree
    node = nt.nodes.new("ShaderNodeAttribute")
    node.attribute_type = 'GEOMETRY'
    node.attribute_name = "Col"
    nt.links.new(node.outputs["Color"], bsdf.inputs["Base Color"])
    obj.data.materials.append(mat)
    return mat


def eye_gradient(co):
    """눈 안쪽 색: 중앙은 진하고, 아래쪽 가장자리로 갈수록 밝은 보라."""
    rx = co.x / EYE_R
    rz = co.z / (EYE_R * EYE_ASPECT)
    r = math.sqrt(rx * rx + rz * rz)
    k = smoothstep(0.0, 0.62, r)                       # 0=중심 1=바깥
    col = [EYE_PUPIL[j] + (EYE_OUTER[j] - EYE_PUPIL[j]) * k for j in range(3)]
    g = smoothstep(0.30, 0.95, -rz) * 0.85             # 아래쪽만 밝게
    return [col[j] + (EYE_GLOW[j] - col[j]) * g for j in range(3)]


def eye_front(dx, dz, half_depth):
    """납작한 렌즈의 앞면 깊이 — 윗층을 이보다 앞에 둬야 파묻히지 않는다."""
    k = 1.0 - (dx / EYE_R) ** 2 - (dz / (EYE_R * EYE_ASPECT)) ** 2
    return half_depth * math.sqrt(max(0.0, k))


EYE_HALF_DEPTH = EYE_R * EYE_FLAT

for side in (-1, 1):
    tag = 'R' if side > 0 else 'L'
    anchor, _nrm = front_surface(EYE_X * side, EYE_Z)
    quat = Vector((0, -1, 0)).rotation_difference(_nrm)

    def add_lens(name, radius, flat, dx=0.0, dz=0.0, dy=0.0, aspect=1.0, segs=44):
        bpy.ops.mesh.primitive_uv_sphere_add(radius=radius, segments=segs,
                                             ring_count=max(14, segs // 2))
        o = bpy.context.active_object
        o.name = name
        o.scale = (1.0, flat, aspect)
        bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
        shade_smooth(o)
        o.rotation_mode = 'QUATERNION'
        o.rotation_quaternion = quat
        # 로컬 -Y 가 법선(바깥) 방향이므로 dy 가 클수록 앞으로 나온다
        o.location = anchor + quat @ Vector((dx, -dy, dz))
        return o

    # 1) 흰 테두리 — 바탕보다 크되 훨씬 납작해서 가장자리에서만 삐져나온다
    rim = add_lens(f"Maring_EyeRim_{tag}", EYE_R * 1.09, 0.100,
                   dy=-0.005, aspect=EYE_ASPECT, segs=48)
    rim.data.materials.append(rim_mat)

    # 2) 눈 바탕 — 그라데이션은 지오메트리가 아니라 버텍스 컬러로
    eye = add_lens(f"Maring_Eye_{tag}", EYE_R, EYE_FLAT,
                   dy=-0.005, aspect=EYE_ASPECT, segs=56)
    apply_vertex_colors(eye, eye_gradient, f"EyeGrad_{tag}", roughness=0.24)

    # 3) 하이라이트 — 광원이 하나이므로 두 눈 모두 같은 쪽에 큰 것이 온다
    for hl_name, hl_r, hl_dx, hl_dz in (
        ("Big",   EYE_R * 0.27,  EYE_R * 0.32,  EYE_R * 0.36),
        ("Small", EYE_R * 0.125, -EYE_R * 0.33, EYE_R * 0.24),
    ):
        hl = add_lens(f"Maring_EyeHL{hl_name}_{tag}", hl_r, 0.32,
                      dx=hl_dx, dz=hl_dz,
                      dy=eye_front(hl_dx, hl_dz, EYE_HALF_DEPTH) - 0.005 + 0.006,
                      segs=28)
        hl.data.materials.append(hl_mat)


# ================= 눈썹 (작은 보라 대시) =================
brow_mat, _ = make_material("Brow", COL_BROW, roughness=0.5)
for side in (-1, 1):
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.044, segments=24, ring_count=14)
    brow = bpy.context.active_object
    brow.name = f"Maring_Brow_{'R' if side > 0 else 'L'}"
    brow.scale = (1.0, 0.20, 0.24)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    shade_smooth(brow)
    brow.data.materials.append(brow_mat)
    place(brow, 0.172 * side, 0.690, offset=0.005)


# ================= 볼터치 =================
blush_mat, _ = make_material("Blush", COL_BLUSH, roughness=0.85, alpha=0.62, matte=True)
for side in (-1, 1):
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.068, segments=28, ring_count=18)
    blush = bpy.context.active_object
    blush.name = f"Maring_Blush_{'R' if side > 0 else 'L'}"
    blush.scale = (1.0, 0.10, 0.62)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    shade_smooth(blush)
    blush.data.materials.append(blush_mat)
    place(blush, 0.318 * side, 0.474, offset=0.006)


# ================= 입 (작은 미소) =================
mouth_curve = bpy.data.curves.new("MouthCurve", type='CURVE')
mouth_curve.dimensions = '3D'
mouth_curve.bevel_depth = 0.0115
mouth_curve.bevel_resolution = 4
sp = mouth_curve.splines.new('BEZIER')
sp.bezier_points.add(2)
for bp, co in zip(sp.bezier_points, [(-0.044, 0, 0.013), (0.0, 0, -0.013), (0.044, 0, 0.013)]):
    bp.co = co
    bp.handle_left_type = 'AUTO'
    bp.handle_right_type = 'AUTO'
mouth = bpy.data.objects.new("Maring_Mouth", mouth_curve)
bpy.context.collection.objects.link(mouth)
bpy.context.view_layer.objects.active = mouth
mouth = convert_to_mesh(mouth)
shade_smooth(mouth)
mouth.data.materials.append(make_material("Mouth", COL_MOUTH, roughness=0.35)[0])
place(mouth, 0.0, 0.404, offset=0.010)


# ================= 가슴 하트 (빛나는 아웃라인) =================
# 평평한 하트를 배에 붙이면 곡면이 물러나며 가장자리가 파묻힌다.
# 각 점을 몸통 표면에 투영해 곡면을 따라 휘게 만든다.
HEART_W = 0.238
HEART_Z = 0.248
HEART_LIFT = 0.013

_pts = []
for k in range(180):
    t = 2.0 * math.pi * k / 180.0
    _pts.append((16 * math.sin(t) ** 3,
                 13 * math.cos(t) - 5 * math.cos(2 * t) - 2 * math.cos(3 * t) - math.cos(4 * t)))
_xs = [p[0] for p in _pts]; _ys = [p[1] for p in _pts]
_cx, _cy = (max(_xs) + min(_xs)) / 2, (max(_ys) + min(_ys)) / 2
_s = HEART_W / (max(_xs) - min(_xs))

heart_curve = bpy.data.curves.new("HeartCurve", type='CURVE')
heart_curve.dimensions = '3D'
heart_curve.bevel_depth = 0.0115
heart_curve.bevel_resolution = 4
hsp = heart_curve.splines.new('POLY')
hsp.points.add(len(_pts) - 1)
for pt, (hx, hy) in zip(hsp.points, _pts):
    wx = (hx - _cx) * _s
    wz = HEART_Z + (hy - _cy) * _s
    spos, snrm = front_surface(wx, wz)
    p = spos + snrm * HEART_LIFT
    pt.co = (p.x, p.y, p.z, 1.0)
hsp.use_cyclic_u = True

heart = bpy.data.objects.new("Maring_Heart", heart_curve)
bpy.context.collection.objects.link(heart)
bpy.context.view_layer.objects.active = heart
heart = convert_to_mesh(heart)
shade_smooth(heart)
heart.data.materials.append(
    make_material("Heart", COL_HEART, roughness=0.2,
                  emission=srgb("#FFD9EC"), emission_strength=1.0)[0]
)
# 곡선 점을 이미 월드 좌표로 찍었으므로 place() 로 다시 옮기지 않는다.


# ================= 할로 (감정 엔젤링) =================
bpy.ops.mesh.primitive_torus_add(major_radius=0.198, minor_radius=0.023,
                                 major_segments=64, minor_segments=16,
                                 location=(0, -0.02, 1.055))
halo = bpy.context.active_object
halo.name = "Maring_Halo"
halo.rotation_euler = (math.radians(22), 0, 0)
shade_smooth(halo)
halo.data.materials.append(
    make_material("Halo", COL_HALO, roughness=0.25,
                  emission=COL_HALO, emission_strength=0.22)[0]
)


# ================= 그룹핑 =================
root = bpy.data.objects.new("Maring", None)
bpy.context.collection.objects.link(root)
for o in list(bpy.context.collection.objects):
    if o is not root and o.type == 'MESH':
        o.parent = root


# ================= 라이트 & 카메라 =================
TARGET = Vector((0, 0, 0.55))


def add_area(loc, energy, size):
    bpy.ops.object.light_add(type='AREA', location=loc)
    lt = bpy.context.active_object
    lt.data.energy = energy
    lt.data.size = size
    lt.rotation_euler = (TARGET - Vector(loc)).to_track_quat('-Z', 'Y').to_euler()
    return lt


add_area((-1.7, -2.3, 1.7), 88, 3.2)    # 키
add_area((1.9, -1.7, 0.5), 34, 3.0)     # 필
add_area((0.0, 1.9, 1.9), 40, 2.5)      # 림

bpy.ops.object.camera_add(location=(0, -2.2, 0.58), rotation=(math.radians(90), 0, 0))
scene.camera = bpy.context.active_object

try:
    scene.render.engine = 'BLENDER_EEVEE_NEXT'
except TypeError:
    scene.render.engine = 'BLENDER_EEVEE'
scene.render.film_transparent = True
scene.render.resolution_x = 1000
scene.render.resolution_y = 1000

scene.world = bpy.data.worlds.new("World")
scene.world.use_nodes = True
_bg = scene.world.node_tree.nodes.get("Background")
if _bg:
    _bg.inputs[0].default_value = (0.90, 0.89, 1.0, 1.0)
    _bg.inputs[1].default_value = 0.38

# AgX 톤매핑은 파스텔을 회색으로 눌러버린다
scene.view_settings.view_transform = 'Standard'
scene.view_settings.look = 'None'


# ================= 저장 & 내보내기 =================
os.makedirs(os.path.dirname(out_blend) or ".", exist_ok=True)
os.makedirs(os.path.dirname(out_glb) or ".", exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=out_blend)
bpy.ops.export_scene.gltf(filepath=out_glb, export_format='GLB',
                          use_selection=False, export_apply=True, export_yup=True)
print(f"[OK] exported: {out_glb}")
print(f"[OK] blend saved: {out_blend}")
print(f"[INFO] body verts: {len(body.data.vertices)}")
