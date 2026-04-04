const express = require('express');
const cors = require('cors');
const { ResilienceEngine } = require('./resilience-engine');
const {
  mockIncidents,
  mockOCHScore,
  mockShiftMetrics,
  mockSleepTimeline,
  mockHRVTimeline,
  mockHandoffSummary,
} = require('./mock-data');

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3001;

// ─────────────────────────────────────────────
// Health check
// ─────────────────────────────────────────────
app.get('/', (req, res) => {
  res.json({
    service: 'Light Resilience Bridge',
    version: '1.0.0',
    status: 'operational',
    endpoints: [
      'GET  /resilience-score',
      'GET  /recovery-debt',
      'GET  /recommendation',
      'GET  /incidents',
      'GET  /incidents/biological-impact',
      'GET  /sleep-timeline',
      'GET  /hrv-timeline',
      'GET  /handoff-summary',
      'POST /override-request',
    ],
  });
});

// ─────────────────────────────────────────────
// GET /resilience-score
// Returns biological score from wearable data.
// In production: mobile app sends aggregated score.
// For demo: computed from mock DREAMT data.
// ─────────────────────────────────────────────
app.get('/resilience-score', (req, res) => {
  const latest = mockSleepTimeline[mockSleepTimeline.length - 1];
  const hrvNormalized = Math.min(100, (latest.rmssd / 50) * 100);
  const biologicalScore = ResilienceEngine.computeBiologicalScore(latest.sleepHours, hrvNormalized);

  res.json({
    biologicalScore,
    components: {
      sleepHours: latest.sleepHours,
      sleepEfficiency: latest.efficiency,
      deepSleepPct: latest.deepSleepPct,
      rmssd: latest.rmssd,
      hrvNormalized: Math.round(hrvNormalized),
      fragmentation: latest.fragmentation,
    },
    baseline: {
      sleepHours: 7.8,
      sleepEfficiency: 91,
      rmssd: 42,
    },
    timestamp: new Date().toISOString(),
  });
});

// ─────────────────────────────────────────────
// GET /recovery-debt
// The core metric: operationalRisk - biologicalScore.
// Runs the full ResilienceEngine pipeline.
// ─────────────────────────────────────────────
app.get('/recovery-debt', (req, res) => {
  const latest = mockSleepTimeline[mockSleepTimeline.length - 1];
  const hrvNormalized = Math.min(100, (latest.rmssd / 50) * 100);

  const result = ResilienceEngine.compute({
    operationalRisk: mockOCHScore.score,
    incidentEvents: mockIncidents,
    sleepHours: latest.sleepHours,
    hrvScore: hrvNormalized,
    hrvTimeline: mockHRVTimeline,
  });

  res.json(result);
});

// ─────────────────────────────────────────────
// GET /recommendation
// Returns prioritized action items.
// ─────────────────────────────────────────────
app.get('/recommendation', (req, res) => {
  const latest = mockSleepTimeline[mockSleepTimeline.length - 1];
  const hrvNormalized = Math.min(100, (latest.rmssd / 50) * 100);

  const result = ResilienceEngine.compute({
    operationalRisk: mockOCHScore.score,
    incidentEvents: mockIncidents,
    sleepHours: latest.sleepHours,
    hrvScore: hrvNormalized,
    hrvTimeline: mockHRVTimeline,
  });

  res.json({
    state: result.state,
    recoveryDebt: result.recoveryDebt,
    recommendations: result.recommendations,
    timestamp: result.timestamp,
  });
});

// ─────────────────────────────────────────────
// GET /incidents
// Returns Rootly incident list + OCH score.
// In production: proxies to Rootly API.
// ─────────────────────────────────────────────
app.get('/incidents', (req, res) => {
  res.json({
    ochScore: mockOCHScore,
    shiftMetrics: mockShiftMetrics,
    incidents: mockIncidents,
  });
});

