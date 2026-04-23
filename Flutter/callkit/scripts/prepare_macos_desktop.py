#!/usr/bin/env python3

import hashlib
import os
import re
import shutil
import subprocess
import sys
import urllib.parse
import urllib.request
from pathlib import Path

BRIDGE_DYLIB_NAME = "libne_callkit.dylib"
LEGACY_BRIDGE_DYLIB_NAME = "libne_call_bridge.dylib"


def read_env(name):
  value = os.environ.get(name, "").strip()
  return value or None


def read_mode(name, default="auto", extra_modes=None):
  value = (read_env(name) or default).strip().lower()
  allowed_modes = {"auto", "download", "source"}
  if extra_modes:
    allowed_modes.update(extra_modes)
  if value not in allowed_modes:
    expected = ", ".join(sorted(allowed_modes))
    raise SystemExit(
        f"Invalid value for {name}: {value}. Expected one of {expected}."
    )
  return value


def run(cmd, cwd=None):
  subprocess.run(cmd, cwd=cwd, check=True)


def require_path(path, description):
  if not path.exists():
    raise SystemExit(f"Missing {description}: {path}")
  return path


def read_macos_dylib_dependencies(path):
  path = require_path(path, "macOS dylib")
  try:
    output = subprocess.check_output(
        ["otool", "-L", str(path)],
        text=True,
        stderr=subprocess.STDOUT,
    )
  except subprocess.CalledProcessError as error:
    raise SystemExit(
        f"Failed to inspect dylib dependencies for {path}: {error.output}"
    ) from error

  dependencies = []
  for line in output.splitlines()[1:]:
    line = line.strip()
    if not line:
      continue
    dependencies.append(line.split(" ", 1)[0])
  return dependencies


def bridge_has_required_nim_dependency(path):
  dependencies = read_macos_dylib_dependencies(path)
  return any(dep.endswith("/libnim.dylib") or dep == "libnim.dylib"
             for dep in dependencies)


def validate_bridge_dylib(path):
  path = require_path(path, "macOS bridge dylib")
  if not bridge_has_required_nim_dependency(path):
    raise SystemExit(
        "Invalid macOS bridge dylib: missing libnim.dylib dependency. "
        f"Refusing to use stale artifact: {path}"
    )
  return path


def copy_tree(src, dst):
  if dst.exists():
    shutil.rmtree(dst)
  shutil.copytree(src, dst, symlinks=True)


def find_bridge_dylib(build_dir):
  candidates = sorted(build_dir.rglob(BRIDGE_DYLIB_NAME))
  if not candidates:
    candidates = sorted(build_dir.rglob(LEGACY_BRIDGE_DYLIB_NAME))
  if not candidates:
    raise SystemExit(
        f"Unable to find {BRIDGE_DYLIB_NAME} under {build_dir}")
  return candidates[0]


def parse_manifest(manifest_path):
  content = require_path(manifest_path, "artifact manifest").read_text(
      encoding="utf-8")
  pattern = re.compile(r'set\(\s*([A-Za-z0-9_]+)\s+"([^"]*)"\s*\)')
  values = {}
  for key, value in pattern.findall(content):
    values[key] = value
  return values


def default_cache_root():
  override = read_env("NE_CALL_DESKTOP_ARTIFACT_CACHE_DIR")
  if override:
    return Path(override).expanduser().resolve()
  return Path.home() / "Library" / "Caches" / "netease_callkit" / "native_artifacts"


def sha256sum(path):
  digest = hashlib.sha256()
  with path.open("rb") as stream:
    for chunk in iter(lambda: stream.read(1024 * 1024), b""):
      digest.update(chunk)
  return digest.hexdigest()


def verify_sha256(path, expected_sha256):
  if not expected_sha256:
    return
  actual = sha256sum(path)
  if actual.lower() != expected_sha256.lower():
    raise SystemExit(
        f"SHA256 mismatch for {path.name}: expected {expected_sha256}, got {actual}"
    )


