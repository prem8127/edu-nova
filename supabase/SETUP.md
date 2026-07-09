# Supabase setup for Harithya Global Education

Everything below is done once, in the Supabase dashboard for your project
(`ymvyyendeblxkixlgnfz`). The app code is already wired to it.

## 1. Run the database schema

Dashboard -> **SQL Editor** -> New query -> paste the contents of
`supabase/schema.sql` -> Run.

This creates the `profiles` table (name, role, grade, etc.) and a trigger
that auto-fills it whenever a new account is created — including a
student's class, which is why they're only ever asked once.

## 2. Switch signup confirmation to a 6-digit OTP (not a magic link)

By default Supabase emails a "Confirm your signup" link. You want a code
instead, since that's what the app's verification screen expects.

Dashboard -> **Authentication -> Emails -> Confirm signup** template ->
replace the body so it uses `{{ .Token }}` instead of
`{{ .ConfirmationURL }}`, e.g.:

```
<h2>Confirm your signup</h2>
<p>Your verification code is:</p>
<h1>{{ .Token }}</h1>
<p>This code expires shortly — enter it in the app to activate your account.</p>
```

Save. Also confirm **Authentication -> Sign In / Providers -> Email** has
"Confirm email" turned ON (it is by default) — that's what makes the
account stay inactive until the code is verified.

## 3. Send that email through your Gmail account (custom SMTP)

Dashboard -> **Project Settings -> Authentication -> SMTP Settings** ->
Enable Custom SMTP, then:

| Field | Value |
|---|---|
| Sender email | your Gmail address |
| Sender name | Harithya Global Education |
| Host | `smtp.gmail.com` |
| Port | `587` |
| Username | your Gmail address |
| Password | a Gmail **App Password** (see below) |

Gmail won't accept your normal password here. Turn on 2-Step Verification
on the Gmail account (myaccount.google.com/security), then generate an
**App Password** at myaccount.google.com/apppasswords and paste that
16-character code in.

Save, then use the "Send test email" button to confirm it works before
testing in the app.

## 4. Add teacher and admin accounts (no self sign-up)

Dashboard -> **Authentication -> Users -> Add user -> Create new user**.

- Email + password: whatever you're giving that teacher/admin.
- Auto Confirm User: turn this ON (they don't need the OTP flow — that's
  student-only).
- User Metadata (JSON) — this is what makes them show up correctly in the
  app:
  ```json
  { "name": "Teacher's full name", "role": "teacher" }
  ```
  or `"role": "admin"` for an admin account.

The same database trigger that fills in student profiles fills this in
too, so no extra step is needed. They can now sign in from the app's
"Staff / Admin sign in" link — there's no sign-up screen for these roles.

## 5. What the app now does

- **Student sign-up**: creates the account, emails a 6-digit code (via
  your Gmail SMTP), the student enters it in-app to activate — then
  they're logged in. Their class/grade was captured once on the sign-up
  form and is stored in `profiles.grade` forever; it's never asked again
  on later logins.
- **Student/teacher/admin login**: real Supabase Auth, session persists
  across app restarts.
- **Teacher/admin**: no sign-up screen in the app at all — accounts only
  come from step 4 above.
