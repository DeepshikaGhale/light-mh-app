# Light - Recovery Debt System for Incident Responders

Built for the Claude Builders Hackathon @ McGill (Rootly Sub-Challenge).
Team: Deepshika Ghale, Athif Shaffy.

## What This App Does

Light fuses two data sources into one metric called **Recovery Debt**:

1. **Rootly operational data** - how many incidents you handled, their severity, time of day
2. **Wearable biometric data** - sleep efficiency, HRV (heart rate variability), sleep fragmentation

The formula: `Recovery Debt = Operational Load - Biological Recovery Capacity`

When your body can't keep up with your incident load, the app detects it and offers concrete actions: generate a handoff, request a shift override, silence low-severity alerts, or escalate to backup.

## How Recovery Debt Is Calculated

### Flutter Side (what the app uses for demo)

In `lib/services/mock_rootly_service.dart`, the `MockWellnessService.computeResilienceDelta()` method:

```
composite = 0.6 * ochScore + 0.4 * sleepRisk
```

- `ochScore` = Rootly On-Call Health score (0-100, higher = more stressed). Mock value: 67.
- `sleepRisk` = computed from `SleepMetrics.sleepRiskScore` getter in `lib/models/rootly_models.dart`

Sleep risk scoring (each component adds points, clamped to 0-100):
- Sleep efficiency < 85% -> penalty = `(85 - efficiency) * 2`
- Deep sleep ratio < 15% -> penalty = `(15 - ratio) * 2`
- Fragmentation > 5 awakenings/hr -> penalty = `(frag - 5) * 5`
- RMSSD < 30ms -> penalty = `(30 - rmssd) * 1.5`
- Sleep latency > 30min -> penalty = `(latency - 30)`

If BOTH ochScore > 50 AND sleepRisk > 50, there's a 1.3x interaction multiplier (compounding effect).

The **delta** = `(100 - sleepRisk) - ochScore`. Negative = biological debt.

### Node.js Side (backend computation engine)

In `backend/resilience-engine.js`, the `ResilienceEngine` class:

- `computeBiologicalScore(sleepHours, hrvScore)`: sleep 0-50 points + HRV 0-50 points
- `computeRecoveryDebt(operationalRisk, biologicalScore)`: simple subtraction
- `classifyState(recoveryDebt)`: >30 = CRITICAL_DEBT, >15 = WARNING, else STABLE

States:
- **STABLE** (composite < 25): "RESILIENT"
- **WARNING** (25-49): "RECOVERY DECLINING"
- **EARLY INTERVENTION** (50-74): "BIOLOGICAL DEBT DETECTED"
- **CRITICAL** (75+): "BIOLOGICAL DEBT CRITICAL"

### Biological Cost of Incidents

Each incident has a recovery cost in hours (`rootly_models.dart: biologicalCostHours`):
- sev0: 72h (3 days)
- sev1: 48h (2 days)
- sev2: 12h
- sev3: 4h

After-hours incidents (10PM-6AM) cost **1.5x** more recovery time. This is auto-detected from the incident timestamp.

## App Screens

The app launches directly into `BurnoutHome` (no onboarding flow for the demo). It has 5 tabs:

### 1. Dashboard (`burnout_dashboard.dart`)
The main screen. Shows:
- **Resilience Delta** gauge - a custom-painted arc showing composite score
- **Rootly OCH** tile - operational load score from Rootly
- **Sleep Risk** tile - biological recovery deficit from wearable data
- **Shift stats** - incidents, after-hours pages, on-call hours, avg MTTR
- **Sleep sparkline** - 7-day sleep efficiency trend (CustomPaint)
- **Telemetry insights** - auto-generated text explaining what's happening
- **OCH risk factors** - chips showing specific risk signals from Rootly
- **Quick nav buttons** to Timeline and Circuit Breaker

Has a theme toggle button in the AppBar (light/dark mode).

### 2. Timeline (`incident_timeline.dart`)
Shows each incident as a card with:
- Severity badge, title, timestamps, MTTR
- **Biological cost** in recovery hours
- After-hours flag with 1.5x multiplier note
- Visual timeline connector between incidents

### 3. Circuit Breaker (`circuit_breaker.dart`)
The action screen. When Recovery Debt is high, offers 4 interventions:

