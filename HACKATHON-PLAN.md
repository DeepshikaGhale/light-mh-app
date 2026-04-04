# Light × Rootly: Predictive Burnout Shield for Engineers

## Claude Builders Hackathon @ McGill — April 4, 2026
## Track: Neuroscience & Mental Health → Rootly Sub-Challenge: Engineer Wellbeing

---

## TL;DR

A Flutter mobile app that merges **sleep disorder detection from wearables** (DREAMT dataset: smartwatch PPG/ACC/EDA/TEMP → sleep quality) with **operational stressor data** (Rootly: incidents, on-call shifts, alert volume, OCH burnout score) to build a **predictive burnout shield** for engineers. Not just a dashboard — an autonomous agent that detects burnout before it happens and takes action via Rootly's API.

---

## The Problem

On-call engineers get paged at 2 AM, work through weekends, and absorb stress that never shows up in a Jira ticket. Current tools track **system health** but not **human health**. By the time someone burns out, it's too late.

## The Insight

Burnout has two sides:
1. **Internal state** — sleep quality from wearables (sleep efficiency, deep sleep ratio, fragmentation, post-page recovery)
2. **External stressors** — incident volume, page frequency, shift patterns, after-hours alerts

Neither alone is enough. An engineer might handle 10 incidents fine one week but break from 3 the next — because their physiological recovery was already depleted. **You need both signals.**

---

## Data Sources

### 1. DREAMT Dataset (Sleep Disorder Detection from Wearables)

**What:** PhysioNet dataset — 100 participants from Duke University Sleep Disorder Lab, with both smartwatch AND full polysomnography signals, expert-annotated sleep stages, and clinical sleep disorder metadata.

**Source:** https://physionet.org/content/dreamt/2.1.0/
**License:** PhysioNet Restricted Health Data License 1.5.0

| Property | Detail |
|----------|--------|
| Participants | 100 (from Duke University Health System Sleep Disorder Lab) |
| Collection | May-September 2022 |
| Demographics | Age 56.2±16.6, BMI 33.7±8.6, 68 obese, 23 severe OSA |
| **Smartwatch (E4)** | |
| BVP | Blood Volume Pulse from PPG sensor @ 64Hz |
| ACC | 3-axis accelerometer (ACC_X, ACC_Y, ACC_Z) @ 32Hz |
| EDA | Electrodermal Activity @ 4Hz |
| TEMP | Skin Temperature @ 4Hz |
| HR | Heart Rate (derived) |
| IBI | Inter-beat Intervals (derived) |
| **Full PSG (100Hz)** | |
| EEG | 5 channels: C4-M1, F4-M1, O2-M1, T3-CZ, CZ-T4 |
| EOG | 2 channels (E1, E2) |
| EMG | Chin channel |
| ECG | Single channel |
| Respiratory | PTAF, FLOW, THORAX, ABDOMEN, SNORE |
| Leg Movement | LAT, RAT channels |
| SpO2 | Blood oxygen saturation (%) |
| **Labels** | Expert-annotated every 30 seconds |
| Sleep Stages | W (Wake), N1, N2, N3 (Non-REM), R (REM) |
| Clinical | OSA severity (AHI, OAHI), BMI, sleep disorder diagnoses |
| **File Format** | CSV files in two folders: data_64Hz (raw) and data_100Hz (unified + PSG) |

### Baigutanova et al. (2025)
*(Second dataset from hackathon challenge — additional sleep disorder dataset. Details TBD — need to confirm source from hackathon organizers.)*

**How we use DREAMT:**
1. Train a **sleep disorder classifier** using only smartwatch-grade signals (BVP, ACC, EDA, TEMP) — same sensors as Apple Watch/Fitbit
2. Detect: **poor sleep quality, fragmented sleep, sleep apnea indicators** from wearable data
3. Feed sleep quality scores into the burnout prediction: bad sleep + heavy on-call = high risk
4. The PSG ground truth validates the wearable-only model's accuracy

