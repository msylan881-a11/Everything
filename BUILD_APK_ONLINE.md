# NAQSH AI — build APK using GitHub Actions

## Important
This workflow builds a **debug/test APK of the current app source**. It does not make the app production-complete: the current backend does not perform real AI image edits until an AI provider is configured, and authentication, billing, ads, and production security are not implemented.

## Steps (using a phone browser)
1. Download and extract this ZIP on your phone. You need to upload the *contents* of the extracted folder, not upload this ZIP as a single file.
2. Sign in to GitHub and create a new repository named `naqsh-ai`. For easiest setup, choose **Public** only if you are comfortable with the source being public; otherwise choose **Private**. Do not add a README/license at creation.
3. In the repository, choose **Add file → Upload files** and upload the extracted project files/folders, including the hidden `.github/workflows/build-android-apk.yml` file. If your phone's file picker cannot upload folders or hidden files, this method may require a computer or a Git client app.
4. Commit the uploaded files to the `main` branch.
5. Open **Actions** → **Build NAQSH AI Android APK** → **Run workflow**.
6. When the run finishes successfully, open it and download the artifact named `naqsh-ai-debug-apk`. Extract that downloaded ZIP to get `app-debug.apk`.
7. Open `app-debug.apk` on your Android phone and allow installation from that source if Android asks.

Official guides:
- Create a repository: https://docs.github.com/en/repositories/creating-and-managing-repositories/quickstart-for-repositories
- Upload files: https://docs.github.com/en/repositories/working-with-files/managing-files/adding-a-file-to-a-repository
- Run workflow: https://docs.github.com/en/actions/how-tos/manage-workflow-runs/manually-run-a-workflow
