# Fan Enterprise Value Technical Engine Playbook

## How FEV signals are produced, governed, served, activated, and measured

## 1. Purpose

The Fan Enterprise Value Technical Engine Playbook explains how the decision platform runs underneath the strategic playbook.

It defines the data, models, rules, serving layers, activation paths, measurement systems, and governance controls required to make FEV reliable and usable.

This playbook should not lead the strategy. It should support the strategy.

The engine exists to answer:

- What data powers FEV?
- How are value, risk, potential, and confidence signals generated?
- How are business thresholds translated into decision rules?
- How are signals delivered to the systems that act on them?
- How are actions measured?
- How are model changes, data issues, privacy rules, and score drift governed?

## 2. Technical Audience

Primary audiences:

- Data Engineering
- Data Science
- ML Engineering
- Analytics Engineering
- Marketing Technology / CRM Ops
- CDP / Activation Platform owners
- Product Analytics
- Experimentation / Measurement
- Data Governance / Privacy
- BI / Reporting teams

Secondary audiences:

- CRM / Lifecycle
- Product / DTC
- Paid Media
- Partnerships
- International
- Finance / Strategy

Business teams should understand the technical engine at a conceptual level, but they should not need to inspect pipelines or model mechanics to use FEV responsibly.

## 3. Technical Premise

The FEV engine is not one model. It is a decision infrastructure made of several connected layers.

Recommended architecture:

1. Source data layer
2. Feature and identity layer
3. Signal generation layer
4. Decision rules layer
5. Serving and activation layer
6. Measurement layer
7. Governance and monitoring layer

Each layer should map back to one or more strategic decision plays.

If a technical capability does not support a decision play, it should not be prioritized ahead of capabilities that do.

## 4. Source Data Layer

The source layer provides the raw ingredients for FEV signals.

### 4.1 Core Fan Identity Inputs

- Fan ID
- NBA ID
- Identity graph keys
- Email / CRM IDs where permitted
- Device or platform identifiers where permitted
- Household or account relationships where appropriate and approved
- Consent and contact eligibility

### 4.2 Revenue and Transaction Inputs

- League Pass / DTC subscription revenue
- Subscription plan, SKU, tenure, renewal status
- Commerce / Fanatics revenue where permitted
- Ticketing revenue and attendance
- Vision or other product revenue
- Attributed acquisition revenue
- Refunds, cancellations, chargebacks where available
- Margin or contribution inputs where available

### 4.3 Engagement Inputs

- App engagement
- Web engagement
- Email sends, opens, clicks
- Push engagement
- Watch activity
- Highlights, articles, video, and content consumption
- Fantasy participation
- Badges, challenges, programs
- Favorite team / player behavior
- First activity and last activity
- Seasonality and event-window behavior

### 4.4 Product and Subscription Inputs

- Product SKU
- Subscription length
- Payment platform
- Renewal date
- Cancellation date
- Trial status
- Device usage
- Feature usage
- Onboarding completion
- Product friction indicators

### 4.5 Campaign and Marketing Inputs

- Campaign ID
- Channel
- Creative
- Audience definition
- Treatment date
- Campaign cost
- Tracking code
- Attribution method
- Holdout / experiment flag

### 4.6 Partner Inputs

- Partner ID
- Partner audience membership
- Partner engagement signals where permitted
- Approved usage scope
- Overlap with owned channels
- Partner revenue or influenced activity

### 4.7 Market and Strategic Inputs

- Country
- Region
- City
- Language where available and permitted
- Local time zone
- Favorite team / player with market relevance
- International market priority
- Event or content calendar
- Local product availability
- Payment availability or limitations

## 5. Feature and Identity Layer

The feature layer converts source data into reusable, governed inputs.

### 5.1 Feature Spine

The fan-level feature spine should provide a stable daily view of fan attributes, behavior, value history, and eligibility.

Recommended requirements:

- One row per fan per score date
- Stable fan identifier
- Refresh timestamp
- Source lineage
- Consent flags
- Contact eligibility flags
- Feature freshness indicators
- Sparse-data indicators

### 5.2 Feature Groups

Recommended feature groups:

- Historical value
- Recent engagement
- Engagement durability
- Product usage
- Subscription lifecycle
- Campaign response
- Content affinity
- Team/player affinity
- Program participation
- Partner context
- Market context
- Risk indicators
- Growth indicators
- Data quality / confidence indicators