def download_file(url, destination):
  parsed = urllib.parse.urlparse(url)
  if parsed.scheme in ("", "file"):
    source_path = Path(urllib.request.url2pathname(parsed.path)).resolve()
    require_path(source_path, f"artifact archive from {url}")
    shutil.copy2(source_path, destination)
    return

  destination.parent.mkdir(parents=True, exist_ok=True)
  with urllib.request.urlopen(url) as response, destination.open("wb") as output:
    shutil.copyfileobj(response, output)


def ensure_archive_dir(cache_root):
  archives_dir = cache_root / "downloads"
  archives_dir.mkdir(parents=True, exist_ok=True)
  return archives_dir


def stamp_text(url, sha256):
  return f"url={url}\nsha256={sha256}\n"


def resolve_extracted_dir(root_dir, staging_dir):
  return staging_dir / root_dir if root_dir else staging_dir


def extract_archive(archive_path, destination_dir):
  suffixes = [suffix.lower() for suffix in archive_path.suffixes]
  if suffixes and suffixes[-1] == ".zip":
    run(["ditto", "-x", "-k", str(archive_path), str(destination_dir)])
    return
  shutil.unpack_archive(str(archive_path), str(destination_dir))


def ensure_downloaded_artifacts(package_root):
  local_dir = read_env("NE_CALL_DESKTOP_MACOS_ARTIFACT_DIR")
  if local_dir:
    return require_path(Path(local_dir).expanduser().resolve(),
                        "local macOS artifact directory")

  manifest = parse_manifest(
      package_root / "native_artifacts" / "manifest.cmake")
  archive_name = manifest.get("NE_CALL_ARTIFACT_MACOS_ARCHIVE", "").strip()
  root_dir = manifest.get("NE_CALL_ARTIFACT_MACOS_ROOT_DIR", "").strip()
  archive_sha256 = read_env("NE_CALL_DESKTOP_MACOS_SHA256") or manifest.get(
      "NE_CALL_ARTIFACT_MACOS_SHA256", "").strip()
  explicit_url = read_env("NE_CALL_DESKTOP_MACOS_ARTIFACT_URL")
  base_url = read_env("NE_CALL_DESKTOP_ARTIFACT_BASE_URL") or manifest.get(
      "NE_CALL_ARTIFACT_BASE_URL", "").strip()
  archive_url = explicit_url or (
      f"{base_url.rstrip('/')}/{archive_name}" if base_url and archive_name else "")

  if archive_url:
    cache_root = default_cache_root()
    version = manifest.get("NE_CALL_ARTIFACT_VERSION", "unknown").strip() or "unknown"
    staging_dir = cache_root / version / "macos"
    stamp_path = staging_dir / ".artifact_stamp"
    extracted_dir = resolve_extracted_dir(root_dir, staging_dir)
    if extracted_dir.exists() and stamp_path.exists():
      if stamp_path.read_text(encoding="utf-8") == stamp_text(
          archive_url, archive_sha256):
        return extracted_dir

    archive_dir = ensure_archive_dir(cache_root)
    archive_path = archive_dir / archive_name
    archive_stamp_path = archive_dir / f"{archive_name}.stamp"
    expected_stamp = stamp_text(archive_url, archive_sha256)
    if (not archive_path.exists() or not archive_stamp_path.exists() or
        archive_stamp_path.read_text(encoding="utf-8") != expected_stamp):
      download_file(archive_url, archive_path)
      archive_stamp_path.write_text(expected_stamp, encoding="utf-8")
    verify_sha256(archive_path, archive_sha256)

    if staging_dir.exists():
      shutil.rmtree(staging_dir)
    staging_dir.mkdir(parents=True, exist_ok=True)
    extract_archive(archive_path, staging_dir)
    extracted_dir = resolve_extracted_dir(root_dir, staging_dir)
    require_path(extracted_dir, "extracted macOS artifact directory")
    stamp_path.write_text(
        expected_stamp,
        encoding="utf-8",
    )
    return extracted_dir

  return None


def find_required_path(root, relative_candidates, description):
  for candidate in relative_candidates:
    path = root / candidate
    if path.exists():
      return path
  raise SystemExit(f"Missing {description} under {root}")


def read_manifest(package_root):
  return parse_manifest(package_root / "native_artifacts" / "manifest.cmake")


