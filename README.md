# ClearVisit

ClearVisit is a private, local-first mobile organizer for preparing for medical appointments, maintaining a medication list, and recording health notes and measurements.

It is not a medical device and does not provide medical advice, diagnosis, monitoring, or treatment.

## Current state

The initial Flutter vertical slice includes:

- Encrypted SQLCipher database
- Random database key stored in iOS Keychain or Android Keystore
- Appointment preparation records and summaries
- Medication list
- Flagged health log entries
- Manual measurements without interpretation
- Local deletion of all records
- Initial model tests

Not yet implemented:

- Editing and individual deletion
- PDF generation and printing
- Encrypted backup/restore
- Biometric app lock and app-switcher privacy shield
- Onboarding and consent records
- Accessibility and device integration tests
- GCP deployment
- Production app-store assets

## Installed development environment

The workspace now contains Flutter 3.44.4 under `.tools/flutter`. The Android SDK and `ClearVisit_API_36` emulator are installed under `%LOCALAPPDATA%\ClearVisitDev` to avoid OneDrive locking large emulator disk images.

To launch the emulator and run ClearVisit:

```powershell
cd C:\Users\suchi\OneDrive\Documents\Codex\clearvisit
.\scripts\run-android.ps1
```

To regenerate wrappers, fetch packages, analyze, and test:

```powershell
.\scripts\bootstrap-mobile.ps1
```

Android backup exclusion and minimum-SDK configuration have been applied. Remaining release hardening is tracked in `docs/PLATFORM_SECURITY.md`.

## Privacy boundary

The mobile app does not currently contain networking code. User-entered records remain in its encrypted local database. GCP is reserved for the public website, policies, build infrastructure, and generic configuration until a separately approved regulated-data project is activated.
