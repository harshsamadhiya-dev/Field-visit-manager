# Field Visit Manager

A Flutter mobile app for UTS/ATVM maintenance engineers to manage station field
visits — inspecting devices, repairing faults, installing equipment, and
performing preventive maintenance — with all data stored on Firebase.

## What it does

An engineer logs in, is assigned (or schedules) a station visit, and works
through a purpose-built flow depending on why they're visiting:

### Visit Type : What the engineer fills in

- **Inspection** : 10 point device health checklist, with remarks on any failed item
- **Repair** : Fault description, severity, parts used, repair notes, resolved status 
- **Install** : Equipment name/model, serial/asset number, installation notes
- **Preventive Maintenance** : 10 point routine maintenance task checklist


Every visit ends with a **report & sign-off** — a summary of everything
logged, plus the engineer's remarks and name — after which the visit is
marked **Completed** and moves to history.

## Tech Stack

- **Flutter** (Dart) — UI framework
- **Firebase Authentication** — engineer and manager login (email/password)
- **Cloud Firestore** — real-time database, stores engineers & visits
- **Provider** — app-wide session state

## Project Structure

```text
lib/
├── models/       # Visit, user, checklist, enums
├── screens/      # Login, dashboards, visit workflows
├── services/     # Firebase auth, Firestore, app state
└── widgets/      # Reusable UI components
```