def read_pubspec_dependency_version(package_root, dependency_name):
  pubspec_path = require_path(package_root / "pubspec.yaml", "pubspec.yaml")
  content = pubspec_path.read_text(encoding="utf-8")
  pattern = re.compile(
      rf"^\s*{re.escape(dependency_name)}\s*:\s*['\"]?([^'\"\s#]+)",
      re.MULTILINE,
  )
  match = pattern.search(content)
  if match:
    return match.group(1).strip()
  return None


def iter_existing_dirs(base_dir, patterns):
  if not base_dir.exists():
    return
  for pattern in patterns:
    for path in sorted(base_dir.glob(pattern)):
      if path.is_dir():
        yield path.resolve()


def resolve_nim_core_v2_macos_root(package_root):
  override = read_env("NE_CALL_NIM_CORE_V2_MACOS_ROOT")
  if override:
    root = Path(override).expanduser().resolve()
    require_path(root / "macos" / "nim_sdk" / "wrapper" / "CMakeLists.txt",
                 "nim_core_v2_macos wrapper CMakeLists.txt")
    return root

  dependency_version = read_pubspec_dependency_version(package_root, "nim_core_v2")
  plugin_version = None
  if dependency_version:
    plugin_version = dependency_version.split("+", 1)[0].strip()

  candidate_patterns = []
  if plugin_version:
    candidate_patterns.extend([
        f"nim_core_v2_macos-{plugin_version}",
        f"nim_core_v2_macos-{plugin_version}*",
    ])
  candidate_patterns.extend([
      "nim_core_v2_macos",
      "nim_core_v2_macos-*",
  ])

  search_roots = [package_root.parent]
  hosted_root = Path.home() / ".pub-cache" / "hosted"
  if hosted_root.exists():
    search_roots.extend(sorted(path for path in hosted_root.iterdir() if path.is_dir()))

  seen = set()
  for search_root in search_roots:
    for candidate in iter_existing_dirs(search_root, candidate_patterns):
      candidate_key = str(candidate)
      if candidate_key in seen:
        continue
      seen.add(candidate_key)
      wrapper_cmake = candidate / "macos" / "nim_sdk" / "wrapper" / "CMakeLists.txt"
      if wrapper_cmake.exists():
        return candidate

  version_hint = f" (expected {plugin_version})" if plugin_version else ""
  raise SystemExit(
      "Unable to locate nim_core_v2_macos package root"
      f"{version_hint}. Set NE_CALL_NIM_CORE_V2_MACOS_ROOT if needed."
  )


def read_library_architectures(path):
  path = require_path(path, "static library")
  try:
    output = subprocess.check_output(
        ["lipo", "-archs", str(path)],
        text=True,
        stderr=subprocess.STDOUT,
    )
  except subprocess.CalledProcessError as error:
    raise SystemExit(
        f"Failed to inspect static library architectures for {path}: "
        f"{error.output}"
    ) from error
  return {arch for arch in output.strip().split() if arch}


def libraries_have_required_architectures(libraries, required_architectures):
  required = set(required_architectures)
  for path in libraries.values():
    if not required.issubset(read_library_architectures(path)):
      return False
  return True