### 5.3 Identity Rules

The engine must define how fan identities are resolved and used.

Key questions:

- What is the primary fan identifier?
- How are anonymous, registered, subscribed, and purchasing identities connected?
- What identity confidence is required for activation?
- What identifiers are allowed in each downstream system?
- How are merges, splits, and identity updates handled?

### 5.4 Data Eligibility

Every feature should have usage metadata.

Recommended fields:

- Allowed for modeling
- Allowed for activation
- Allowed for reporting
- Allowed for partner use
- Consent requirement
- Retention period
- Source owner
- Sensitivity level

## 6. Signal Generation Layer

The signal layer produces the outputs that the strategic playbook acts on.

### 6.1 Observed Value

Historical realized value from known revenue or attributable behavior.

Examples:

- 12-month observed revenue
- 24-month observed revenue
- Product-level revenue
- Order count
- Subscription tenure
- Ticketing activity
- Commerce activity

### 6.2 Predicted Future Value

Expected future value over a defined horizon.

Recommended horizons:

- 12-month predicted enterprise value
- 24-month predicted enterprise value

Recommended outputs:

- Predicted value
- Prediction interval or confidence band
- Model version
- Score date
- Top drivers

### 6.3 Retention / Dormancy Risk

Likelihood of churn, renewal failure, dormancy, or engagement decline.

Recommended outputs:

- Risk score
- Risk tier
- Primary risk reason code
- Risk confidence
- Recommended diagnostic category

### 6.4 Growth Potential

Likelihood that a fan relationship can expand in depth, value, product adoption, or strategic importance.

Recommended outputs:

- Growth potential score
- Growth tier
- Product or engagement opportunity
- Top opportunity drivers

### 6.5 Opportunity Gap

Difference between likely fan interest and current fan behavior.

Recommended examples:

- Engagement-to-monetization gap
- Content affinity gap
- Product education gap
- Team/player personalization gap
- App feature adoption gap
- Renewal readiness gap

### 6.6 Product Propensity

Likelihood of relevant product adoption or upgrade.

Recommended outputs:

- Product propensity score
- Product fit reason code
- Eligibility flag
- Suppression flag where applicable

### 6.7 Partner Value Signal

Value associated with partner-linked or partner-engaged fan audiences.

Recommended outputs:

- Partner-linked value
- Partner audience quality index
- Overlap estimate
- Incrementality confidence
- Approved usage flag

### 6.8 Strategic Market Value

Long-term market or segment potential that may not be captured by direct current revenue.

Recommended outputs:

- Market strategic value tier
- Market growth signal
- Local engagement durability
- Player/team affinity strength
- Monetization readiness
- Strategic confidence

### 6.9 Confidence Signal

Every major score should have a confidence indicator.

Recommended confidence inputs:

- Data completeness
- Feature freshness
- Historical depth
- Identity confidence
- Score stability
- Model calibration
- Sparse-data flags
- Known source issues

## 7. Decision Rules Layer

The decision rules layer translates signals into action eligibility.

This is where the strategic playbook becomes operational.

### 7.1 Rule Types

Recommended rule types:

- Value tier rules
- Risk tier rules
- Growth tier rules
- Opportunity gap rules
- Product eligibility rules
- Channel eligibility rules
- Consent rules
- Frequency caps
- Suppression rules
- Confidence gates
- Escalation rules
- Measurement assignment rules

### 7.2 Example Rule Logic

#### Example 1: Save Path Eligibility

A fan is eligible for save-path treatment if:

- FEV tier is Enterprise Critical or High Value
- Retention risk is High
- Contact eligibility is true
- Confidence is Medium or High
- Fan is not already in conflicting treatment
- Holdout assignment allows treatment

#### Example 2: Conversion Path Eligibility

A fan is eligible for high-potential conversion treatment if:

- Growth potential is High
- Current direct revenue is Low or Zero
- Engagement durability is Medium or High
- Product fit exists
- Contact eligibility is true
- The fan is not over-contacted

#### Example 3: Paid Media Suppression

An audience may be suppressed from high-cost retargeting if:

- FEV is Low Current Priority
- Growth potential is Low
- Strategic value is Low
- Confidence is High
- No active strategic exception applies

#### Example 4: Product Friction Escalation

A friction issue should be escalated if:

