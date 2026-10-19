/**
 * Mock data generators for demo.
 * Simulates Rootly API responses and DREAMT-derived wearable data.
 */

const now = new Date();
const hoursAgo = (h) => new Date(now.getTime() - h * 60 * 60 * 1000).toISOString();
const daysAgo = (d) => new Date(now.getTime() - d * 24 * 60 * 60 * 1000).toISOString();

// Simulated Rootly incidents (past 7 days)
const mockIncidents = [
  {
    id: 'INC-1847',
    title: 'Database connection pool exhausted',
    severity: 'sev1',
    status: 'resolved',
    timestamp: hoursAgo(6),
    resolved_at: hoursAgo(4),
    mttr_minutes: 132,
  },
  {
    id: 'INC-1842',
    title: 'Auth service 5xx spike (>15%)',
    severity: 'sev1',
    status: 'resolved',
    timestamp: hoursAgo(26),  // ~1 day + 2hrs ago
    resolved_at: hoursAgo(24),
    mttr_minutes: 107,
  },
  {
    id: 'INC-1838',
    title: 'Payment webhook delivery failures',
    severity: 'sev0',
    status: 'resolved',
    timestamp: hoursAgo(51),  // ~2 days ago, 3AM
    resolved_at: hoursAgo(46),
    mttr_minutes: 303,
  },
  {
    id: 'INC-1835',
    title: 'CDN cache purge timeout',
    severity: 'sev2',
    status: 'resolved',
    timestamp: hoursAgo(86),  // ~3.5 days
    resolved_at: hoursAgo(85),
    mttr_minutes: 45,
  },
  {
    id: 'INC-1831',
    title: 'Kubernetes node OOM - prod-worker-7',
    severity: 'sev1',
    status: 'resolved',
    timestamp: hoursAgo(97),  // ~4 days ago, 1AM
    resolved_at: hoursAgo(94),
    mttr_minutes: 195,
  },
  {
    id: 'INC-1828',
    title: 'API latency p99 > 2s on /search',
    severity: 'sev3',
    status: 'resolved',
    timestamp: hoursAgo(130),
    resolved_at: hoursAgo(129),
    mttr_minutes: 32,
  },
  {
    id: 'INC-1824',
    title: 'SSL certificate expiry - api.prod',
    severity: 'sev2',
    status: 'resolved',
    timestamp: hoursAgo(160),
    resolved_at: hoursAgo(159),
    mttr_minutes: 55,
  },
];

// Simulated OCH score from Rootly On-Call Health
const mockOCHScore = {
  score: 67,
  trend: -12,
  tier: 'EARLY_INTERVENTION',
  risk_factors: [
    '3 sev0/sev1 incidents in 7 days',
    '2 after-hours pages this week',
    'On-call 3 consecutive weeks',
    'Slack sentiment: declining',
    'PR review backlog: 8 open',
  ],
  computed_at: now.toISOString(),
};

// Simulated shift metrics
const mockShiftMetrics = {
  total_shifts_7d: 3,
  hours_on_call: 52.5,
  incident_count: 7,
  after_hours_pages: 3,
  avg_mttr_minutes: 127,
  primary_shifts: 2,
  secondary_shifts: 1,
};

// Simulated wearable data (DREAMT-derived parameters)
// Shows degradation pattern after incidents
const mockSleepTimeline = [
  { date: daysAgo(6), sleepHours: 7.8, efficiency: 91, deepSleepPct: 22, rmssd: 42, fragmentation: 2.1 },
  { date: daysAgo(5), sleepHours: 7.2, efficiency: 88, deepSleepPct: 19, rmssd: 38, fragmentation: 3.0 },
  { date: daysAgo(4), sleepHours: 7.0, efficiency: 89, deepSleepPct: 20, rmssd: 40, fragmentation: 2.8 },
  { date: daysAgo(3), sleepHours: 4.2, efficiency: 62, deepSleepPct: 8,  rmssd: 22, fragmentation: 7.2 }, // Post sev1 2AM
  { date: daysAgo(2), sleepHours: 3.8, efficiency: 58, deepSleepPct: 6,  rmssd: 19, fragmentation: 8.5 }, // Post sev0
  { date: daysAgo(1), sleepHours: 5.1, efficiency: 64, deepSleepPct: 10, rmssd: 24, fragmentation: 6.8 }, // Still wrecked
  { date: daysAgo(0), sleepHours: 5.8, efficiency: 71, deepSleepPct: 13, rmssd: 28, fragmentation: 5.4 }, // Slow recovery
];

// HRV timeline (hourly) — for incident-to-dip mapping
const mockHRVTimeline = [];
for (let h = 168; h >= 0; h--) {
  // Base HRV around 40, with dips around incident times
  let baseHRV = 40;
  const hoursFromNow = h;

  // Dip patterns after major incidents
  if (hoursFromNow >= 93 && hoursFromNow <= 105) baseHRV = 24;      // After INC-1831 (sev1, 1AM)
  else if (hoursFromNow >= 46 && hoursFromNow <= 70) baseHRV = 19;  // After INC-1838 (sev0, 3AM)
  else if (hoursFromNow >= 24 && hoursFromNow <= 40) baseHRV = 22;  // After INC-1842 (sev1)
  else if (hoursFromNow >= 0 && hoursFromNow <= 12) baseHRV = 26;   // After INC-1847 (sev1)
  else if (hoursFromNow >= 70 && hoursFromNow <= 80) baseHRV = 35;  // Partial recovery

  // Add some noise
  const noise = Math.round((Math.random() - 0.5) * 4);
  mockHRVTimeline.push({
    timestamp: hoursAgo(h),
    value: Math.max(10, baseHRV + noise),
  });
}

// Handoff summary template
const mockHandoffSummary = `## On-Call Handoff Summary
**Outgoing:** You  |  **Incoming:** Sarah K.  |  **Generated:** ${now.toISOString().slice(0, 16)}

### Open Items
- **INC-1847** (Sev1) — DB connection pool exhausted. Resolved, but monitoring for recurrence. Pool size bumped 50→100.
- **INC-1842** (Sev1) — Auth service 5xx. Root cause: bad deploy. Rolled back. Post-mortem scheduled Thursday.

### Watch List
- Payment webhooks (INC-1838) — delivery queue still draining. ETA: 2 hours.
- Node memory on prod-worker-7 — OOM twice this week. INFRA-442 open.

### Context
- Deploy freeze until Thursday per INC-1838 post-mortem
- Backup escalation: Marcus T.

### Recovery Note
⚠️ Outgoing engineer's recovery debt is in CRITICAL range. 3 after-hours pages in 48h. Recommend light shift for next rotation.`;

module.exports = {
  mockIncidents,
  mockOCHScore,
  mockShiftMetrics,
  mockSleepTimeline,
  mockHRVTimeline,
  mockHandoffSummary,
};