**Why this is perfect for engineer burnout:**
- Engineers already wear smartwatches — no new hardware needed
- Sleep disruption from 2AM pages is measurable and quantifiable
- Sleep quality is the #1 predictor of next-day cognitive performance
- DREAMT specifically recruited sleep disorder patients (obese, OSA) — robust training data
- Wearable-only classification means the model runs on-device (offline-first)

### 2. Rootly API + MCP Server (Operational Stressors)

**API Base:** `https://api.rootly.com/v1/`
**Auth:** Bearer token — `Authorization: Bearer rootly_4c69de14805170593458b2f1c58bb0eb7591f0c9f9c6fa7652313c6a938ca865`
**Format:** JSON:API (`application/vnd.api+json`)

#### Rootly MCP Server (101 tools)

**Hosted endpoints:**
- HTTP: `https://mcp.rootly.com/mcp`
- SSE: `https://mcp.rootly.com/sse`

**Key custom tools for our app:**

| MCP Tool | What it gives us | App usage |
|----------|-----------------|-----------|
| `check_oncall_health_risk` | At-risk users, safe replacements, action summaries | Core burnout detection |
| `get_oncall_shift_metrics` | Hours on-call, shift counts, primary/secondary roles by user/team | Workload quantification |
| `get_shift_incidents` | Incidents during period, severity, avg resolution time | Stress exposure measurement |
| `get_oncall_handoff_summary` | Current/next on-call + shift incidents | Handoff automation |
| `find_related_incidents` | TF-IDF similar historical incidents | Pattern recognition |
| `suggest_solutions` | Past resolution mining | Reduce cognitive load |
| `create_override_recommendation` | Smart override assignments | Automated relief |
| `check_responder_availability` | Who's available to help | Swap facilitation |

**Key REST API endpoints:**

| Endpoint | Use |
|----------|-----|
| `POST /v1/incidents` | Create burnout incident when threshold crossed |
| `GET /v1/incidents` | Fetch incident history for workload analysis |
| `GET /v1/schedules` | Pull on-call schedules |
| `GET /v1/schedule_rotations` | Rotation patterns |
| `POST /v1/override_shifts` | Create relief shifts |
| `GET /v1/escalation_policies` | Escalation chains |
| `POST /v1/incident_action_items` | Create recovery tasks |

### 3. Rootly On-Call Health API (Burnout Scoring)

**Hosted:** `https://api.oncallhealth.ai/docs`
**Open source:** `github.com/Rootly-AI-Labs/On-Call-Health`

**OCH Score** — composite burnout risk score (0-100):
| Range | Level | Action |
|-------|-------|--------|
| 0-24 | Maintain balance | Green — keep going |
| 25-49 | Monitor risk | Yellow — watch trends |
| 50-74 | Early intervention | Orange — reduce load, suggest swap |
| 75-100 | Immediate action | Red — force handoff, block pages |

**Inputs to OCH score:**
- Incident response volume & severity
- After-hours page frequency
- Weekend activity patterns
- Escalation frequency
- Response times
- Shift frequency & duration
- PR volume and code review load
- Self-reported wellbeing scores
- Slack sentiment analysis

**Integrations:** Rootly, PagerDuty, GitHub, Slack, Linear, Jira

**Validated against:** Copenhagen Burnout Inventory (CBI) + Maslach Burnout Inventory (MBI)

---

## Architecture: The Signa-Rootly Bridge

