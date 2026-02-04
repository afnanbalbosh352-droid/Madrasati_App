

---

## What is being tested?

### 1. Unit tests (logic)

- **Empty login**: We check that the app *does not* allow login when ID or password is empty.
- **Valid login**: We check that when both ID and password are provided, login is allowed.
- **Email format**: We check that the teacher email is built correctly from the National ID (e.g. `teacher_999@madrasati.edu`).

**Why it matters:** This is the “business logic” of login. If someone breaks it later, tests will fail and we’ll know.

### 2. Widget tests (UI)

- **Splash screen:** We build the splash screen and check that the text **"Madrasati"** and **"Your School Companion"** appear.
- **Role selection:** We check that **"Madrasati"**, **"Choose how to continue"**, and the three options (School Administration, Teacher, Parent) are visible.
- **Teacher login:** We check that the screen shows **"Login as a Teacher"**, text fields, and a **"Login"** button.
- **Background widget:** We check that our reusable educational-pattern background can display a child widget.

**Why it matters:** This ensures that after UI changes, the most important labels and buttons are still present and the app doesn’t show a blank or wrong screen.

---

## How to explain this in a defense

1. **“We added automated tests”**  
   We don’t rely only on manual testing; we have code that checks the app automatically.

2. **“We test both logic and UI”**  
   - **Unit tests** check rules (e.g. “no login with empty password”).  
   - **Widget tests** check that the right text and widgets appear on key screens.

3. **“Tests are easy to run”**  
   One command: `flutter test`. If something breaks, the tests fail and we fix it before release.

4. **“We focused on critical flows”**  
   Splash, role selection, and login are the first things users see; we made sure those are covered.

---

## File overview

| File | Purpose |
|------|--------|
| `madrasati_defense_tests.dart` | Main test suite with unit + widget tests and comments for defense. |
| `widget_test.dart` | Minimal smoke test: app starts and splash shows “Madrasati”. |
| `aut_unit_test.dart` | Extra unit tests for login validation. |

**Use-case tests:** `use_case_tests.dart` — tests grouped by use case (UC1–UC7). Run: `flutter test test/use_case_tests.dart`  
**How to run (step-by-step):** `HOW_TO_RUN_TESTS.md`