1. **Generate Smart Handoff** - creates an AI-summarized handoff document
   - Production: calls Rootly MCP `get_oncall_handoff_summary`
   - Shows the generated markdown in a dialog

2. **Request Shift Override** - finds backup and creates override
   - Production: `POST /v1/override_shifts`
   - Shows confirmation with replacement engineer name

3. **Silence Non-Critical Alerts** - filters sev3/sev4 for 4 hours
   - Production: updates alert rules via Rootly API

4. **Escalate to Backup** - moves you to secondary status
   - Has a confirmation dialog before executing
   - Production: `POST /v1/escalation_policies`

Each action card shows the API endpoint it would call, has a loading state, and flips to a "completed" state with a checkmark.

### 4. Wearable Connect (`wearable_connect.dart`)
Device pairing screen for:
- Apple Watch (Series 4+)
- Fitbit (Sense, Versa 3+, Charge 5+)
- Garmin (Venu, Forerunner, Fenix)
- Samsung Galaxy Watch (Watch 4+)

Each card shows what signals it collects (HR, HRV, Sleep Stages, etc). Connection is simulated with a 2-second delay. "WHAT WE COLLECT" section lists the actual biometrics. Privacy note: all health data stays on-device.

### 5. Recovery (`burnout_home.dart: _RecoveryScreen`)
Bridges to wellness features:
- **4-7-8 Breathing** - navigates to `BreatheScreen`
- **Incident Debrief Journal** - navigates to `JournalScreen`
- **Sleep Optimization** - shows sleep coaching dialog with recommendations

Shows a recovery target: current composite score -> target of < 25, with estimated days to full recovery.

## Data Flow

```
Rootly API                    Wearable (DREAMT dataset)
    |                              |
    v                              v
OCH Score (0-100)            SleepMetrics
Risk Factors                 (efficiency, deep sleep,
Incident List                fragmentation, RMSSD,
                             sleep latency)
    |                              |
    v                              v
MockRootlyService            MockWellnessService
    |                              |
    +--------- FUSION ------------+
                  |
                  v
          ResilienceDelta
          (compositeScore, delta, insights)
                  |
          +-------+-------+
          |       |       |
          v       v       v
      Dashboard  Timeline  Circuit Breaker
```

Currently everything uses mock data (`MockRootlyService`, `MockWellnessService`). In production:
- Rootly data would come through the Node.js backend (`backend/server.js`) which proxies to Rootly REST API
- Wearable data would come from HealthKit/Google Health Connect via the wearable connection

## DREAMT Dataset

The sleep data parameters are based on the **DREAMT dataset** from PhysioNet (Duke University). 100 participants wore smartwatch-grade sensors (PPG, accelerometer, EDA, skin temperature) for multi-night sleep tracking. The mock data in `MockWellnessService.getWeeklySleep()` shows a realistic 7-day degradation pattern: good baseline -> incident disruption -> compounding sleep debt.

## Theme System

`lib/theme/obs_theme.dart` controls all visual styling.

**Brand palette:**
- Text: #11363E (dark teal)
- Background: #CCE7E2 (mint)
- Surface/containers: #FFFFFF
- Fonts: RubikOne (titles), Telegraf/SpaceGrotesk (body)

**How it works:**
- Static colors for things that don't change between themes (critical, warning, highlights)
- `xxxOf(context)` methods for theme-aware colors: `bgOf()`, `surfaceOf()`, `textPrimaryOf()`, `safeOf()`, etc.
- `isDark(context)` checks `Theme.of(context).brightness`
- `tierColor(score)` and `tierLabel(score)` map composite scores to colors/labels

**Dark mode:**
- Background: #0D0D0D
- Surface: #1A1A1A
- Text: #E0E0E0
- Accent: #00FF41 (terminal green)

Theme toggle is in the Dashboard AppBar. State managed by `AppState.toggleTheme()`.

**CustomPainter note:** `CustomPainter` classes don't have `BuildContext`, so theme-aware colors must be passed as constructor parameters. See `_ResilienceGaugePainter(borderColor:)` and `_SleepSparklinePainter(safeColor:)`.

## Backend

Node.js Express server on port 3001. File: `backend/server.js`.