- Affected fans include high-FEV or high-growth-potential fans
- The friction repeats across a meaningful audience
- The estimated value at risk crosses an agreed threshold
- Product owner is assigned

### 7.3 Rule Governance

Business rules should be versioned and owned.

Recommended metadata:

- Rule ID
- Rule name
- Business owner
- Technical owner
- Rule version
- Effective date
- Expiration date if applicable
- Approved use case
- Measurement requirement
- Governance approval status

## 8. Serving and Activation Layer

The serving layer delivers FEV outputs to the systems where decisions happen.

### 8.1 Core Serving Tables

Recommended v1 tables:

- `fan_enterprise_value_daily`
- `fan_enterprise_value_reason_codes_daily`
- `fan_enterprise_value_action_eligibility_daily`
- `segment_enterprise_value_daily`
- `campaign_enterprise_value_daily`
- `product_enterprise_value_daily`
- `partner_enterprise_value_daily`
- `market_enterprise_value_daily`

Not all tables need to launch at once. The first priority should be the tables required by the first strategic pilots.

### 8.2 Fan-Level Serving Requirements

Recommended fields:

- `fan_id`
- `score_date`
- FEV tier
- Observed value
- Predicted 12-month value
- Predicted 24-month value
- Retention risk tier
- Growth potential tier
- Opportunity gap
- Strategic value tier
- Confidence level
- Top reason codes
- Action eligibility flags
- Channel eligibility flags
- Consent flags
- Model version
- Rule version
- Refresh timestamp

### 8.3 Activation Destinations

Potential destinations:

- CRM platform
- CDP
- Paid media audiences
- Product personalization systems
- NBA App / web personalization
- Marketing campaign tools
- Partner workflows where approved
- Executive dashboards
- Analytics workbench

### 8.4 Activation Requirements

Each activation destination should define:

- Required identifier
- Allowed fields
- Refresh cadence
- Latency requirement
- Consent constraints
- Suppression rules
- Frequency rules
- Experiment assignment
- Data retention requirement
- Owner

## 9. Measurement Layer

The measurement layer proves whether FEV-driven actions work.

### 9.1 Experiment Assignment

Where feasible, the engine should support:

- Holdout assignment
- Treatment group assignment
- Experiment ID
- Campaign ID
- Treatment date
- Eligibility snapshot
- Score snapshot
- Rule version snapshot

### 9.2 Outcome Capture

The engine should capture outcomes such as:

- Renewal
- Cancellation
- Conversion
- Upgrade
- Revenue
- Engagement
- App activation
- Watch behavior
- Support resolution
- Product feature adoption
- Partner event or action
- Market development milestone

### 9.3 Incrementality Methods

Recommended methods:

- Randomized holdout
- A/B test
- Matched control
- Geo test
- Difference-in-differences
- Synthetic control where appropriate
- Pre/post with controls only when better methods are unavailable

### 9.4 Measurement Outputs

Recommended outputs:

- Incremental enterprise value
- Incremental conversion lift
- Incremental retention lift
- Retained value
- Value per treated fan
- Value per incremental conversion
- Cost per incremental value
- Confidence band
- Recommended scale / pause / revise decision

## 10. Monitoring and Reliability Layer

The engine must be reliable enough for operating decisions.

### 10.1 Data Monitoring

Monitor:

- Row counts
- Feature null rates
- Source freshness
- Distribution shifts
- Identity match rates
- Consent flag availability
- Revenue input completeness
- Engagement input completeness
- Partner feed availability

### 10.2 Model Monitoring

Monitor:

- Score distribution
- Calibration
- Drift
- Feature importance changes
- Prediction error where outcomes are available
- Segment-level performance
- Sparse-data behavior
- Fairness indicators

### 10.3 Rule Monitoring

Monitor:

- Number of fans eligible by rule
- Treatment eligibility changes
- Suppression volumes
- Conflicting rules
- Rule version changes
- Exception rates

### 10.4 Activation Monitoring

Monitor:

- Audience delivery success
- Field delivery success
- Downstream ingestion success
- Duplicate records
- Missing identifiers
- Contact eligibility failures
- Experiment assignment integrity

### 10.5 Refresh and SLA Standards

Recommended standards:

- Daily refresh for core fan FEV signals
- Intraday or event-driven updates only where business action requires it
- Freshness timestamp on all outputs
- Stale score flag
- Rollback process
- Failed refresh alerting
- Business owner notification for high-impact failures

