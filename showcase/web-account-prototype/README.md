# Meo Account Web Prototype

This directory is a **design prototype**, not a production authentication client.

The goal is to design and critique the Meo Account login and account-management experience in plain HTML/CSS/JavaScript first, then port accepted interaction patterns back to the real application without tying visual iteration to Flutter widgets or backend behavior.

## What it demonstrates

- Two-step email → password sign-in flow
- Google/GitHub visual entry points
- Expanded navigation, compact navigation rail, and mobile bottom navigation
- Account overview with profile identity, security state, recent devices, and quick actions
- Placeholder shells for Profile, Security, Devices, Apps & data, and Settings
- Light/dark appearance
- Reduced-motion support
- No framework or external runtime dependencies

## Relationship to MeoUI

The CSS variables intentionally mirror the semantic roles and interaction timing in `MeoTheme.qml`:

- primary / on-primary
- primary-container / on-primary-container
- surface container levels
- outline / outline-variant
- 120 ms fast interaction feedback
- 220 ms normal state transitions
- 320 ms spatial/page transitions
- adaptive behavior around the MeoUI compact/medium/expanded width model

The prototype should be treated as a visual reference. Production QML/Flutter code should continue to use its native MeoUI/theme tokens rather than copying hard-coded CSS values.

## Running

Open `index.html` directly in a browser, or serve this directory with any static HTTP server.

The mock sign-in accepts any displayed values. OAuth buttons also enter the account mock immediately. Nothing is sent to Supabase or any external service.

## Product rule

Security behavior is not simulated as authorization. Real MFA, reauthentication, session revocation, account deletion, OAuth state, and admin actions must remain enforced by the account backend/Edge Functions. The HTML prototype only defines the desired user experience around those controls.