**Endpoints:**
| Endpoint | Description |
|---|---|
| `GET /resilience-score` | Biological score from wearable data |
| `GET /recovery-debt` | Full ResilienceEngine pipeline output |
| `GET /recommendation` | Prioritized action items based on state |
| `GET /incidents` | Rootly incident list + OCH score |
| `GET /incidents/biological-impact` | Each incident mapped to biological cost |
| `GET /sleep-timeline` | 7-day sleep data for sparkline |
| `GET /hrv-timeline` | Hourly HRV with optional time filter |
| `GET /handoff-summary` | Generated handoff document |
| `POST /override-request` | Simulate shift override via Rootly |

The backend is not currently connected to the Flutter app (app uses `MockRootlyService` directly). To connect: `lib/services/resilience_bridge.dart` would make HTTP calls to these endpoints.

## File Structure

```
light/
  lib/
    main.dart                          # Entry point, Provider setup, MaterialApp
    models/
      rootly_models.dart               # RootlyIncident, OnCallHealthScore, SleepMetrics, ResilienceDelta
      mood_entry.dart                  # MoodEntry model (unused in burnout flow)
      journal_entry.dart               # JournalEntry model
    screens/
      burnout/
        burnout_home.dart              # Tab shell (5 tabs) + Recovery screen
        burnout_dashboard.dart         # Main dashboard with gauge + sparkline
        incident_timeline.dart         # Incident cards with biological cost
        circuit_breaker.dart           # 4 intervention actions
        wearable_connect.dart          # Device pairing UI
      breathe/breathe_screen.dart      # 4-7-8 breathing exercise
      journal/journal_screen.dart      # CBT thought record
      chat/chat_screen.dart            # Chat (unused in demo)
      home/home_screen.dart            # Original home (unused in demo)
      onboarding/                      # Onboarding flow (unused in demo)
      progress/progress_screen.dart    # Progress tracking (unused in demo)
    services/
      app_state.dart                   # ChangeNotifier: theme, mood entries, streaks
      mock_rootly_service.dart         # Mock incident + sleep data
      resilience_bridge.dart           # HTTP client for backend (not yet wired)
      crisis_service.dart              # Crisis resources
    theme/
      obs_theme.dart                   # Brand palette, theme-aware helpers, ThemeData
      app_theme.dart                   # Old theme (unused)
    widgets/                           # Reusable widgets (mood card, actions, streaks)
  backend/
    server.js                          # Express server (port 3001)
    resilience-engine.js               # ResilienceEngine computation class
    mock-data.js                       # Mock data generators
    package.json                       # Node dependencies (express, cors)
  fonts/
    RubikOne-Regular.ttf               # Title font
    SpaceGrotesk-Variable.ttf          # Body font (registered as "Telegraf")
    Poppins-*.ttf                      # Legacy fonts
  pitch-deck.html                      # 8-slide presentation (arrow keys, N for notes)
  architecture-diagram.html            # System architecture visualization
```

## How To Run

```bash
# Flutter app (iOS simulator)
cd light
flutter run

# Backend (optional, not connected to app yet)
cd backend
npm install
node server.js
# Runs on http://localhost:3001

# Open pitch deck
open pitch-deck.html

# Open architecture diagram
open architecture-diagram.html
```

## State Management

Uses `provider` package. Single `AppState` (ChangeNotifier) holds:
- `themeMode` - light/dark toggle
- `moodEntries` - mood check-in history
- `journalEntries` - journal entries
- `currentStreak` / `longestStreak` - consecutive activity days
- `breathingSessionsCompleted` / `exercisesCompleted` - counters

The burnout screens don't use AppState for data. They call `MockRootlyService` and `MockWellnessService` static methods directly in their `build()` methods.

## Rootly Integration Points

Currently mocked. In production, these would be real API calls:

| Feature | Mock | Production |
|---|---|---|
| OCH Score | `MockRootlyService.getOCHScore()` returns 67 | Rootly On-Call Health API |
| Incidents | `MockRootlyService.getRecentIncidents()` returns 7 incidents | `GET /v1/incidents` |
| Handoff | `MockRootlyService.generateHandoffSummary()` returns template | Rootly MCP `get_oncall_handoff_summary` |
| Shift Override | Simulated with 2s delay | `POST /v1/override_shifts` |
| Alert Silencing | Simulated with 2s delay | Rootly MCP alert management |
| Escalation | Simulated with 2s delay | `POST /v1/escalation_policies` |
| Sleep Data | `MockWellnessService.getWeeklySleep()` returns 7 days | HealthKit / Google Health Connect |