```
┌──────────────────────────────────────────────────────────────────┐
│                    LIGHT MOBILE APP (Flutter)                     │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                    PRESENTATION LAYER                    │    │
│  │                                                         │    │
│  │  ┌────────────┐ ┌────────────┐ ┌────────────────────┐  │    │
│  │  │ Burnout    │ │ Incident   │ │ Recovery           │  │    │
│  │  │ Dashboard  │ │ Impact     │ │ Tracker            │  │    │
│  │  │            │ │ Timeline   │ │                    │  │    │
│  │  │ • OCH Score│ │ • HRV dips │ │ • Breathing        │  │    │
│  │  │ • Trend    │ │ │ mapped to│ │ • Journal          │  │    │
│  │  │ • Risk tier│ │ │ incidents│ │ • Sleep coaching   │  │    │
│  │  └────────────┘ └────────────┘ └────────────────────┘  │    │
│  │                                                         │    │
│  │  ┌────────────────────────────────────────────────────┐│    │
│  │  │          THE CIRCUIT BREAKER (1-tap actions)       ││    │
│  │  │                                                    ││    │
│  │  │  [🔄 Request Swap]  [📋 Handoff Summary]          ││    │
│  │  │  [🔇 Silence Alerts] [🆘 Escalate to Backup]     ││    │
│  │  └────────────────────────────────────────────────────┘│    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                   INTELLIGENCE LAYER                     │    │
│  │                                                         │    │
│  │  ┌──────────────────┐    ┌───────────────────────────┐ │    │
│  │  │ Fusion Engine    │    │ On-Device LLM (SmolLM2)   │ │    │
│  │  │                  │    │                           │ │    │
│  │  │ IF physiological │    │ Natural language queries: │ │    │
│  │  │ stress HIGH      │    │ "Am I at risk this week?" │ │    │
│  │  │ AND operational  │    │ "Who can cover tonight?"  │ │    │
│  │  │ load HIGH        │    │ "Show my recovery trend"  │ │    │
│  │  │ THEN → intervene │    │                           │ │    │
│  │  └──────────────────┘    └───────────────────────────┘ │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                      DATA LAYER                          │    │
│  │                                                         │    │
│  │  ┌─────────────┐  ┌──────────────┐  ┌───────────────┐ │    │
│  │  │ DREAMT     │  │ Rootly API   │  │ On-Call Health │ │    │
│  │  │ (Sleep)     │  │ (Incidents)  │  │ (OCH Score)   │ │    │
│  │  │             │  │              │  │               │ │    │
│  │  │ • PPG→HRV   │  │ • Incidents  │  │ • Burnout     │ │    │
│  │  │ • ACC→      │  │ • Schedules  │  │   risk 0-100  │ │    │
│  │  │   Movement  │  │ • Shifts     │  │ • Trend       │ │    │
│  │  │ • EDA→Stress│  │ • Alerts     │  │ • Per-user    │ │    │
│  │  │ • Sleep Eff%│  │ • Overrides  │  │   baseline    │ │    │
│  │  └──────┬──────┘  └──────┬───────┘  └───────┬───────┘ │    │
│  │         │                │                   │         │    │
│  │         └────────────────┼───────────────────┘         │    │
│  │                          ▼                             │    │
│  │                   ┌─────────────┐                      │    │
│  │                   │  SQLite     │                      │    │
│  │                   │  (Local DB) │                      │    │
│  │                   └─────────────┘                      │    │
│  └─────────────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────────────┘
```

---

## Core Features

### Feature 1: Burnout Dashboard

The main screen shows a single **Elasticity Score** — how well you're bouncing back from incidents.

**Inputs:**
- Rootly `check_oncall_health_risk` → OCH score (0-100)
- Rootly `get_oncall_shift_metrics` → hours on-call, shift count
- Rootly `get_shift_incidents` → incident count, severity distribution, avg MTTR
- DREAMT-trained model → sleep efficiency, deep sleep %, fragmentation (from smartwatch)

**Display:**
- Circular gauge: green/yellow/orange/red
- 7-day trend sparkline
- "You've handled 7 incidents this week, 3 after midnight. Your recovery is trending down."

### Feature 2: Incident Impact Timeline

A scrollable timeline that overlays **sleep quality impact** onto **operational events**.

```
Mon 2AM  ─── 🔴 DB outage (sev1) ──── Sleep efficiency: 62% ──── Deep sleep: 8% ──── Recovery: 3 days
Wed 11AM ─── 🟡 API latency (sev3) ── Sleep normal (89%) ─────── Deep sleep: 22% ── Recovery: 2 hours
Thu 3AM  ─── 🔴 Auth failure (sev1) ── Sleep efficiency: 54% ──── Deep sleep: 5% ─── ⚠️ Still recovering
```

