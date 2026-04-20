# VR Class Study Guide: 3D Concepts & Pipeline

This guide expands core theoretical and practical concepts for VR development. Each topic includes definitions, key formulas, and practical notes using the left-hand coordinate system (LHCS) your class uses.

---

## Intro & VR Fundamentals
- Overview: definitions and core goals — presence, immersion, and fidelity. VR presents synthetic sensory signals (visual, audio, haptics) to create a sense of "being there".
- Key performance metrics:
    - Frame rate ($f$) and frame time: $t_{frame}=1000/f$ (ms). Target high refresh (e.g., 90Hz+) for VR to reduce motion sickness.
    - Motion‑to‑photon latency: total time from user motion to displayed update; aim for $<20$ ms when possible.
    - Jitter vs consistent frame time: constant frame time reduces judder.
- Device basics: HMD components include display(s), lenses, IMU (gyroscope/accelerometer), positional tracking system, and optics that map display to eye.

## Light, Optics, and HMD Design
- Display & optics basics:
    - Field of view (FOV): angular extent visible to eye; larger FOV increases immersion but demands more pixels.
    - Resolution per eye and pixels-per-degree (PPD): approximate $\mathrm{PPD}\approx\dfrac{\text{pixels}_\text{horizontal}}{\text{FOV}_\text{deg}}$ (useful for estimating angular resolution).
    - Visual angle: $\theta = 2\arctan\left(\dfrac{s}{2d}\right)$ (radians), convert to degrees by $\theta_\text{deg}=\theta\cdot\dfrac{180}{\pi}$, where $s$ is object size and $d$ distance.
- Optical issues to know (exam‑style): lens distortion (barrel), chromatic aberration, Fresnel optics artifacts, modulation transfer (MTF) reducing contrast at high spatial frequencies, and the need for pre‑warp/distortion correction in rendering.
- HMD tradeoffs: IPD adjustment, sweet‑spot (optical center), vergence–accommodation conflict (fixed focal plane vs changing vergence), persistence and motion blur, and thermal/weight/user comfort concerns.
- Light basics: inverse‑square falloff for point sources $I\propto1/d^2$ (qualitative is sufficient unless otherwise asked).

## Human Vision — Physiology
- Photoreceptors: cones (color, photopic vision, concentrated in fovea) and rods (low‑light, peripheral). Fovea = high acuity center of vision.
- Visual acuity: human foveal acuity ~1 arcminute (1/60°); practical rule: very small angular features below this limit are hard to resolve.
- Color: trichromatic (three cone types — short/mid/long wavelengths) — color perception depends on cone responses and lighting.
- Depth cues (qualitative): binocular disparity (stereopsis), motion parallax, accommodation (lens focus), convergence, occlusion, perspective, and shading.

## Human Vision — Temporal
- Temporal resolution: critical flicker fusion (CFF) depends on luminance and stimulus, typical thresholds ~50–90 Hz; VR refresh targets (90Hz+) reduce perceptible flicker and latency effects.
- Motion perception: smooth pursuit vs saccades; temporal aliasing and judder occur when update rate is too low relative to motion.
- Latency implications: motion‑to‑photon latency and low sample rates increase perceived lag and sickness; predictive tracking and higher sampling rates mitigate this.
- Comfort mitigations: vignetting, reduced acceleration, snap turns, and high frame rates help reduce vection‑induced discomfort.

