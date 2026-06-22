#!/usr/bin/env python3

import os
import shutil
from pathlib import Path

import prepare_macos_desktop as desktop_prepare


def read_env(name):
  value = os.environ.get(name, "").strip()
  return value or None


def resolve_upstream_urls(manifest):
  rtc_url = read_env("NE_CALL_UPSTREAM_NERTC_MACOS_SDK_URL") or manifest.get(
      "NE_CALL_UPSTREAM_NERTC_MACOS_SDK_URL", "").strip()
  observability_url = read_env(
      "NE_CALL_UPSTREAM_OBSERVABILITY_MACOS_SDK_URL") or manifest.get(
          "NE_CALL_UPSTREAM_OBSERVABILITY_MACOS_SDK_URL", "").strip()
  if not rtc_url:
    raise SystemExit(
        "Missing upstream RTC macOS SDK URL. "
        "Set NE_CALL_UPSTREAM_NERTC_MACOS_SDK_URL or fill manifest.cmake.")
  if not observability_url:
    raise SystemExit(
        "Missing upstream observability macOS SDK URL. "
        "Set NE_CALL_UPSTREAM_OBSERVABILITY_MACOS_SDK_URL or fill manifest.cmake.")
  return rtc_url, observability_url


def ensure_download(url, destination):
  destination.parent.mkdir(parents=True, exist_ok=True)
  if destination.exists():
    return destination
  desktop_prepare.download_file(url, destination)
  return destination


def extract_to_dir(archive_path, destination):
  if destination.exists():
    shutil.rmtree(destination)
  destination.mkdir(parents=True, exist_ok=True)
  desktop_prepare.extract_archive(archive_path, destination)
  return destination


def find_required_path(root, relative_candidates, description):
  for candidate in relative_candidates:
    path = root / candidate
    if path.exists():
      return path
  raise SystemExit(f"Missing {description} under {root}")


def main():
  script_dir = Path(__file__).resolve().parent
  package_root = script_dir.parent
  manifest = desktop_prepare.parse_manifest(
      package_root / "native_artifacts" / "manifest.cmake")
  version = manifest.get("NE_CALL_ARTIFACT_VERSION", "unknown").strip() or "unknown"
  rtc_url, observability_url = resolve_upstream_urls(manifest)

  cache_root = desktop_prepare.default_cache_root()
  upstream_root = cache_root / "upstream_sdk" / version / "macos"
  downloads_root = upstream_root / "downloads"
  extracts_root = upstream_root / "extracts"
  artifact_root = Path(
      read_env("NE_CALL_LOCAL_MACOS_ARTIFACT_DIR") or
      str(package_root / "macos" / ".local_desktop_artifact")).expanduser().resolve()
  artifact_zip = Path(
      read_env("NE_CALL_LOCAL_MACOS_ARTIFACT_ZIP") or
      str(package_root / "macos" / ".local_desktop_artifact.zip")).expanduser().resolve()

  rtc_archive = ensure_download(rtc_url, downloads_root / "nertc_macos_sdk.zip")
  observability_archive = ensure_download(
      observability_url, downloads_root / "observability_macos_sdk.zip")

  rtc_extract_root = extract_to_dir(rtc_archive, extracts_root / "rtc")
  observability_extract_root = extract_to_dir(
      observability_archive, extracts_root / "observability")

  nertc_xcframework = find_required_path(
      rtc_extract_root,
      [
          Path("sdk/nertc_sdk_Mac.xcframework"),
          Path("nertc_sdk_Mac.xcframework"),
      ],
      "nertc_sdk_Mac.xcframework",
  )
  observability_xcframework = find_required_path(
      observability_extract_root,
      [
          Path("NEXKitBase.xcframework"),
          Path("sdk/NEXKitBase.xcframework"),
      ],
      "NEXKitBase.xcframework",
  )

  bridge_dylib = desktop_prepare.build_bridge_from_source(package_root)
  desktop_prepare.validate_bridge_dylib(bridge_dylib)

  if artifact_root.exists():
    shutil.rmtree(artifact_root)
  artifact_root.mkdir(parents=True, exist_ok=True)

  packaged_bridge = artifact_root / desktop_prepare.BRIDGE_DYLIB_NAME
  shutil.copy2(bridge_dylib, packaged_bridge)
  desktop_prepare.validate_bridge_dylib(packaged_bridge)
  desktop_prepare.copy_tree(
      nertc_xcframework, artifact_root / "nertc_sdk_Mac.xcframework")
  desktop_prepare.copy_tree(
      observability_xcframework, artifact_root / "NEXKitBase.xcframework")

  if artifact_zip.exists():
    artifact_zip.unlink()
  desktop_prepare.run([
      "ditto",
      "-c",
      "-k",
      "--keepParent",
      str(artifact_root),
      str(artifact_zip),
  ])

  print(f"artifact_dir={artifact_root}")
  print(f"artifact_zip={artifact_zip}")


if __name__ == "__main__":
  main()