## 11. Governance and Control Layer

FEV requires strong governance because it may influence fan treatment, investment decisions, and partner strategy.

### 11.1 Approved Use Cases

Each use case should be approved before activation.

Recommended approval metadata:

- Use case name
- Business owner
- Data owner
- Systems involved
- Fan data used
- Activation fields used
- Consent basis
- Measurement method
- Expiration or review date

### 11.2 Consent and Eligibility

The engine must ensure that activation respects:

- Email eligibility
- Push eligibility
- Marketing consent
- Partner data restrictions
- Regional privacy rules
- Data retention policies
- Sensitive-use exclusions

### 11.3 Explainability

Each major score should provide reason codes that are understandable to business users.

Recommended reason code categories:

- Recent revenue
- Historical revenue
- Subscription behavior
- Engagement durability
- Product usage
- Team/player affinity
- Program participation
- Campaign response
- Market context
- Risk behavior
- Sparse data

### 11.4 Fairness and Responsible Use

FEV should not be used for sensitive inference, unfair exclusion, or unexplained treatment that creates avoidable harm.

Required controls:

- Fairness checks across approved demographic or geographic dimensions
- Human review for high-impact use cases
- Documentation of allowed and disallowed uses
- Monitoring for systematic underinvestment in strategic audiences
- Review of suppression logic

## 12. Technical Ownership Matrix

| Layer | Primary Owner | Supporting Owners | Key Responsibility |
|---|---|---|---|
| Source data | Data Engineering | Source system owners | Reliable ingestion and source freshness |
| Identity | Data Platform / Identity Team | Governance, CRM Ops | Stable identifiers and matching rules |
| Feature layer | Analytics Engineering | Data Science, Data Engineering | Reusable governed features |
| Models | Data Science | Analytics, Product Lead | Scores, calibration, reason codes, drift |
| Decision rules | Fan Value Product Lead | Business Owners, Data Science, Martech | Translate strategy into action eligibility |
| Serving tables | Data Engineering | Analytics Engineering | Daily outputs, lineage, reliability |
| Activation integrations | Martech / CDP Owners | CRM, Paid Media, Product | Deliver signals to action systems |
| Measurement | Analytics / Experimentation | Business Owners, Data Science | Holdouts, lift reads, outcomes |
| Dashboards | BI / Analytics | Product Lead, Finance | Reporting and decision visibility |
| Governance | Data Governance / Privacy | Legal, Product Lead, Business Owners | Approved use, consent, fairness, audit |
| Operations | Platform Owner | All technical teams | SLAs, alerts, rollback, issue resolution |

## 13. Technical Operating Runbook

### 13.1 Score Refresh Failure

If daily FEV scores fail to refresh:

1. Data Engineering investigates source or pipeline failure.
2. Platform owner flags stale score status.
3. Activation teams are notified if downstream treatment is affected.
4. Use prior-day scores only if approved fallback rules allow it.
5. Incident is documented with root cause and remediation.

### 13.2 Model Version Change

Before a new model version is promoted:

1. Data Science validates calibration and drift.
2. Analytics compares score movement and affected audience sizes.
3. Business owners review expected impact on decision plays.
4. Governance reviews material use-case changes if needed.
5. Rollback plan is documented.
6. Version is released with effective date and release notes.

### 13.3 Threshold Change

Before thresholds are changed:

1. Business owner proposes decision rationale.
2. Analytics estimates audience impact.
3. Finance reviews economics where cost is material.
4. Experimentation confirms measurement plan.
5. Rule version is updated.
6. Change is documented in decision log.

### 13.4 Activation Mismatch

If downstream systems receive incorrect or unexpected audiences:

1. Activation owner pauses affected journey or campaign if needed.
2. Martech/CDP owner checks delivery logs.
3. Data Engineering validates source output.
4. Rule owner checks eligibility logic.
5. Analytics checks treatment and holdout integrity.
6. Issue is documented before restart.

### 13.5 Data Governance Issue

If a data-use concern is raised:

1. Pause affected activation if risk is material.
2. Governance and Privacy review use case and fields.
3. Confirm consent and approved usage.
4. Remove or modify fields if needed.
5. Document decision and update allowed-use registry.

## 14. Technical Roadmap Aligned to Strategy