def build_nim_core_v2_wrapper_libraries(wrapper_root, build_root):
  sdk_path = subprocess.check_output(
      ["xcrun", "--sdk", "macosx", "--show-sdk-path"],
      text=True,
  ).strip()
  if not sdk_path:
    raise SystemExit("Failed to resolve macOS SDK path via xcrun")

  if build_root.exists():
    shutil.rmtree(build_root)
  build_root.mkdir(parents=True, exist_ok=True)

  cmake_args = [
      "cmake",
      "-S",
      str(wrapper_root),
      "-B",
      str(build_root),
      "-G",
      "Ninja",
      "-DINSTALL_CPP_WRAPPER=OFF",
      "-DBUILD_SHARED_LIBS=OFF",
      "-DCMAKE_CXX_STANDARD=14",
      "-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15",
      "-DCMAKE_OSX_ARCHITECTURES=x86_64;arm64",
      "-DCMAKE_C_COMPILER=clang",
      "-DCMAKE_CXX_COMPILER=clang++",
      f"-DCMAKE_OSX_SYSROOT={sdk_path}",
  ]
  build_env = os.environ.copy()
  build_env.update({
      "CC": "clang",
      "CXX": "clang++",
  })
  subprocess.run(cmake_args, check=True, env=build_env)
  subprocess.run([
      "cmake",
      "--build",
      str(build_root),
      "--config",
      "Release",
      "--target",
      "nim_cpp_wrapper",
      "nim_wrapper_util",
      "-j",
      "4",
  ], check=True, env=build_env)

  return {
      "libnim_cpp_wrapper.a": require_path(
          find_required_path(
              build_root,
              [
                  Path("nim_cpp_wrapper/libnim_cpp_wrapper.a"),
                  Path("nim_cpp_wrapper/Release/libnim_cpp_wrapper.a"),
              ],
              "built libnim_cpp_wrapper.a",
          ),
          "built libnim_cpp_wrapper.a",
      ),
      "libnim_wrapper_util.a": require_path(
          find_required_path(
              build_root,
              [
                  Path("nim_wrapper_util/libnim_wrapper_util.a"),
                  Path("nim_wrapper_util/Release/libnim_wrapper_util.a"),
              ],
              "built libnim_wrapper_util.a",
          ),
          "built libnim_wrapper_util.a",
      ),
  }


def ensure_nim_core_v2_wrapper_libraries(package_root):
  nim_root = resolve_nim_core_v2_macos_root(package_root)
  macos_lib_root = require_path(
      nim_root / "macos" / "nim_sdk" / "lib",
      "nim_core_v2_macos macOS nim_sdk lib directory",
  )
  root_lib_root = require_path(
      nim_root / "nim_sdk" / "lib",
      "nim_core_v2_macos nim_sdk lib directory",
  )

  artifact_names = ("libnim_cpp_wrapper.a", "libnim_wrapper_util.a")
  required_architectures = ("x86_64", "arm64")
  macos_artifacts = {name: macos_lib_root / name for name in artifact_names}
  if (all(path.exists() for path in macos_artifacts.values()) and
      libraries_have_required_architectures(macos_artifacts,
                                            required_architectures)):
    return macos_artifacts

  root_artifacts = {name: root_lib_root / name for name in artifact_names}
  if (all(path.exists() for path in root_artifacts.values()) and
      libraries_have_required_architectures(root_artifacts,
                                            required_architectures)):
    for name, source in root_artifacts.items():
      shutil.copy2(source, macos_artifacts[name])
    return macos_artifacts

  wrapper_root = require_path(
      nim_root / "macos" / "nim_sdk" / "wrapper",
      "nim_core_v2_macos macOS nim_sdk wrapper directory",
  )
  dependency_version = read_pubspec_dependency_version(package_root, "nim_core_v2")
  build_version = dependency_version.split("+", 1)[0].strip() if dependency_version else "unknown"
  build_root = (
      default_cache_root() / "support" / "nim_core_v2_wrapper" / build_version / "macos"
  )
  built_artifacts = build_nim_core_v2_wrapper_libraries(wrapper_root, build_root)

  for name, source in built_artifacts.items():
    shutil.copy2(source, root_lib_root / name)
    shutil.copy2(source, macos_artifacts[name])

  return macos_artifacts


def resolve_nim_core_v2_macos_nim_sdk_root(package_root):
  nim_root = resolve_nim_core_v2_macos_root(package_root)
  candidates = [
      nim_root / "macos" / "nim_sdk",
      nim_root / "nim_sdk",
  ]
  for candidate in candidates:
    include_dir = candidate / "include"
    lib_dir = candidate / "lib"
    if include_dir.exists() and lib_dir.exists():
      return candidate
  raise SystemExit(
      f"Unable to locate nim_core_v2_macos nim_sdk directory under {nim_root}"
  )


def resolve_upstream_framework_urls(manifest):
  rtc_url = read_env("NE_CALL_UPSTREAM_NERTC_MACOS_SDK_URL") or manifest.get(
      "NE_CALL_UPSTREAM_NERTC_MACOS_SDK_URL", "").strip()
  observability_url = read_env(
      "NE_CALL_UPSTREAM_OBSERVABILITY_MACOS_SDK_URL") or manifest.get(
          "NE_CALL_UPSTREAM_OBSERVABILITY_MACOS_SDK_URL", "").strip()
  return rtc_url, observability_url