**How:** `get_shift_incidents` gives incident timestamps + severity. DREAMT-trained model gives sleep quality impact from wearable data. The fusion engine calculates recovery time based on sleep metrics returning to baseline.

### Feature 3: The Circuit Breaker (1-Tap Actions)

When burnout risk is HIGH, the app offers immediate actions powered by Rootly API:

| Button | Rootly API Call | What happens |
|--------|----------------|--------------|
| 🔄 Request Swap | `create_override_recommendation` → `POST /v1/override_shifts` | Finds available backup, creates override shift |
| 📋 Handoff Summary | `get_oncall_handoff_summary` | Generates handoff doc with open incidents, context, next steps |
| 🔇 Silence Non-Critical | `updateIncident` (filter sev3/sev4) | Mutes low-severity alerts for recovery period |
| 🆘 Escalate | `POST /v1/escalation_policies` trigger | Brings in backup before you hit breaking point |

### Feature 4: Smart Shift Scoring

Before each on-call shift, the app pre-calculates risk:

```
Upcoming Shift: Friday 6PM - Monday 6AM
────────────────────────────────────
Risk Factors:
  • Weekend shift (+15 points)
  • 3rd consecutive week on primary (+20 points)
  • 2 sev1 incidents last shift (+10 points)
  • Current OCH score: 62 (Early Intervention)
────────────────────────────────────
Predicted Risk: 🟠 HIGH (72/100)
Recommendation: Request swap or add secondary
[🔄 Find Available Backup]
```

### Feature 5: Recovery Mode

When the app detects you need recovery (OCH > 50 or physiological indicators down):

- **Guided breathing** (4-7-8, already built)
- **CBT thought journal** for processing incident stress (already built)
- **Sleep coaching** based on shift schedule
- **Auto-status** — sets Rootly/Slack status to recovery mode
- **Incident retrospective** prompt — turn the stress into learning

### Feature 6: Team Health View (Manager/Lead)

Uses `get_oncall_shift_metrics` grouped by team to show:
- Who's most loaded this sprint
- Workload distribution fairness
- Historical burnout risk per team member
- Suggested rotation rebalancing

---

## The Intelligence: Fusion Engine Logic

```python
# Pseudocode for the fusion decision engine

def assess_risk(user):
    # Layer 1: Operational load (from Rootly)
    och_score = rootly.check_oncall_health_risk(user)
    shift_metrics = rootly.get_oncall_shift_metrics(user, period="7d")
    incidents = rootly.get_shift_incidents(user, period="7d")

    after_hours_count = count(incidents, after_hours=True)
    sev1_count = count(incidents, severity="sev1")

    # Layer 2: Sleep quality (from DREAMT-trained model)
    # In production: real smartwatch data (PPG, ACC, EDA, TEMP)
    # For hackathon: DREAMT pre-processed participant data
    sleep_efficiency = dreamt_model.predict_sleep_efficiency(wearable_features)
    deep_sleep_ratio = dreamt_model.predict_deep_sleep_ratio(wearable_features)
    fragmentation = dreamt_model.predict_fragmentation_index(wearable_features)
    post_page_recovery = compute_recovery_after_pages(sleep_data, incidents)

    # Layer 3: Fusion scoring
    operational_risk = och_score  # 0-100
    physiological_risk = compute_sleep_risk(
        sleep_efficiency, deep_sleep_ratio, fragmentation, post_page_recovery
    )  # 0-100

    # Weighted composite
    # Physiological signals amplify operational risk
    composite = 0.6 * operational_risk + 0.4 * physiological_risk

    # Interaction effect: if BOTH are high, risk is multiplicative
    if operational_risk > 50 and physiological_risk > 50:
        composite = min(100, composite * 1.3)

    return {
        "score": composite,
        "tier": get_tier(composite),  # green/yellow/orange/red
        "triggers": identify_top_factors(shift_metrics, incidents, sleep_efficiency),
        "recommended_actions": get_actions(composite, user),
    }

def get_actions(score, user):
    if score >= 75:
        return [
            auto_find_backup(user),      # Rootly: create_override_recommendation
            generate_handoff(user),       # Rootly: get_oncall_handoff_summary
            silence_low_sev(user),        # Rootly: update alerts
            notify_manager(user),         # Rootly: create incident (burnout type)
        ]
    elif score >= 50:
        return [
            suggest_swap(user),
            breathing_exercise(),
            journal_prompt("incident stress"),
        ]
    elif score >= 25:
        return [
            show_trend_warning(user),
            sleep_coaching(user.next_shift),
        ]
    else:
        return [encourage_streak(user)]
```