// ─────────────────────────────────────────────
// GET /incidents/biological-impact
// Maps each incident to its biological cost.
// The key visualization data for the timeline.
// ─────────────────────────────────────────────
app.get('/incidents/biological-impact', (req, res) => {
  const impacts = ResilienceEngine.mapIncidentsToBiologicalImpact(
    mockIncidents,
    mockSleepTimeline,
    mockHRVTimeline
  );

  res.json({
    impacts,
    totalRecoveryHoursNeeded: impacts.reduce((s, i) => s + i.biologicalCost.recoveryHoursNeeded, 0),
    availableRecoveryHours: 56, // ~8h sleep × 7 days
    recoveryDeficit: impacts.reduce((s, i) => s + i.biologicalCost.recoveryHoursNeeded, 0) - 56,
    unrecoveredCount: impacts.filter(i => i.status === 'RECOVERY_INCOMPLETE').length,
  });
});

// ─────────────────────────────────────────────
// GET /sleep-timeline
// 7-day sleep data for sparkline visualization.
// ─────────────────────────────────────────────
app.get('/sleep-timeline', (req, res) => {
  res.json({
    timeline: mockSleepTimeline,
    baseline: { sleepHours: 7.8, efficiency: 91, rmssd: 42 },
    alerts: mockSleepTimeline
      .filter(d => d.efficiency < 85)
      .map(d => ({
        date: d.date,
        message: `Sleep efficiency ${d.efficiency}% (below 85% threshold)`,
        severity: d.efficiency < 65 ? 'critical' : 'warning',
      })),
  });
});

// ─────────────────────────────────────────────
// GET /hrv-timeline
// Hourly HRV for incident-to-dip overlay.
// ─────────────────────────────────────────────
app.get('/hrv-timeline', (req, res) => {
  // Optionally filter by time range
  const hours = parseInt(req.query.hours) || 168; // default 7 days
  const cutoff = new Date(Date.now() - hours * 60 * 60 * 1000);
  const filtered = mockHRVTimeline.filter(p => new Date(p.timestamp) >= cutoff);

  res.json({
    timeline: filtered,
    baseline: 40,
    stressThreshold: 30,
    currentValue: filtered[filtered.length - 1]?.value || 0,
  });
});

// ─────────────────────────────────────────────
// GET /handoff-summary
// Generates handoff doc for clean transition.
// In production: calls Rootly MCP get_oncall_handoff_summary.
// ─────────────────────────────────────────────
app.get('/handoff-summary', (req, res) => {
  res.json({
    summary: mockHandoffSummary,
    generated_at: new Date().toISOString(),
    rootly_action: 'MCP: get_oncall_handoff_summary',
  });
});

// ─────────────────────────────────────────────
// POST /override-request
// Simulates requesting a shift override via Rootly.
// In production: POST /v1/override_shifts
// ─────────────────────────────────────────────
app.post('/override-request', (req, res) => {
  const { reason } = req.body || {};

  res.json({
    status: 'requested',
    override: {
      id: 'OVR-' + Date.now().toString(36),
      current_oncall: 'You',
      replacement: 'Sarah K.',
      starts_at: new Date().toISOString(),
      ends_at: new Date(Date.now() + 12 * 60 * 60 * 1000).toISOString(),
      reason: reason || 'Recovery debt critical — biological signals indicate insufficient recovery capacity',
      rootly_action: 'POST /v1/override_shifts',
    },
    notification: {
      sent_to: 'Sarah K.',
      channel: '#oncall-team',
      message: 'Override requested. Recovery debt score: CRITICAL_DEBT.',
    },
  });
});

// ─────────────────────────────────────────────
app.listen(PORT, () => {
  console.log(`\n  Light Resilience Bridge`);
  console.log(`  ─────────────────────`);
  console.log(`  Running on http://localhost:${PORT}`);
  console.log(`  Endpoints:`);
  console.log(`    GET  /resilience-score`);
  console.log(`    GET  /recovery-debt`);
  console.log(`    GET  /recommendation`);
  console.log(`    GET  /incidents`);
  console.log(`    GET  /incidents/biological-impact`);
  console.log(`    GET  /sleep-timeline`);
  console.log(`    GET  /hrv-timeline`);
  console.log(`    GET  /handoff-summary`);
  console.log(`    POST /override-request\n`);
});
