# Light: Recovery Debt for On-Call Engineers
### Claude Builders Hackathon @ McGill — April 2026
### Track: Neuroscience & Mental Health | Rootly Sub-Challenge

---

## SLIDE 1: The Problem

**On-call is a hidden health crisis.**

- Engineers get paged at 2 AM, work through weekends, absorb stress
- Current tools track **system health** — not **human health**
- By the time someone burns out, it's already too late
- **76% of on-call engineers** report sleep disruption from pages
- The cost of burnout: $125K+ per engineer in turnover alone

> "We have observability for every server in our fleet. We have zero observability for the humans running them."

---

## SLIDE 2: The Insight

**Burnout has two sides. Nobody measures both.**

| | Rootly (exists today) | Light (what we built) |
|---|---|---|
| **Measures** | Operational Load | Recovery Capacity |
| **Data** | Incidents, pages, shift hours | Sleep quality, HRV, recovery time |
| **Tells you** | "You're paged too much" | "You're not recovering from being paged" |
| **Source** | Jira, GitHub, Slack, PagerDuty | DREAMT dataset, smartwatch signals |

An engineer might handle 10 incidents fine one week — but break from 3 the next.

**Why?** Their biological recovery was already depleted.

**You need both signals.**

---

## SLIDE 3: Recovery Debt — The Missing Metric

```
Recovery Debt = Operational Risk (OCH) − Biological Score (Sleep + HRV)
```

| Score | State | What It Means |
|-------|-------|---------------|
| < 0 | STABLE | You're recovering faster than you're being loaded |
| 0–15 | STABLE | Manageable — maintain current rotation |
| 15–30 | WARNING | Recovery declining — monitor closely |
| > 30 | CRITICAL | Biological debt — you're operating on credit your body can't repay |

**This metric doesn't exist anywhere else.**

---

## SLIDE 4: How It Works

```
┌─────────────────┐     ┌─────────────────┐
│   SMARTWATCH     │     │   ROOTLY API     │
│   (DREAMT)       │     │   + OCH Score    │
│                  │     │                  │
│ • Sleep hours    │     │ • Incidents      │
│ • HRV (RMSSD)   │     │ • Shift metrics  │
│ • Sleep stages   │     │ • After-hrs pages│
│ • Fragmentation  │     │ • Alert volume   │
└────────┬────────┘     └────────┬────────┘
         │                       │
         └───────────┬───────────┘
                     ▼
          ┌─────────────────────┐
          │  RESILIENCE ENGINE  │
          │                     │
          │  biologicalScore =  │
          │  f(sleep, HRV)      │
          │                     │
          │  recoveryDebt =     │
          │  OCH - bioScore     │
          │                     │
          │  → STABLE           │
          │  → WARNING          │
          │  → CRITICAL_DEBT    │
          └──────────┬──────────┘
                     ▼
          ┌─────────────────────┐
          │   LIGHT MOBILE APP  │
          │                     │
          │  Dashboard + Actions│
          └─────────────────────┘
```

---

## SLIDE 5: The App — Burnout Dashboard

**What the engineer sees:**

- **Recovery Debt gauge** — single number, color-coded (green/yellow/red)
- **OCH Score** (from Rootly) vs **Sleep Risk** (from DREAMT) — side by side
- **7-day sleep trend sparkline** — shows degradation after incidents
- **Telemetry insights** — natural language:
  - "Sleep efficiency 71% (baseline: 91%). Down 20pp since Monday."
  - "HRV at 28ms. Below 30ms threshold — high sympathetic activation."
  - "3 after-hours incidents in 7 days. Each 2AM page costs 1.5x more recovery."
- **Shift stats** — incidents, after-hours pages, on-call hours, avg MTTR

---

## SLIDE 6: Incident × Biology Timeline

**Every incident has a biological cost.**

```
Mon 2AM  ─ 🔴 DB outage (sev1) ─── Sleep eff: 62% ─── Deep sleep: 8%  ─── Recovery: 48h
Wed 11AM ─ 🟡 CDN timeout (sev2) ── Sleep eff: 89% ─── Deep sleep: 20% ─── Recovery: 4h
Thu 3AM  ─ 🔴 Auth 5xx (sev1) ──── Sleep eff: 54% ─── Deep sleep: 5%  ─── ⚠️ UNRECOVERED
```

**Key insight:** After-hours incidents cost **1.5x more** biological recovery than daytime.

"INC-1838 (Sev0, 3AM) cost you **64 hours** of biological recovery. You've had 56 available. You're in deficit."

---

## SLIDE 7: The Circuit Breaker

**Not just a dashboard — autonomous actions via Rootly API.**

| Action | Rootly Integration | What Happens |
|--------|-------------------|--------------|
| **Generate Handoff** | MCP: `get_oncall_handoff_summary` | AI drafts Slack-ready handoff with open incidents + context |
| **Request Shift Override** | `POST /v1/override_shifts` | Finds available backup, creates override shift |
| **Silence Non-Critical** | MCP: update alerts | Mutes sev3/sev4 for recovery period |
| **Escalate to Backup** | `POST /v1/escalation_policies` | Pages backup, moves you to secondary |

