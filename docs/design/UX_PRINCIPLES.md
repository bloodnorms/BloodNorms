# BloodNorms — The 18 "3-Year-Old Simple" UX Principles

**Role:** Principal Product Designer & Senior Frontend Engineer  
**Document:** `docs/design/UX_PRINCIPLES.md`

Emergency medical software often fails because interfaces are dense, cluttered, and confusing. BloodNorms adheres to 18 strict UX principles to guarantee calm clarity under pressure.

---

### 1. One Screen, One Job
Every view has exactly one core responsibility: dispatching a broadcast, inspecting an audience, triaging emergencies, or managing blood stock. If a view starts trying to do two distinct jobs, split it into two sub-views with clear routes.

### 2. One Confident Primary Action Pill
Every view must have exactly ONE near-black `#1F1F1F` pill button. If a 3-year-old looks at the screen, they must instinctively point to that single button as the thing that makes progress. Secondary actions are always outlined or tonal.

### 3. Tactile Pill Buttons
All buttons use the `radiusPill = 999.0` token. Sharp rectangular buttons feel bureaucratic; pills feel approachable, modern, and friendly.

### 4. Minimum 44px Tap Targets
Every button, checkbox, switch, or icon tap region has at least 44x44 dp interactive hit testing. This prevents mis-taps on mobile and touch displays during emergencies.

### 5. Plain Grade-5 Language
Never use raw technical jargon, database column names, or developer idioms:
- Say "Triage queue", not "Dead-letter asynchronous queue".
- Say "Connected blood centers", not "Distributed facility microservices".
- Say "Travel preferences", not "Spatial polygon geofence bounds".

### 6. Domain-First Naming
Consumer third-party brand names and comic-book phrasing are strictly forbidden. No "Superhero actions", no "Duolingo-style gamification", no "Tinder swipe". Everything is named by our healthcare domain: `Quick actions`, `Donors registry`, `Stock matrix`.

### 7. Semantic Color Discipline
Color is never decorative wallpaper. Backgrounds are pure white or soft neutral gray. Color exists strictly to convey status:
- Green (`#1E8E3E`) = Verified, active, connected, resolved.
- Amber (`#B06000`) = Pending approval, warning, approaching limit.
- Red (`#D93025`) = Urgent emergency, critical shortage, blocked requester.
- Blue-Violet (`#5B5BF0`) = Interactive navigation, accent highlight.

### 8. Calm Stat Metric Cards
Top-level metrics use `AppStatCard` with quiet labels, large bold values, outline icons, and hover lift. Saturated rainbow gradients are strictly banned.

### 9. Fully Rounded Search Bars
All searches use `AppSearchField`: fully rounded pill geometry, magnifying glass prefix, clear button suffix, and instant filtering.

### 10. Prompt-Style Composers
Broadcast and message composition takes inspiration from conversational AI prompts: a single wide, comfortable text box with rounded option chips below.

### 11. Friendly Empty States
When a list is empty, never show a blank void or raw error message. Display `AppEmptyState` with a soft circle icon, a reassuring title ("No active emergencies"), and a clear explanation ("The network is standing by").

### 12. Empathetic Error States
When a query fails, show `AppErrorState` with what went wrong in plain words and a single clear retry button.

### 13. Comfortable Table Rows
Data tables must have generous row height (>= 48px), comfortable padding, and soft pill badges. Never cram rows edge-to-edge.

### 14. Progressive Disclosure
Do not overwhelm users with 30 fields at once. Basic inputs are visible upfront; advanced filters and dangerous toggles sit behind clean expandable sections or confirmation dialogs.

### 15. Floating Pill Toasts
Toasts float bottom-center in near-black `#1F1F1F` pills with white text. They confirm completed actions and dismiss automatically after 2 seconds.

### 16. Four-Eyes Governance Without Crashing
Any attempt to execute a high-impact mutation (broadcast > 200 donors) intercepts gracefully, displaying an explanatory Four-Eyes approval modal rather than throwing a runtime error.

### 17. Smooth Micro-Interactions
Interactive elements provide instantaneous tactile feedback: buttons scale to 0.98 on press; stat cards lift by 2px on hover; segmented controls slide smoothly over 150ms.

### 18. Light Theme Strictness
The platform is designed exclusively in Light Theme. Consistent high-contrast light surfaces ensure maximum readability in bright hospital emergency wards and outdoor blood drive tents.

