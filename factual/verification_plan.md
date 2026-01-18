# Verification Plan: User Identity & Grouping

## Objective
To verify how the app groups and identifies users, specifically determining if it relies on **Device ID (Firebase UID)** or **IP Address**.

## Hypothesis
The app uses **Firebase Anonymous Authentication**.
- **Identity**: Linked to the **Installation ID** (UID).
- **IP Address**: Used mainly for **Geolocation** (e.g., "User is in London") by Firebase Analytics, NOT for grouping user history.

## Verification Steps

### Test 1: Identify the Current User
1.  Run the app in the Emulator.
2.  Observe the logs for "User detected: <UID>".
3.  Check Firebase Console -> **Authentication** branch.
    - Confirm a new Anonymous User exists with that UID.
4.  Check Firestore -> **users** collection.
    - Confirm a document exists with that UID.

### Test 2: The "Reinstall" Test (Proving it's not IP-based)
1.  **Delete** the app from the Emulator.
2.  **Re-run** the app.
3.  Observe a **NEW** UID is generated.
4.  **Result**: 
    - Even though the Emulator has the **same IP**, the system sees a **New User**.
    - This confirms grouping is based on **Device/Installation ID**, not IP.

### Test 3: Analytics Dashboard
1.  Go to Firebase Console -> Analytics -> **Dashboard**.
2.  Look at the "User location" map.
    - This is populated by IP.
3.  Look at "User retention" or "Activity".
    - This is grouped by UID.

## Expected Outcome
- The logs will show a unique UID (e.g., `28dM8...`).
- Clearing app data will generate a *new* UID, starting a fresh history.
- **Conclusion**: We are using a secure, standard "Device ID" approach, which is better than IP (which changes if you switch Wi-Fi).

## Running the Verification
I will now run the app and capture the logs to show you the UID generation in action.