## Transformations (Model / World / View / Projection)
- Overview: Transformations are represented as 4x4 homogeneous matrices combining translation, rotation, and scale so we can chain transforms and apply them to 3D points in homogeneous coordinates $[x,y,z,1]^T$.
- Common 4x4 forms:
        - Translation:

            $$
            T(t_x,t_y,t_z)=\begin{bmatrix}
            1 & 0 & 0 & t_x \\
            0 & 1 & 0 & t_y \\
            0 & 0 & 1 & t_z \\
            0 & 0 & 0 & 1
            \end{bmatrix}
            $$

        - Uniform Scale:

            $$
            S(s)=\begin{bmatrix}
            s & 0 & 0 & 0 \\
            0 & s & 0 & 0 \\
            0 & 0 & s & 0 \\
            0 & 0 & 0 & 1
            \end{bmatrix}
            $$

        - Rotation about X (angle $\theta$):

            $$
            R_x(\theta)=\begin{bmatrix}
            1 & 0 & 0 & 0 \\
            0 & \cos\theta & -\sin\theta & 0 \\
            0 & \sin\theta & \cos\theta & 0 \\
            0 & 0 & 0 & 1
            \end{bmatrix}
            $$
            (similarly for $R_y,R_z$).
- Composition: Apply right-to-left to a column vector: $v_{world}=M_{model}\\,v_{model}$, and full pipeline $v_{clip}=M_{proj}\\,M_{view}\\,M_{model}\\,v_{model}$.
- Practical notes:
    - Use row- or column-major consistently (Unity uses column-major and column vectors).
    - For hierarchical objects, local-to-world is the product of parent transforms.
    - In LHCS, forward is +Z — mind handedness when building view matrices.

---

## Quaternions
- Instructor note: the professor omitted Quaternions from the review slides but confirmed you must know them. Study the items below; you do NOT need to convert between representations for this exam — only know how they are represented and the core principles/formulas.

- Rotation matrices: 3×3 orthogonal matrices used to rotate vectors about the origin. Properties: $R^T R = I$, $\det(R)=1$.
    - Single-axis forms (angle $\theta$):
        $$R_x(\theta)=\begin{bmatrix}1&0&0\\0&\cos\theta&-\sin\theta\\0&\sin\theta&\cos\theta\end{bmatrix},\quad R_y(\theta)=\begin{bmatrix}\cos\theta&0&\sin\theta\\0&1&0\\-\sin\theta&0&\cos\theta\end{bmatrix},$$
        $$R_z(\theta)=\begin{bmatrix}\cos\theta&-\sin\theta&0\\\sin\theta&\cos\theta&0\\0&0&1\end{bmatrix}$$

- Linear interpolation (LERP): simple pointwise interpolation between vectors; not ideal for rotations because it does not preserve constant angular velocity or unit-length.
    - Formula: $\mathrm{LERP}(v_0,v_1,t)=(1-t)v_0 + t v_1$, $t\in[0,1]$.

- Euler angles: three ordered rotations (commonly roll, pitch, yaw). Order matters (e.g., Z–Y–X vs X–Y–Z) and changes the resulting rotation.
    - Composition: $R = R_{order}(\alpha,\beta,\gamma)$ where each $R_*$ is a single-axis rotation.

- Roll / Pitch / Yaw (LHCS): semantic names for Euler angles. In this course: +X = right, +Y = up, +Z = forward.
    - roll: rotation about the forward axis (+Z)
    - pitch: rotation about the right axis (+X)
    - yaw: rotation about the up axis (+Y)

- Gimbal lock: qualitative effect where two rotation axes become collinear (e.g., pitch = ±90°) causing a loss of one degree of freedom in Euler-angle representations.

- Axis/angle: rotation represented by a unit axis vector $\mathbf{u}$ and an angle $\theta$ about that axis. The axis must be normalized; the pair $(\mathbf{u},\theta)$ uniquely describes the rotation.

- Quaternions: 4-component representation $q=(x,y,z,w)$ or $q=\langle\mathbf{v},w\rangle$ with $\mathbf{v}=(x,y,z)$; unit quaternions represent rotations.
    - Norm / normalization: $|q|=\sqrt{x^2+y^2+z^2+w^2}$; enforce $|q|=1$ for pure rotations.
    - Conjugate / inverse (unit): $q^*=(-x,-y,-z,w)$ and $q^{-1}=q^*$.
    - Rotate a vector $\mathbf{p}$ (treat as pure quaternion $(\mathbf{p},0)$):
        $$p' = q\,p\,q^{-1}$$
    - Quaternion multiplication (composition): for $q=(\mathbf{v},w)$ and $r=(\mathbf{u},s)$,
        $$q\,r = (\;w\mathbf{u} + s\mathbf{v} + \mathbf{v}\times\mathbf{u}\;,\; ws - \mathbf{v}\cdot\mathbf{u}\;)$$
    - Interpolation: Slerp for constant-speed rotational interpolation:
        $$\mathrm{Slerp}(q_0,q_1,t)=\frac{\sin((1-t)\theta)}{\sin\theta}q_0+\frac{\sin(t\theta)}{\sin\theta}q_1,\quad\cos\theta=q_0\cdot q_1$$

