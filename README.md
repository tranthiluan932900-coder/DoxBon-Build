# DoxBon Build Starter

## Files
- `DoxBon.dylib.m`: UIKit menu shell and HTTPS license-validation client.
- `.github/workflows/build.yml`: builds an arm64 iOS dynamic library with GitHub Actions.

## Required before use
1. Replace `DBLicenseEndpoint` in `DoxBon.dylib.m` with your own HTTPS validation endpoint.
2. The endpoint must accept JSON `{"key":"...","device_id":"..."}` and return JSON such as:
   `{"valid":true,"expires_at":"2026-12-31T23:59:59Z"}`
   or `{"valid":false,"message":"Key không hợp lệ"}`.
3. Keep server secrets on the server. Never embed an admin/API secret in the dylib.
4. This is a UI/licensing starter. The three feature rows are placeholders; they do not yet implement Video Star media/QR operations.
5. Integrate and test only in an app/build you are authorized to modify. The constructor-based menu launch is a starter approach and may need adjustment for the target app's lifecycle/integration method.

## Build
Push to `main`, or run **Actions → Build DoxBon iOS Library → Run workflow**.
Download the `DoxBon-iOS` artifact from the completed run.