---

## Rootly API Integration Details

### Authentication
```dart
// Flutter HTTP client setup
const rootlyBaseUrl = 'https://api.rootly.com/v1';
const rootlyToken = 'rootly_4c69de14...'; // stored securely on device

final headers = {
  'Authorization': 'Bearer $rootlyToken',
  'Content-Type': 'application/vnd.api+json',
};
```

### Key API Calls

**1. Get on-call health risk:**
```
MCP: check_oncall_health_risk
→ Returns: at-risk users, safe replacements, action summaries
```

**2. Get shift metrics for current user:**
```
MCP: get_oncall_shift_metrics(period: "7d", group_by: "user")
→ Returns: shift counts, hours, primary/secondary tracking
```

**3. Get incidents during shifts:**
```
MCP: get_shift_incidents(period: "7d", severity: ["sev0", "sev1"])
→ Returns: incident list, summary with counts, avg resolution time
```

**4. Create burnout incident:**
```http
POST /v1/incidents
{
  "data": {
    "type": "incidents",
    "attributes": {
      "title": "Burnout Risk Alert: [User] - OCH Score 78",
      "summary": "Automated alert: engineer's composite burnout score crossed intervention threshold. 5 sev1 incidents in 7 days, 3 after-hours pages, declining recovery metrics.",
      "status": "detected",
      "severity_id": "<sev1_id>"
    }
  }
}
```

**5. Create override shift (relief):**
```http
POST /v1/override_shifts
{
  "data": {
    "type": "override_shifts",
    "attributes": {
      "starts_at": "2026-04-05T18:00:00Z",
      "ends_at": "2026-04-06T06:00:00Z"
    }
  }
}
```

**6. Create recovery action items:**
```http
POST /v1/incidents/{id}/action_items
{
  "data": {
    "type": "incident_action_items",
    "attributes": {
      "summary": "Complete 4-7-8 breathing exercise",
      "status": "open",
      "priority": "high"
    }
  }
}
```

### MCP Server Connection (for Claude/LLM integration)
```json
{
  "mcpServers": {
    "rootly": {
      "url": "https://mcp.rootly.com/mcp",
      "headers": {
        "Authorization": "Bearer rootly_4c69de14..."
      }
    }
  }
}
```

---

## DREAMT Dataset Integration

### What We Extract

From the DREAMT CSV files, we train a lightweight **sleep quality + disorder classifier** using smartwatch-only signals:

| Signal | Features Extracted | Maps To |
|--------|-------------------|---------|
| BVP (PPG) | HRV (RMSSD, SDNN, pNN50), HR variability | Autonomic nervous system state, recovery capacity |
| IBI | Inter-beat intervals, LF/HF ratio | Sympathetic/parasympathetic balance |
| ACC (3-axis) | Movement intensity, position changes, restlessness index | Sleep fragmentation, leg movements |
| EDA | Skin conductance level, SCR frequency | Stress arousal, sleep depth |
| TEMP | Skin temperature slope, circadian rhythm | Sleep onset, thermoregulation |
| HR | Mean HR, HR dips during sleep, HR recovery | Cardiovascular stress, sleep quality |

**Training approach:**
1. Load DREAMT `data_64Hz/` → extract smartwatch signals (BVP, ACC, EDA, TEMP)
2. Compute features per 30-second epoch (matching sleep stage labels)
3. Train sleep stage classifier: Wake / N1 / N2 / N3 / REM
4. Derive sleep quality metrics: sleep efficiency, deep sleep %, fragmentation index, OSA risk
5. Validate against PSG ground truth from `data_100Hz/`
6. Export to TFLite for on-device inference