- Quick exam notes: know the representations and key properties (matrix orthogonality; quaternion unit norm), LERP vs Slerp tradeoffs, qualitative explanation of gimbal lock, and roll/pitch/yaw axes under LHCS. Conversions between forms are NOT required for this exam.

---

## 3D → 2D Viewing (View Transform & Camera)
- View matrix: transforms world coordinates into camera (eye) coordinates by applying the inverse of the camera's world transform: $M_{view}=M_{camera}^{-1}$.
- Camera basis (in LHCS): commonly compute right $\\mathbf{r}$, up $\\mathbf{u}$, forward $\\mathbf{f}$ (+Z forward):
    - $\\mathbf{f} = \\\mathrm{normalize}(target - eye)$
    - $\\mathbf{r} = \\\mathrm{normalize}(\\mathbf{f} \\\times up)$ (cross product uses left-hand rule here)
    - $\\mathbf{u} = \\\mathbf{r} \\\times \\\mathbf{f}$
- To unproject screen point to a world ray: transform NDC $(x_{ndc},y_{ndc},-1,1)$ by $M_{proj}^{-1}M_{view}^{-1}$ (then do homogeneous divide).

---

## Projections (Perspective & Orthographic)
- Perspective projection: maps the view-space frustum to clip space so that after the homogeneous divide $x,y$ exhibit perspective foreshortening.
    - Parameters: vertical field-of-view `fov`, aspect `a` (width/height), near `n`, far `f`.
    - Focal scale: $s = 1/\tan(\mathrm{fov}/2)$.
    - Common (LHCS, column-major) example matrix (conventions vary by API):
        $$M_{proj}=\begin{bmatrix}\dfrac{s}{a}&0&0&0\\0&s&0&0\\0&0&\dfrac{far}{far-near}&-\dfrac{far\cdot near}{far-near}\\0&0&1&0\end{bmatrix}$$
    - Pipeline notes:
        - Clip-space: $v_{clip}=M_{proj}\,v_{view}$ (homogeneous).
        - Perspective divide: $v_{ndc}=v_{clip}/v_{clip}.w$ to produce NDC coordinates.
        - Viewport transform: $x_{screen}=(x_{ndc}+1)/2\cdot\text{width}$, $y_{screen}=(1-y_{ndc})/2\cdot\text{height}$ (Y convention may vary).
        - Depth: $z_{ndc}=z_{clip}/w_{clip}$. NDC z-range depends on API (OpenGL uses $[-1,1]$, DirectX uses $[0,1]$).
        - Precision: perspective depth is non-linear (more precision near the near plane). Large `far/near` ratios cause z-fighting; mitigate by moving `near` as far out as acceptable, using higher precision depth or reverse-Z techniques.
    - Common issues: frustum culling, clipping at the near plane, z-fighting, and API-dependent sign/scale conventions (don't rely on memorized signs; understand the pipeline).

- Orthographic (parallel) projection: linear mapping of a rectangular box $[l,r]\times[b,t]\times[n,f]$ to clip space; preserves sizes and parallelism (no perspective foreshortening).
    - Example (LHCS, column-major) mapping z to $[0,1]$:
        $$M_{ortho}=\begin{bmatrix}\dfrac{2}{r-l}&0&0&-\dfrac{r+l}{r-l}\\0&\dfrac{2}{t-b}&0&-\dfrac{t+b}{t-b}\\0&0&\dfrac{1}{far-near}&-\dfrac{near}{far-near}\\0&0&0&1\end{bmatrix}$$
    - Pipeline: $v_{clip}=M_{ortho}\,v_{view}$. Because $w=1$, no perspective divide is required; NDC coordinates are linear with view-space coordinates.
    - Use cases: UI overlays, CAD/engineering views, shadow-map orthographic passes.

- Clipping: clipping is performed in clip space against the canonical view volume (before the divide) so attributes interpolate correctly. After dividing by $w$, coordinates are in NDC; primitives outside the $[-1,1]^3$ cube are clipped or culled.

---

## Interaction (Overview)
- Interaction stacks common in XR: input sampling → pose filtering → hit-test/selection → manipulation → haptics/feedback.
- Track poses at high sample rates and apply smoothing or predictive filters (low-latency extrapolation) to reduce perceived lag.
- Represent user controllers and hands as 6-DoF poses (position + quaternion orientation).

---

## Selection (Picking & Raycasting)
- Raycasting: cast ray from controller or camera origin along forward vector. Ray equation: $r(t)=o+td$ where $o$ is origin and $d$ normalized direction.
- Screen picking workflow: screen XY → NDC → view-space → world-space ray with inverse proj/view. Then test intersections with bounding volumes (AABB, sphere) before precise triangle tests.
- Spatial queries: use physics engine raycasts for collision-aware selection; do layer masks and distance checks for performance.
- Laser pointers vs direct touch: laser (exocentric) uses longer reach but needs clear depth cues; direct grab (egocentric) requires hand tracking and collision handling.

---

## Manipulation (Grabbing, Transforming Objects)
- Map controller pose to object transform: when grabbing, store initial object-to-controller transform $M_{oc}=M_{controller}^{-1}M_{object}$ and update object each frame: $M_{object}=M_{controller}M_{oc}$.
- For rotation, prefer quaternion-based composition to avoid gimbal issues: $q_{object}(t)=q_{controller}(t)\\,q_{oc}$.
- Constraining transforms: clamp translations to planes/axes, apply spring/damper smoothing for stable interactions, and use inverse kinematics where needed for articulated grabs.

---

## Navigation (Locomotion Techniques)
- Teleportation: instant position change — low sickness risk; implement fade-in/out and arc-based placement to maintain orientation cues.
- Continuous locomotion: joystick-based or physically walking; mitigations for sickness include vignetting, reduced acceleration, and user-controlled motion.
- Snap-turn vs smooth-turn: snap-turn reduces rotational vection and sickness; smooth-turn provides immersion but can increase discomfort.

---

## Motion & Vection
- Vection: illusory self-motion induced by visual flow; strong when large field-of-view and coherent motion cues exist.
- Sensory Conflict Theory: mismatch between visual and vestibular signals causes cybersickness. Reduce mismatch by:
    - Letting users control speed, using teleportation, or adding visual anchors.
    - Applying comfort techniques: vignette, stabilized horizon, constant frame rate.

---

## AR Basics (Registration & Occlusion)
- Registration (tracking & anchoring): compute transforms that map virtual objects to real-world coordinates using feature/marker-based or SLAM-based tracking.
- Anchors: persistent pose references that keep objects stable relative to the environment.
- Occlusion: use depth sensing or generated depth meshes to correctly occlude virtual geometry behind real objects — essential for believable AR.

---

## Spatial Audio (Basics)
- Spatialization uses distance attenuation, panning, and HRTF filters to place sound in 3D. Important parameters: source position, listener position, orientation, and Doppler.
- Simple attenuation: $L = L_0 - 20\\log_{10}(d/d_0)$ for inverse-square falloff (clamped to avoid extremes).
- HRTF provides realistic directional cues; use reverb/occlusion to match environmental acoustics.

---

## Left-Handed Coordinate System Reference (LHCS)
- In this course LHCS conventions: +X = right, +Y = up, +Z = forward.
- Cross product direction: left-hand rule — place thumb along Y, index along Z, middle gives X direction reference when checking orientation.

---

## Quick Formulas & Cheatsheet
- Homogeneous point: $p_h=[x,y,z,1]^T$. Transform: $p' = M p_h$.
- View pipeline: $v_{clip}=M_{proj} M_{view} M_{model} v_{model}$.
- Quaternion rotate: $p' = q p q^{-1}$ (with $p$ as quaternion $(\\mathbf{p},0)$).
- Ray: $r(t)=o+td$, test intersection with triangle or sphere.
- Perspective: $x_{ndc}=x_{clip}/w_{clip}$ (post homogeneous divide).

---

# Practice Questions (Multiple Choice) — 30 Questions

1. Which matrix transforms model coordinates to world coordinates?
A. Projection matrix
B. View matrix
C. Model (or model-to-world) matrix
D. Normal matrix

2. Which operation must be applied last when converting clip-space to screen coordinates?
A. Model transform
B. Homogeneous divide (divide by w)
C. Rotation about Y
D. Object-to-parent multiplication

3. In a left-handed coordinate system used in this class, which axis points forward?
A. +X
B. +Y
C. +Z
D. -Z

4. Which is an advantage of quaternions over Euler angles?
A. They are easier to visualize
B. They eliminate gimbal lock and interpolate smoothly
C. They use fewer numbers than vectors
D. They avoid the need for normalization

5. To rotate a vector p by a unit quaternion q, which formula is correct?
A. p' = q + p + q
B. p' = q p q^-1 (treat p as quaternion with w=0)
C. p' = q * p
D. p' = p q q

6. Slerp is used to:
A. Linearly scale vectors
B. Interpolate rotations along the shortest arc on the 4D sphere
C. Project points to clip space
D. Compute inverse matrices

7. Which vector is typically the camera “forward” in our LHCS convention?
A. normalize(eye - target)
B. normalize(target - eye)
C. world up vector
D. right cross up

8. The view matrix is:
A. The camera’s world transform
B. The inverse of the camera’s world transform
C. The projection matrix transposed
D. The model matrix for the camera object

9. In perspective projection, why do we do the homogeneous divide?
A. To convert from clip-space to NDC applying perspective foreshortening
B. To normalize normals
C. To apply texture mapping
D. To invert the view transform

10. Which projection preserves parallelism (no perspective)?
A. Perspective
B. Orthographic
C. Perspective with infinite far plane
D. View-projection combined

11. Which test is cheapest for broad-phase ray picking?
A. Triangle intersection
B. Bounding sphere or AABB test
C. Pixel-perfect depth test
D. Mesh-level raycast

12. For a ray r(t)=o+td, what does d need to be for correct intersection math?
A. d can be any non-zero vector
B. d must be normalized (unit length)
C. d must be zero
D. d must be a quaternion

13. When grabbing an object with a controller, storing the initial object-to-controller transform M_oc lets you:
A. Ignore controller orientation later
B. Maintain the relative offset/rotation while the controller moves
C. Instantly snap object to origin
D. Convert object to screen space

14. Which is a good way to reduce rotation-induced cybersickness during turning?
A. Increase field-of-view
B. Use snap-turn instead of smooth-turn
C. Force high acceleration
D. Disable controllers

15. Teleportation reduces sickness because it:
A. Provides continuous optic flow
B. Eliminates extended visual-vestibular conflict by being instantaneous
C. Forces head tracking off
D. Uses larger FOV

16. Vection describes:
A. The vestibular organ
B. The sensation of self-motion induced by visual cues
C. A rendering algorithm
D. A quaternion interpolation method

17. Sensory Conflict Theory explains cybersickness as:
A. Hardware overheating
B. A mismatch between visual motion cues and vestibular/proprioceptive signals
C. Low battery on controllers
D. Low polygon count

18. AR registration primarily concerns:
A. Placing UI elements in world space
B. Anchoring virtual objects to real-world coordinates accurately over time
C. Increasing frame rate
D. Sound spatialization

19. For occlusion in AR, the ideal input is:
A. A 2D sprite
B. A depth map or depth mesh of the real scene
C. Higher polygon count on virtual objects
D. More lights

20. Spatial audio HRTF primarily improves:
A. Volume attenuation only
B. Directional perception (localization) of sounds
C. Framerate
D. Rendering of textures

21. Which formula gives simple inverse-square sound attenuation in dB?
A. L = L0 + 10 log10(d)
B. L = L0 - 20 log10(d/d0)
C. L = L0 * d
D. L = L0 / d^2

22. In Unity (column-major, column vectors), which multiplication order applies a model then view then projection?
A. v' = M_model * v; v'' = M_view * v'; v_clip = M_proj * v''
B. v' = v * M_model; ...
C. v_clip = v_model * M_view * M_proj
D. Order doesn’t matter

23. The cross product r = f × up (in LHCS) is used to compute:
A. The view frustum
B. The camera right vector (r)
C. The projection near plane
D. Sound attenuation

24. Which is a correct reason to normalize quaternions regularly in an application?
A. To make them smaller in memory
B. To avoid drift accumulating from repeated multiplications and maintain unit length
C. To convert them to Euler angles
D. To add translations

25. Which interaction technique is exocentric?
A. Direct hand touch
B. Ray/laser pointing from controller
C. Room-scale walking
D. Teleportation

26. For picking on screen coordinates, which sequence is correct?
A. Screen XY → NDC → clip-space → world-space (via inverse proj * inverse view)
B. World-space → clip-space → screen XY
C. Model-space → screen XY directly
D. NDC → screen XY → model-space

27. Which comfort technique reduces peripheral optic flow during locomotion?
A. Increasing brightness
B. Vignetting (narrowing FOV during motion)
C. Higher resolution textures
D. Disabling controllers

28. For continuous locomotion, what is a common mitigation for sickness?
A. Add constant acceleration spikes
B. Use user-controlled speed, vignetting, and limit angular velocity
C. Random camera jitter
D. Force full-screen overlays

29. Which of these is true about clipping?
A. It happens after the homogeneous divide
B. It happens before projection
C. It happens in clip space against the clip-volume and then homogeneous divide to NDC
D. It’s only needed for audio

30. Which is the correct quick formula for transforming a homogeneous point?
A. p' = M * [x y z]^T
B. p'_h = M * p_h where p_h = [x y z 1]^T
C. p' = p_h / M
D. p' = transpose(M) * p_h

### Answers & Explanations
 
1. C — The model matrix converts model-local coordinates into world coordinates. The model matrix encodes an object's translation/rotation/scale relative to its local origin; applying it places the object into world space. See the "Transformations" section: [Transformations (Model / World / View / Projection)](StudyGuide.md#L7).

2. B — Homogeneous divide (divide by w) is done after projection to produce NDC and applies perspective foreshortening. After multiplying by the projection matrix you divide by the clip-space w to map to normalized device coordinates so distant objects appear smaller. See "Projections": [Projections (Perspective & Orthographic)](StudyGuide.md#L40).

3. C — In the course LHCS convention, +Z is forward. This is a handedness convention that affects view matrix construction and cross-product order; always verify axes when converting content. See "Left-Handed Coordinate System Reference": [Left-Handed Coordinate System Reference (LHCS)](StudyGuide.md#L101).

4. B — Quaternions avoid gimbal lock and interpolate smoothly via Slerp. Unlike Euler angles, quaternions represent rotations on a 4D unit sphere so you can compose and smoothly interpolate rotations without losing degrees of freedom. See "Quaternions": [Quaternions](StudyGuide.md#L21).

5. B — Rotation by quaternion is p' = q p q^-1 with p treated as a pure quaternion (vector, w=0). This formula applies the quaternion rotation to the 3D vector using quaternion multiplication and the quaternion inverse (or conjugate for unit quaternions). See "Quaternions": [Quaternions](StudyGuide.md#L21).

6. B — Slerp interpolates rotations on the unit quaternion sphere along the shortest arc. Use Slerp to smoothly interpolate orientations over time while preserving constant angular velocity on the interpolation path. See "Quaternions": [Quaternions](StudyGuide.md#L21).

7. B — Forward is normalize(target - eye): it points from the camera position toward its look-at target. This vector is used to build the camera basis (right, up, forward) for the view matrix in LHCS. See "3D → 2D Viewing": [3D → 2D Viewing (View Transform & Camera)](StudyGuide.md#L30).

8. B — The view matrix is the inverse of the camera’s world transform; it moves world coordinates into camera (eye) space. Computing M_view as M_camera^{-1} ensures geometry is expressed relative to the camera origin and axes. See "3D → 2D Viewing": [3D → 2D Viewing (View Transform & Camera)](StudyGuide.md#L30).

9. A — The homogeneous divide converts clip coordinates to NDC and implements perspective foreshortening by dividing x,y,z by w. Without it, the perspective projection would not create the proper depth scaling for farther objects. See "Projections": [Projections (Perspective & Orthographic)](StudyGuide.md#L40).

10. B — Orthographic projection preserves parallelism because it maps the view volume linearly without a perspective divide; parallel lines remain parallel. Use orthographic for UI overlays or engineering views where scale must not change with depth. See "Projections": [Projections (Perspective & Orthographic)](StudyGuide.md#L40).

11. B — AABB or bounding-sphere tests are cheap broad-phase tests used before expensive triangle-level checks; they quickly cull most objects. Use these as the first filter in a picking pipeline to reduce computational cost. See "Selection (Picking & Raycasting)": [Selection (Picking & Raycasting)](StudyGuide.md#L57).

12. B — Normalizing d to unit length simplifies intersection math and avoids scaling artifacts; many intersection formulas assume unit direction. Normalization also keeps t values in ray equations proportional to world units. See "Selection (Picking & Raycasting)": [Selection (Picking & Raycasting)](StudyGuide.md#L57).

13. B — Storing M_oc = M_controller^{-1} M_object preserves the initial object-to-controller offset so the object follows the controller with the same relative pose while the controller moves. This keeps grabs stable and predictable. See "Manipulation (Grabbing, Transforming Objects)": [Manipulation (Grabbing, Transforming Objects)](StudyGuide.md#L65).

14. B — Snap-turn reduces rotational vection and sickness by using discrete yaw steps rather than continuous rotation, which reduces the duration of conflicting vestibular cues. It trades some smoothness for comfort. See "Navigation (Locomotion Techniques)": [Navigation (Locomotion Techniques)](StudyGuide.md#L72).

15. B — Teleportation reduces sickness because instantaneous displacement removes prolonged visual-vestibular conflict that causes vection-based discomfort. Include fade or blink transitions to avoid abrupt visual discontinuities. See "Navigation (Locomotion Techniques)" and "Motion & Vection": [Navigation (Locomotion Techniques)](StudyGuide.md#L72) and [Motion & Vection](StudyGuide.md#L79).

16. B — Vection is the sensation of self-motion induced by visual cues (optic flow) even when the vestibular system detects no motion. Large-field coherent motion strongly drives vection. See "Motion & Vection": [Motion & Vection](StudyGuide.md#L79).

17. B — Sensory Conflict Theory explains cybersickness as a mismatch between visual motion cues and vestibular/proprioceptive signals; when senses disagree, the brain may trigger nausea or disorientation. Reducing mismatch reduces sickness. See "Motion & Vection": [Motion & Vection](StudyGuide.md#L79).

18. B — AR registration is about anchoring virtual objects to stable real‑world coordinates over time so virtual content appears fixed to real features; accuracy and drift control are key. Techniques include marker-based and SLAM-based tracking. See "AR Basics (Registration & Occlusion)": [AR Basics (Registration & Occlusion)](StudyGuide.md#L87).

19. B — A depth map or depth mesh of the real scene provides per-pixel or per-surface distance so rendered virtual objects can be occluded correctly by nearer real geometry; this greatly improves believability. See "AR Basics (Registration & Occlusion)": [AR Basics (Registration & Occlusion)](StudyGuide.md#L87).

20. B — HRTF improves directional perception (localization) by filtering audio based on head-related transfer functions so the listener perceives sound direction and elevation more naturally. Combine with distance attenuation and occlusion for realism. See "Spatial Audio (Basics)": [Spatial Audio (Basics)](StudyGuide.md#L94).

21. B — In dB, inverse-square attenuation is expressed as L = L0 - 20 log10(d/d0); this converts multiplicative intensity falloff into additive decibel drop. Clamp near/far distances to avoid extreme values. See "Spatial Audio (Basics)": [Spatial Audio (Basics)](StudyGuide.md#L94).

22. A — With Unity's column-major, column-vector convention you successively left-multiply by model, view, then projection: v_world = M_model * v_model; v_view = M_view * v_world; v_clip = M_proj * v_view. Order and convention matter when composing transforms. See "Transformations" and "3D → 2D Viewing": [Transformations (Model / World / View / Projection)](StudyGuide.md#L7) and [3D → 2D Viewing (View Transform & Camera)](StudyGuide.md#L30).

23. B — r = f × up computes the camera right vector (r) when f (forward) is target-eye and up is the world-up; cross-product order depends on handedness so verify conventions. See "3D → 2D Viewing" and "Left-Handed Coordinate System Reference": [3D → 2D Viewing (View Transform & Camera)](StudyGuide.md#L30) and [Left-Handed Coordinate System Reference (LHCS)](StudyGuide.md#L101).

24. B — Normalizing quaternions prevents length drift caused by repeated multiplications and numerical error; keeping quaternions unit-length ensures they represent pure rotations. Renormalize periodically after composition. See "Quaternions": [Quaternions](StudyGuide.md#L21).

25. B — Ray/laser pointing from a controller is exocentric because it selects objects at a distance via a ray, unlike direct touch which is egocentric. Design depth cues and reticles for accurate distant selection. See "Selection (Picking & Raycasting)": [Selection (Picking & Raycasting)](StudyGuide.md#L57).

26. A — Picking uses Screen XY → NDC → clip-space → view/world via inverse projection and view matrices; unprojecting allows formation of the world-space ray for intersection tests. Ensure correct coordinate conventions and near/far depth values. See "Selection (Picking & Raycasting)" and "Projections": [Selection (Picking & Raycasting)](StudyGuide.md#L57) and [Projections (Perspective & Orthographic)](StudyGuide.md#L40).

27. B — Vignetting (narrowing the effective FOV during motion) reduces peripheral optic flow and can lower vection-induced sickness while preserving central view. Implement smooth transitions tied to motion. See "Motion & Vection": [Motion & Vection](StudyGuide.md#L79).

28. B — Common continuous-locomotion mitigations include letting users set speed, applying vignetting during movement, and limiting angular velocity to reduce vestibular mismatch and discomfort. Combine techniques and test with users. See "Navigation (Locomotion Techniques)" and "Motion & Vection": [Navigation (Locomotion Techniques)](StudyGuide.md#L72) and [Motion & Vection](StudyGuide.md#L79).

29. C — Clipping is performed in clip space against the clip volume (the view frustum defined by clip coordinates) and then the homogeneous divide maps surviving vertices to NDC. Clipping before divide avoids incorrect interpolation of clipped attributes. See "Projections": [Projections (Perspective & Orthographic)](StudyGuide.md#L40).

30. B — Use homogeneous coordinates p_h=[x,y,z,1]^T and multiply p'_h = M p_h to apply a 4x4 transform; this handles translation, rotation, and scale in one matrix. Afterward, perform the homogeneous divide if needed. See "Transformations": [Transformations (Model / World / View / Projection)](StudyGuide.md#L7).