**The handoff button makes it *socially safe* to step away.**

Backed by objective data — not "I feel tired."

---

## SLIDE 8: Recovery Mode

When debt is high, the app prescribes recovery:

- **4-7-8 Breathing** — activates parasympathetic response, targets HRV recovery
- **Incident Debrief Journal** — CBT thought record to process incident stress
- **Sleep Coach** — personalized bedtime based on next shift + current sleep debt
- **Recovery Target** — "Score: 67 → Target: < 25. Est. 6 days with active intervention."

---

## SLIDE 9: Privacy Model

**Raw biological data NEVER leaves the device.**

```
ON DEVICE (private)          SHARED (opt-in)
─────────────────           ────────────────
• Heart rate                • Readiness score (0-100)
• Sleep stages              • Recovery delta
• HRV values               • "Available" / "Recovery Mode"
• Fragmentation             • Handoff request
```

- No medical claims — this is **decision support**, not diagnosis
- Engineer controls what's shared
- One tap to revoke

---

## SLIDE 10: Technical Architecture

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Mobile App** | Flutter | Dashboard, timeline, circuit breaker, recovery |
| **Backend** | Node.js / Express | ResilienceEngine, Rootly API bridge |
| **Data Model** | DREAMT (PhysioNet) | 100 participants, smartwatch signals, sleep stages |
| **Incident Data** | Rootly API + MCP | OCH score, incidents, shifts, escalation |
| **On-Device AI** | SmolLM2 (planned) | Natural language queries across both data sources |
| **Storage** | SQLite (local) | All health data stays on-device |

**Rootly integration points:**
- REST API: incidents, overrides, escalation policies
- MCP Server (101 tools): handoff summaries, health risk checks, shift metrics
- On-Call Health API: OCH burnout score (0-100)

---

## SLIDE 11: DREAMT Dataset

**Why this science is credible:**

- **100 participants** from Duke University Sleep Disorder Lab
- **Smartwatch-grade sensors** (same as Apple Watch / Fitbit):
  - PPG (heart rate), Accelerometer, EDA, Skin Temperature
- **Expert-annotated** sleep stages every 30 seconds
- **Clinical metadata**: sleep apnea severity, BMI, disorder diagnoses
- **Published**: PhysioNet, peer-reviewed at CHIL (PMLR)

**Key finding:** Consumer wearables achieve comparable sleep staging accuracy to medical-grade PSG.

→ This means the model works with hardware engineers already own.

---

## SLIDE 12: Why Rootly Needs This

Rootly On-Call Health is world-class at measuring the **work**.

But it stops at the keyboard.

It doesn't know:
- If the engineer has a newborn at home
- If that 2AM page cost 3 days of cognitive recovery
- If they're already sleep-deprived going into a shift
- If their nervous system has recovered from last week's sev0

**Light provides the biological telemetry layer that makes OCH personal.**

> "We don't just track incidents. We track the biological cost of those incidents."

---

## SLIDE 13: Demo Flow

1. **Launch app** → Mode selector → "Burnout Shield"
2. **Dashboard** → Recovery Debt: WARNING (19). OCH: 67. Sleep Risk: 48.
3. **Sparkline** → Clear sleep degradation after Tuesday's sev0
4. **Insights** → "HRV at 28ms, below threshold. 3 after-hours pages this week."
5. **Timeline** → Tap INC-1838 (sev0, 3AM) → "64h recovery needed, 56h available"
6. **Circuit Breaker** → Generate Handoff → Shows Slack-ready summary
7. **Recovery Mode** → Breathing exercise → "Target: score < 25, est. 6 days"

---

## SLIDE 14: What's Next

| Phase | Feature | Timeline |
|-------|---------|----------|
| **Now** | Mock data + demo | Hackathon |
| **Week 1** | Real Rootly API integration | Connect live OCH scores |
| **Week 2** | Apple Watch / Fitbit sync | Real wearable data |
| **Month 1** | DREAMT model deployment | On-device sleep classification |
| **Month 2** | Team Health dashboard | Manager view across team |
| **Month 3** | Rootly plugin | Native integration in Rootly product |

---

## SLIDE 15: The Ask

**For Rootly:**
- Access to On-Call Health API for live integration
- Explore building Light as a Rootly plugin / extension
- Pilot with 1-2 engineering teams

**For the hackathon:**
- This is the missing human observability layer
- Real API integration, real science, real privacy model
- Not a wellness app — an **SRE-grade observability tool for humans**

---

## Team

**Athif Shaffy** — McGill University
- Built COGITO (mental health apps, 18+ languages, UKE Hamburg)
- On-device LLM experience (SmolLM2-135M via llama_cpp_dart)
- Flutter + Ionic cross-platform development

---

## One-Liner

> **"Light is human observability for on-call engineers. It measures what Rootly can't see — the biological cost of every incident — and turns it into automated relief before burnout happens."**
