# Image attributes reference

Full vocabulary for the prompt construction step (see `SKILL.md` → "Prompt construction"). Claude draws from this list when asking the Look and Optional questions, and when interpreting free-text answers — it is a reference glossary, not a script to read verbatim. Offer a representative sample from each category in the actual chat message, not the full list; let the user type their own words at any point, preset or no preset.

## Content (from the description, not a pick-list)

Filled in from what the user already said; only ask if genuinely missing or ambiguous.

- **Subject + Action** — who/what is in frame, doing what.
- **Environment / Background** — where it's happening.
- **Subject appearance / wardrobe** — only relevant if a person/character is in frame and isn't already locked by a preset.

## Look (always asked, one compact question)

### Type/Style
Photorealistic · Hyper-realistic · Cinematic film still · Cartoon · Anime/manga · Comic book/graphic novel · Concept art · Digital art · Vector/flat illustration · Glassmorphism · Wireframe · Pixel art · Low poly · Isometric · Scandinavian design · Product photo · Interior-design render

### Mood / emotional tone
Beautiful · Bohemian · Chaotic · Cozy · Divine · Eclectic · Futuristic · Kitschy · Nostalgic · Whimsical · Dramatic · Playful · Energetic · Eerie · Triumphant · Dark · Simple · Realistic

### Lighting
Natural daylight · Golden hour/sunset · Studio lighting · Neon/night · Backlighting · Dramatic/rim-lit · Soft/diffused · Overcast/flat · Chiaroscuro · Light painting

### Color palette / tone
Vibrant/saturated · Muted/desaturated · Black and white/monochrome · Pastel · Warm tones · Cool tones · High-contrast · Sepia/vintage · Iridescent · Ultraviolet

## Optional (ask explicitly per category — "want to set any of these, or skip?" — never fill silently)

### 1. Detail level / visual intensity
Highly detailed/intricate · Medium detail · Clean/minimal · Hyper-realistic

### 2. Composition
Centered · Rule of thirds · Negative space · Symmetrical · Leading lines · Framed/foreground element

### 3. Effects
Double exposure · Grainy film · Misty/foggy · Faded/antique photo · Color explosion · Paint splattering · Photo manipulation · Color-shift art · Bioluminescent · Underwater · Otherworldly · Digital fractal · Geometric pen overlay · Gomori photography

### 4. Camera angle / shot type
Close-up · Medium shot · Wide/establishing shot · POV (first-person) · Low angle · High/aerial angle · Over-the-shoulder · Dutch/tilted angle

### 5. Lens / depth of field
Wide-angle · Standard · Telephoto · Macro · Fisheye · Shallow depth of field/bokeh · Deep focus · Tilt-shift

### 6. Medium
Photograph · 3D render/CGI · Digital illustration/painting · Watercolor · Oil painting · Acrylic painting · Fresco · Palette-knife painting · Pencil sketch/line art · Ink drawing · Doodle drawing · Charcoal drawing · Linocut · Halftone print · Stippling · Claymation/stop-motion

### 7. Movement
Art Deco · Art Nouveau · Baroque · Bauhaus · Constructivism · Cubism · Cyberpunk · Fantasy · Fauvism · Film noir · Glitch art · Impressionism · Industrial · Maximalism · Minimalism · Modern art/Modernism · Neo-expressionism · Pointillism · Pop art · Psychedelic · Science fiction · Steampunk · Surrealism · Synthetism · Synthwave · Vaporwave

### 8. Material / texture
Fabric · Fur · Marble · Metal · Wood carving · Origami · Paper mâché · Layered paper · Yarn · 3D pattern · Guilloche pattern · Polka-dot pattern · Abstract/strange pattern

## Not asked (locked elsewhere)

Aspect ratio and resolution are fixed by the skill (9:16, 1080x1920 — see "Resolution floor" in `SKILL.md`) and never offered as a choice here.
