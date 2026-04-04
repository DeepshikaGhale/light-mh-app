# Light - Offline Mental Health Companion

## Hackathon: Claude Builders @ McGill (April 4, 2026)
## Track: Neuroscience & Mental Health

---

## Core Concept

Light is a **fully offline** mental health companion app that runs AI-powered CBT (Cognitive Behavioral Therapy) directly on-device. Nothing leaves the phone by default.

### Why Offline?
- Mental health data is the most sensitive data a person has
- No internet = no data breaches, no cloud dependency, no privacy anxiety
- Works in low-connectivity environments (rural areas, developing regions)
- Users trust it more → they use it more → better outcomes

---

## Features (Built)

| Feature | Description | Status |
|---------|-------------|--------|
| Onboarding | Name, concern selection (anxiety, depression, sleep, etc.) | Done |
| Mood Check-in | 5-point emoji scale + energy, sleep, anxiety sliders | Done |
| CBT Thought Journal | 6-step guided flow: situation → automatic thought → distress rating → cognitive distortion identification → balanced reframe → re-rating | Done |
| AI Chat | CBT-informed conversational support (placeholder, ready for on-device LLM) | Done |
| 4-7-8 Breathing | Animated breathing exercise with phase tracking, 5 cycles | Done |
| Progress Dashboard | Streaks, mood history, journal entries with distress trends | Done |
| Crisis Detection | Keyword-based crisis language detection with 988/Crisis Text Line resources | Done |
| Streak Tracking | Consecutive day tracking across mood + journal activities | Done |

---

## Integration Layer (Optional Cloud Sync)

The app is offline-first, but offers **opt-in** integrations for users who want to share data with care teams or escalate crises.

### 1. Rootly - Incident-Based Crisis Management

**Concept:** Map mental health episodes to Rootly's incident management framework.

| Rootly Concept | Mental Health Mapping |
|----------------|---------------------|
| Incident | Mood crisis / distress episode |
| Severity | Distress level (1-10 scale → sev0-sev3) |
| Alert | Mood drop detection (e.g., mood went from 4 to 1) |
| Alert Urgency | Risk level (low/medium/high/critical) |
| Incident Status | Episode lifecycle: detected → acknowledged → mitigated → resolved |
| Escalation Policy | Self-help → peer support → therapist → crisis hotline |
| Action Items | Coping tasks from safety plan |
| Retrospective | Post-episode reflection journal entry |
| Heartbeat | Daily wellness check-in ("I'm okay" signal) |
| Workflows | Automated: if mood < 2 for 3 days → create incident |

**User Flow:**
1. User enables "Care Team Sync" in settings (off by default)
2. App detects sustained low mood or crisis keywords
3. Creates a Rootly incident with severity mapped from distress score
4. Therapist/care team gets notified through Rootly's escalation
5. User can also manually trigger "I need help" → creates incident
6. Daily heartbeat check-ins let care team know user is okay
7. After episode resolves, retrospective maps to journal reflection

**Privacy Model:**
- API key stored locally on device
- User explicitly opts in per-feature
- Can revoke access anytime
- Only sends aggregated/anonymized data unless user chooses otherwise

### 2. PCare+ (pcare.ca) - Clinical Guideline Integration

**What is PCare+?**
PCare+ is an early-stage Canadian/US startup (Merck Digital Sciences Studio Cohort 2025, $100K SAFE from Merck Global Health Innovation Fund). They build a **"deterministic compiler for care coordination"** - turning clinical practice guideline PDFs into structured, executable digital logic. Founded by Antoine Denis, a Resident Physician in Public Health & Preventive Medicine at McGill. Contact: pcare@mds.studio

**Why it fits Light perfectly:**
PCare+ compiles clinical guidelines into personalized, risk-based questionnaires. Light already does CBT-based thought journaling and mood tracking. Together:

| PCare+ Capability | Light Integration |
|-------------------|-------------------|
| Clinical guideline compiler | Feed depression/anxiety screening guidelines (PHQ-9, GAD-7) into Light's assessment flow |
| Risk-based questionnaires | Dynamic screening that adapts based on user's mood history and risk factors |
| Deterministic clinical logic | Evidence-based intervention recommendations (not hallucinated AI advice) |
| Physician-in-the-loop | Validated recommendations that Light can surface as coping strategies |
| Evolving evidence base | App recommendations auto-update as clinical guidelines change |