def ensure_downloaded_upstream_frameworks(package_root):
  manifest = read_manifest(package_root)
  version = manifest.get("NE_CALL_ARTIFACT_VERSION", "unknown").strip() or "unknown"
  rtc_url, observability_url = resolve_upstream_framework_urls(manifest)
  if not rtc_url or not observability_url:
    return None

  cache_root = default_cache_root()
  upstream_root = cache_root / "upstream_sdk" / version / "macos"
  downloads_root = upstream_root / "downloads"
  extracts_root = upstream_root / "extracts"
  downloads_root.mkdir(parents=True, exist_ok=True)

  def ensure_archive(url, archive_name):
    archive_path = downloads_root / archive_name
    stamp_path = downloads_root / f"{archive_name}.stamp"
    expected_stamp = stamp_text(url, "")
    if (not archive_path.exists() or not stamp_path.exists() or
        stamp_path.read_text(encoding="utf-8") != expected_stamp):
      download_file(url, archive_path)
      stamp_path.write_text(expected_stamp, encoding="utf-8")
    return archive_path, expected_stamp

  def ensure_extract(archive_path, expected_stamp, extract_dir):
    stamp_path = extract_dir / ".artifact_stamp"
    if (not extract_dir.exists() or not stamp_path.exists() or
        stamp_path.read_text(encoding="utf-8") != expected_stamp):
      if extract_dir.exists():
        shutil.rmtree(extract_dir)
      extract_dir.mkdir(parents=True, exist_ok=True)
      extract_archive(archive_path, extract_dir)
      stamp_path.write_text(expected_stamp, encoding="utf-8")
    return extract_dir

  rtc_archive, rtc_stamp = ensure_archive(rtc_url, "nertc_macos_sdk.zip")
  observability_archive, observability_stamp = ensure_archive(
      observability_url, "observability_macos_sdk.zip")

  rtc_extract_root = ensure_extract(rtc_archive, rtc_stamp, extracts_root / "rtc")
  observability_extract_root = ensure_extract(
      observability_archive, observability_stamp, extracts_root / "observability")

  return {
      "nertc_xcframework": find_required_path(
          rtc_extract_root,
          [
              Path("sdk/nertc_sdk_Mac.xcframework"),
              Path("nertc_sdk_Mac.xcframework"),
          ],
          "nertc_sdk_Mac.xcframework",
      ),
      "observability_xcframework": find_required_path(
          observability_extract_root,
          [
              Path("NEXKitBase.xcframework"),
              Path("sdk/NEXKitBase.xcframework"),
          ],
          "NEXKitBase.xcframework",
      ),
  }


def resolve_source_desktop_assets(package_root):
  desktop_root = resolve_desktop_root(package_root)
  if desktop_root is None:
    raise SystemExit(
        "No local desktop source configured. Set NE_CALL_DESKTOP_SOURCE_DIR "
        "or keep the monorepo desktop/ directory available."
    )

  require_path(desktop_root / "CMakeLists.txt", "desktop CMakeLists.txt")
  nertc_xcframework = require_path(
      desktop_root / "third_party" / "nertc" / "lib" / "macos" /
      "nertc_sdk_Mac.xcframework",
      "NERtc macOS xcframework",
  )
  observability_xcframework = require_path(
      desktop_root / "third_party" / "observability" / "lib" / "macos" /
      "NEXKitBase.xcframework",
      "observability macOS xcframework",
  )
  return {
      "desktop_root": desktop_root,
      "nertc_xcframework": nertc_xcframework,
      "observability_xcframework": observability_xcframework,
  }


def resolve_desktop_root(package_root):
  override = read_env("NE_CALL_DESKTOP_SOURCE_DIR")
  if override:
    root = Path(override).expanduser().resolve()
    require_path(root, "desktop source root")
    return root

  default_root = (package_root / ".." / ".." / "desktop").resolve()
  if default_root.exists():
    return default_root
  return None