### Sleep Quality → Burnout Risk Features

| Derived Metric | Formula | Burnout Signal |
|----------------|---------|----------------|
| Sleep Efficiency | Total sleep / Time in bed | < 85% = poor recovery |
| Deep Sleep Ratio | N3 time / Total sleep | < 15% = insufficient restoration |
| Fragmentation Index | Awakenings per hour | > 5 = disrupted sleep |
| Sleep Latency | Time to first N1 | > 30 min = hyperarousal (stress) |
| REM Latency | Time to first REM | Abnormal = mood disorder indicator |
| Post-Page Recovery | Sleep efficiency after 2AM alert | How well you recover from pages |

**For the hackathon demo:** Pre-process DREAMT participant data to show sleep quality scores. Overlay with simulated Rootly incident timestamps to demonstrate: "This engineer was paged at 2AM, their sleep efficiency dropped from 91% to 62%, deep sleep ratio fell to 8%. Their recovery hasn't normalized after 3 days. OCH score: 74 → Circuit Breaker activated."

---

## App Screens (Flutter)

### Screen 1: Burnout Dashboard (Home)
- Circular elasticity gauge (0-100, color-coded)
- 7-day trend line
- Current shift info from Rootly
- Top risk factors as chips

### Screen 2: Incident Impact Timeline
- Vertical timeline with incident cards
- Each card shows: severity, time, duration, sleep quality impact
- Color-coded recovery periods between incidents (sleep efficiency trend)

### Screen 3: Circuit Breaker
- 4 large action buttons (swap, handoff, silence, escalate)
- Each triggers Rootly API calls
- Confirmation + status tracking

### Screen 4: Recovery Mode
- Breathing exercise (built)
- Thought journal for incident stress (built)
- Sleep schedule optimizer based on next shift
- Recovery countdown timer

### Screen 5: Team Health (Manager View)
- Team members listed by OCH score
- Workload distribution bar chart
- "Rebalance Rotation" suggestion button

### Screen 6: Chat (AI Assistant)
- Natural language interface to both Rootly + DREAMT data
- "How am I doing this week?"
- "Find me a backup for tonight's shift"
- "What was my worst incident this month?"

---

## Why This Wins

1. **Two-signal fusion** — First app to combine sleep quality (DREAMT wearable data) + operational load (Rootly) for burnout prediction
2. **Not just a dashboard** — The Circuit Breaker takes autonomous action via Rootly API
3. **Real API integration** — Actually calls Rootly endpoints, creates incidents, manages shifts
4. **Neuroscience grounding** — DREAMT dataset (100 sleep disorder patients, Duke University) provides validated wearable → sleep quality mapping
5. **Offline-first** — Core wellness features (breathing, journal) work without internet
6. **Rootly sub-challenge fit** — Uses MCP server, On-Call Health API, REST API, and CLI concepts
7. **Hackathon-ready scope** — Dashboard + Circuit Breaker + Recovery Mode is buildable in hours

---

## Build Priority (Hackathon Day)

| Priority | Feature | Time Est |
|----------|---------|----------|
| P0 | Rootly service (API client + MCP calls) | 1 hr |
| P0 | Burnout dashboard with real OCH data | 1 hr |
| P0 | Circuit Breaker (4 action buttons → API) | 1 hr |
| P1 | Incident Impact Timeline | 45 min |
| P1 | DREAMT sleep quality model + demo | 45 min |
| P1 | Fusion engine (combine both scores) | 30 min |
| P2 | Team Health view | 30 min |
| P2 | Chat integration with MCP | 30 min |
| Already done | Breathing, Journal, Mood, Onboarding | ✅ |

---

## Sharing This Doc

This document is self-contained. Share it with any AI assistant or team member for:
- Implementation guidance
- API endpoint reference
- Architecture decisions
- Feature prioritization