### Phase 1: Pilot Engine

Supports the first strategic pilots.

Required capabilities:

- Fan-level FEV score
- Retention risk score
- Growth potential score
- Confidence level
- Reason codes
- Action eligibility flags
- CRM/CDP export
- Holdout assignment
- Basic lift measurement
- Daily refresh monitoring

### Phase 2: Decision Expansion

Supports more plays and more operating teams.

Required capabilities:

- Product propensity
- Opportunity gap scoring
- Product friction signals
- Paid media suppression outputs
- Segment value table
- Campaign value measurement
- Rule versioning
- Expanded dashboards

### Phase 3: Enterprise Value Engine

Supports cross-functional planning and investment allocation.

Required capabilities:

- Partner value signal
- Market strategic value signal
- Product value table
- Partner value table
- Market value table
- Incrementality framework across campaigns and partners
- Finance-aligned investment reporting
- Advanced governance and fairness monitoring

## 15. Strategic-to-Technical Mapping

| Strategic Need | Technical Capability | Primary Technical Owner |
|---|---|---|
| Protect high-value fans at risk | FEV tier, risk score, reason codes, contact eligibility | Data Science / Martech |
| Grow high-potential low-revenue fans | Growth potential, opportunity gap, product fit | Data Science / Product Analytics |
| Avoid wasteful paid media | Suppression rules, audience exports, value tiers | Paid Media Tech / Analytics |
| Fix product friction | Product event data, friction flags, value-at-risk reporting | Product Analytics / Data Engineering |
| Measure campaign value | Holdouts, treatment logs, outcome capture | Experimentation / Analytics |
| Evaluate partner value | Partner-linked signals, overlap logic, approved-use flags | Partnerships Analytics / Governance |
| Invest in strategic markets | Market value signal, local engagement, growth indicators | International Analytics / Strategy |
| Govern use | Consent flags, approved-use registry, audit logs | Governance / Privacy |

## 16. Decision Object Model

FEV should operate across multiple decision objects.

| Decision Object | Technical Output | Strategic Use | Primary Business Owner |
|---|---|---|---|
| Fan | Fan-level score and eligibility | Treatment and personalization | CRM / Product |
| Segment | Segment value table | Planning and prioritization | Strategy / Marketing |
| Product | Product value and friction views | Roadmap and packaging | Product / DTC |
| Campaign | Incremental value readout | Scale / pause / revise | Marketing / Analytics |
| Partner | Partner value and overlap views | Commercial strategy | Partnerships |
| Market | Market strategic value signal | Market development | International / Strategy |
| Program | Program lift and value contribution | Program investment | Program Owner |

## 17. Recommended Starting Pilots

### Pilot 1: High-FEV / High-Risk League Pass Save Path

Purpose: protect retained enterprise value.

Primary business owner: CRM / Lifecycle

Required technical capabilities:

- FEV tier
- Retention risk
- League Pass status
- Reason codes
- Contact eligibility
- Holdout assignment
- Renewal outcome tracking

Success metric:

- Incremental retained value and renewal lift

### Pilot 2: High-Engagement / Low-Revenue Conversion Path

Purpose: convert high-potential fans without over-monetizing too early.

Primary business owner: Product Growth / Lifecycle

Required technical capabilities:

- Growth potential
- Engagement durability
- Revenue status
- Product fit
- Contact eligibility
- Treatment assignment
- Conversion and post-conversion engagement tracking

Success metric:

- Incremental conversion and durable engagement after conversion

### Pilot 3: High-Value Product Friction Recovery

Purpose: identify and fix value leakage caused by product or support friction.

Primary business owner: Product / DTC

Required technical capabilities:

- FEV tier
- Product usage
- Friction indicators
- Drop-off event
- Recovery eligibility
- Product outcome tracking

Success metric:

- Recovered activation, reduced abandonment, and retained value

## 18. Technical Playbook Takeaway

The technical engine should not be judged by how sophisticated it looks. It should be judged by whether it makes the strategic playbook executable.

The engine must reliably answer:

- Who or what crossed a value condition?
- What action is eligible?
- Who owns the action?
- Can the action be activated safely?
- Was the action measured?
- Did it create incremental value?

If the engine cannot answer those questions, it is not yet a decision platform.

## Operating Standard

No signal without an owner. No owner without an action. No action without measurement. No technical build without a decision use case.