def build_bridge_from_source(package_root):
  macos_root = package_root / "macos"
  build_root = macos_root / ".desktop_build"
  desktop_assets = resolve_source_desktop_assets(package_root)
  desktop_root = desktop_assets["desktop_root"]
  nim_sdk_root = resolve_nim_core_v2_macos_nim_sdk_root(package_root)

  sdk_path = subprocess.check_output(
      ["xcrun", "--sdk", "macosx", "--show-sdk-path"],
      text=True,
  ).strip()
  if not sdk_path:
    raise SystemExit("Failed to resolve macOS SDK path via xcrun")

  if build_root.exists():
    shutil.rmtree(build_root)
  build_root.mkdir(parents=True, exist_ok=True)

  cmake_args = [
      "cmake",
      "-S",
      str(desktop_root),
      "-B",
      str(build_root),
      "-DNE_CALL_BUILD_SHARED_BRIDGE=ON",
      "-DCMAKE_BUILD_TYPE=Release",
      "-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15",
      "-DCMAKE_OSX_ARCHITECTURES=x86_64;arm64",
      f"-DNE_CALL_MACOS_NIM_ROOT={nim_sdk_root}",
      f"-DCMAKE_OSX_SYSROOT={sdk_path}",
  ]
  run(cmake_args)
  run(["cmake", "--build", str(build_root), "--target", "ne_call_bridge", "-j", "4"])

  bridge_dylib = require_path(find_bridge_dylib(build_root), "built bridge dylib")
  return bridge_dylib


def resolve_packaged_bridge_dylib(package_root):
  frameworks_root = package_root / "macos" / "Frameworks"
  for candidate_name in (BRIDGE_DYLIB_NAME, LEGACY_BRIDGE_DYLIB_NAME):
    candidate = frameworks_root / candidate_name
    if candidate.exists():
      staged_dir = package_root / "macos" / ".prepared_bridge"
      if staged_dir.exists():
        shutil.rmtree(staged_dir)
      staged_dir.mkdir(parents=True, exist_ok=True)
      staged_bridge = staged_dir / candidate.name
      shutil.copy2(candidate, staged_bridge)
      return validate_bridge_dylib(staged_bridge)
  return None


def prepare_frameworks_dir(frameworks_root):
  if frameworks_root.exists():
    shutil.rmtree(frameworks_root)
  frameworks_root.mkdir(parents=True, exist_ok=True)


def resolve_bridge_artifact(package_root, downloaded_dir, bridge_mode):
  if bridge_mode == "download":
    if downloaded_dir is None:
      raise SystemExit(
          "macOS bridge mode is download, but no downloadable artifact is configured. "
          "Set NE_CALL_DESKTOP_MACOS_ARTIFACT_DIR, "
          "NE_CALL_DESKTOP_MACOS_ARTIFACT_URL, or NE_CALL_DESKTOP_ARTIFACT_BASE_URL."
      )
    bridge_path = downloaded_dir / BRIDGE_DYLIB_NAME
    if not bridge_path.exists():
      bridge_path = downloaded_dir / LEGACY_BRIDGE_DYLIB_NAME
    return validate_bridge_dylib(bridge_path)

  if bridge_mode == "source":
    return validate_bridge_dylib(build_bridge_from_source(package_root))

  if bridge_mode == "packaged":
    packaged_bridge = resolve_packaged_bridge_dylib(package_root)
    if packaged_bridge is None:
      raise SystemExit(
          "macOS bridge mode is packaged, but no packaged bridge dylib is available "
          f"under {package_root / 'macos' / 'Frameworks'}."
      )
    return packaged_bridge

  if downloaded_dir is not None:
    bridge_from_download = downloaded_dir / BRIDGE_DYLIB_NAME
    if not bridge_from_download.exists():
      bridge_from_download = downloaded_dir / LEGACY_BRIDGE_DYLIB_NAME
    if bridge_from_download.exists():
      try:
        return validate_bridge_dylib(bridge_from_download)
      except SystemExit as error:
        print(
            "[netease_callkit] ignoring stale downloaded macOS bridge dylib: "
            f"{error}",
            file=sys.stderr,
        )
  desktop_root = resolve_desktop_root(package_root)
  if desktop_root is not None:
    return validate_bridge_dylib(build_bridge_from_source(package_root))

  packaged_bridge = resolve_packaged_bridge_dylib(package_root)
  if packaged_bridge is not None:
    return packaged_bridge

  return validate_bridge_dylib(build_bridge_from_source(package_root))


