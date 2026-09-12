# Maring basic v2 image

Created with the built-in image generation/editing tool.

Output: `maring_basic_v2.png`

Purpose: Front-facing 2.5D revision based on the original 2D character. This is a raster image, not an updated GLB or Blender model. Existing original assets are preserved.

## Initial prompt

Use case: identity-preserve / style-transfer.
Asset type: Maring mobile app character PNG, refined front-view 2.5D character art.
Input images: Image 1 (maring_basic.png) is the AUTHORITATIVE character design and identity reference. Image 2 (maring_preview.png) is the flawed 3D render to correct. It is NOT the design authority.
Primary request: Produce one corrected high-resolution front-facing full-body Maring image, faithfully restoring Image 1's character identity while giving it restrained, soft 2.5D volume. Match Image 1 very closely in outer silhouette, eye size and spacing, face position, arm/foot position, expression, palette, halo, and chest emblem. Do not blend the bad proportions of Image 2 into the result.
Subject: one short round pear/egg-shaped pastel cloud-jelly companion with a slightly narrower crown and fuller lower body; small rounded hands placed toward the front edges of the lower torso, two tiny flattened shiny feet. Many small SHALLOW translucent cloud scallops across a smooth underlying body, particularly a calm flatter facial area; no giant protruding lobes. Body pearl pink-white on top graduating into luminous periwinkle-lavender below. Translucent pearly softness, subtle specular glints and sparse tiny white star sparkles as in Image 1.
Face: preserve Image 1's small oval jewel-like dark navy-purple eyes at their original relative scale (each eye roughly 14 percent of body width), delicate pale outline, layered pink-violet iris glow and small multiple white and blue highlights. Wide gentle spacing. Tiny upward curved two-lobed w-shaped smile, softly tilted short lilac brows. Soft blush under outer eye corners with three small diagonal light-pink strokes, no opaque circular cheek disks.
Chest: trace the distinctive pink-white luminous emblem from Image 1: soft scalloped heart/cloud outline with a short round tab protruding from each side at mid-height, lavender-pink inner heart and a small central sparkle. Preserve its exact visual identity, not a generic wire heart. Thin lavender halo with inner and outer luminous edge lines forming a horizontal ellipse floating just above the crown, matching Image 1 proportions.
Composition: single character only, centered, straight-on at face height, entire halo and feet visible, generous clean transparent margin, square canvas, character about 85% of canvas height.
Background: genuinely transparent alpha, no painted checkerboard, no floor/environment, only a very soft small translucent contact shadow below feet.
Lighting: soft bright diffuse pastel illumination and restrained bloom, preserve saturation and facial readability at app size.
Constraints: no text, labels, comparison panels, additional characters, props, ears, wool/fur, harsh grooves, giant eyes, thick white eye rims, plastic clay finish or dark ambient occlusion. This must be unmistakably the original Maring in Image 1.

## Background refinement prompt

Use case: background-extraction.
Edit target: the provided Maring image.
Remove ONLY the entire baked-in gray and white checkerboard background and the floor shadow. Return a clean character cutout on a genuinely TRANSPARENT alpha background. All pixels outside the character and within the open hole of its floating halo must be alpha transparent. DO NOT paint or render a checkerboard to represent transparency. No white or gray backdrop. Preserve precisely the character, face, expression, proportions, eyes, pearlescent pink/lavender colors, small cloud lobes, chest emblem, hands, feet, halo, all internal highlights. Keep its existing position and framing. Do not redesign or restyle anything. Preserve clean anti-aliased edges. Output an RGBA PNG with actual alpha transparency.