**Proposed Integration (no public API yet - partnership model):**

1. **Guideline-Powered Screening:** PCare+ compiles PHQ-9/GAD-7/PSQI guidelines → Light uses the compiled logic locally to run validated depression/anxiety/sleep assessments
2. **Risk-Stratified Interventions:** Based on screening scores, Light recommends specific CBT modules (e.g., behavioral activation for moderate depression, worry time for GAD)
3. **Preventive Care Bridge:** Light detects sustained mood decline → surfaces PCare+ guideline-aligned recommendation to see a physician
4. **Offline Execution:** PCare+ compiles guidelines once → Light downloads the compiled logic → runs entirely offline (fits the deterministic, non-generative approach)
5. **Evidence Trail:** Every recommendation in Light can cite the specific clinical guideline it came from (e.g., "Based on CANMAT 2016 Guidelines for Depression Management")

**Why this is compelling for the hackathon:**
- PCare+ is McGill-connected (Antoine Denis is a McGill resident physician)
- Shows a real pathway from self-help app → evidence-based clinical care
- "Deterministic compiler" + "on-device LLM" = AI that's both smart AND clinically safe
- Merck backing adds credibility to the clinical validation story

**Next steps to make this real:**
- Contact pcare@mds.studio to discuss integration pilot
- Request sample compiled guideline output format
- Build a local guideline executor in Light that consumes PCare+ compiled logic
- Start with PHQ-9 (depression) and GAD-7 (anxiety) as proof of concept

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (cross-platform) |
| State Management | Provider |
| On-Device AI | SmolLM2-135M via llama_cpp_dart (FFI) |
| Local Storage | SQLite (sqflite) |
| Embeddings | BGE-small-en-v1.5 via ONNX Runtime |
| RAG Knowledge Base | CBT techniques, cognitive distortions, coping strategies |
| Crisis Integration | Rootly API (opt-in) |
| Healthcare Integration | PCare.ca (opt-in, TBD) |
| Design | Material 3, Poppins font, sage green palette |

## Architecture

```
┌─────────────────────────────────────────────┐
│                   Light App                  │
│                                             │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐   │
│  │  Mood    │ │ Journal  │ │ Breathe  │   │
│  │ Check-in │ │  (CBT)   │ │ Exercise │   │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘   │
│       │             │            │          │
│  ┌────▼─────────────▼────────────▼─────┐   │
│  │           App State (Provider)       │   │
│  └────┬─────────────┬──────────────────┘   │
│       │             │                       │
│  ┌────▼─────┐ ┌─────▼──────┐              │
│  │  SQLite  │ │ On-Device  │              │
│  │ (Local)  │ │ LLM + RAG  │              │
│  └──────────┘ └────────────┘              │
│                                             │
│  ─ ─ ─ ─ ─ ─ PRIVACY WALL ─ ─ ─ ─ ─ ─ ─  │
│  (Everything above is offline by default)   │
│                                             │
│  ┌──────────────────────────────────────┐  │
│  │     Optional Cloud Sync (Opt-in)     │  │
│  │  ┌─────────┐     ┌───────────┐      │  │
│  │  │ Rootly  │     │ PCare.ca  │      │  │
│  │  │ (Crisis │     │(Healthcare│      │  │
│  │  │  Mgmt)  │     │  Portal)  │      │  │
│  │  └─────────┘     └───────────┘      │  │
│  └──────────────────────────────────────┘  │
└─────────────────────────────────────────────┘
```

## Why This Wins

1. **Privacy-first** - No data leaves the phone unless the user says so
2. **AI on-device** - Claude-informed CBT without cloud dependency
3. **Real clinical framework** - CBT thought records, not just "how are you feeling" check-ins
4. **Smart escalation** - Rootly integration means a therapist gets alerted before a crisis becomes an emergency
5. **Canadian healthcare ready** - PCare.ca integration for real-world deployment
6. **Evidence-based** - Tracks distress before/after reframing to show CBT effectiveness