def resolve_framework_artifacts(package_root, downloaded_dir, framework_mode):
  if framework_mode == "download":
    if downloaded_dir is not None:
      return {
          "nertc_xcframework": require_path(
              downloaded_dir / "nertc_sdk_Mac.xcframework",
              "downloaded NERtc macOS xcframework",
          ),
          "observability_xcframework": require_path(
              downloaded_dir / "NEXKitBase.xcframework",
              "downloaded observability macOS xcframework",
          ),
      }

    upstream_frameworks = ensure_downloaded_upstream_frameworks(package_root)
    if upstream_frameworks is not None:
      return upstream_frameworks

    raise SystemExit(
        "macOS framework mode is download, but no downloadable framework source is configured. "
        "Set one of: "
        "NE_CALL_DESKTOP_MACOS_ARTIFACT_DIR, "
        "NE_CALL_DESKTOP_MACOS_ARTIFACT_URL, "
        "NE_CALL_DESKTOP_ARTIFACT_BASE_URL, "
        "NE_CALL_UPSTREAM_NERTC_MACOS_SDK_URL, "
        "NE_CALL_UPSTREAM_OBSERVABILITY_MACOS_SDK_URL."
    )

  if framework_mode == "source":
    desktop_assets = resolve_source_desktop_assets(package_root)
    return {
        "nertc_xcframework": desktop_assets["nertc_xcframework"],
        "observability_xcframework": desktop_assets["observability_xcframework"],
    }

  if downloaded_dir is not None:
    nertc_xcframework = downloaded_dir / "nertc_sdk_Mac.xcframework"
    observability_xcframework = downloaded_dir / "NEXKitBase.xcframework"
    if nertc_xcframework.exists() and observability_xcframework.exists():
      return {
          "nertc_xcframework": nertc_xcframework,
          "observability_xcframework": observability_xcframework,
      }

  desktop_assets = resolve_source_desktop_assets(package_root)
  return {
      "nertc_xcframework": desktop_assets["nertc_xcframework"],
      "observability_xcframework": desktop_assets["observability_xcframework"],
  }


def copy_resolved_artifacts(bridge_dylib, nertc_xcframework,
                            observability_xcframework, frameworks_root):
  bridge_dylib = validate_bridge_dylib(bridge_dylib)
  nertc_xcframework = require_path(
      nertc_xcframework, "NERtc macOS xcframework")
  observability_xcframework = require_path(
      observability_xcframework,
      "observability macOS xcframework",
  )

  shutil.copy2(bridge_dylib, frameworks_root / bridge_dylib.name)
  copy_tree(nertc_xcframework, frameworks_root / nertc_xcframework.name)
  copy_tree(
      observability_xcframework,
      frameworks_root / observability_xcframework.name,
  )
  (frameworks_root / ".gitkeep").write_text("", encoding="utf-8")


def main():
  script_dir = Path(__file__).resolve().parent
  package_root = script_dir.parent
  macos_root = package_root / "macos"
  frameworks_root = macos_root / "Frameworks"
  default_mode = read_mode("NE_CALL_DESKTOP_MACOS_MODE")
  bridge_mode = read_mode(
      "NE_CALL_DESKTOP_MACOS_BRIDGE_MODE", default_mode, extra_modes={"packaged"})
  framework_mode = read_mode("NE_CALL_DESKTOP_MACOS_FRAMEWORK_MODE", default_mode)

  downloaded_dir = ensure_downloaded_artifacts(package_root)
  bridge_dylib = resolve_bridge_artifact(package_root, downloaded_dir, bridge_mode)
  framework_artifacts = resolve_framework_artifacts(
      package_root, downloaded_dir, framework_mode)
  ensure_nim_core_v2_wrapper_libraries(package_root)
  prepare_frameworks_dir(frameworks_root)
  copy_resolved_artifacts(
      bridge_dylib,
      framework_artifacts["nertc_xcframework"],
      framework_artifacts["observability_xcframework"],
      frameworks_root,
  )


if __name__ == "__main__":
  try:
    main()
  except subprocess.CalledProcessError as error:
    sys.exit(error.returncode)
