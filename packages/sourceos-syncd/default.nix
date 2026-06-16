{ lib, python3Packages, sourceos-syncd-src }:

python3Packages.buildPythonApplication {
  pname = "sourceos-syncd";
  version = "0.1.0";
  src = sourceos-syncd-src;

  pyproject = true;
  build-system = with python3Packages; [
    setuptools
  ];

  # No third-party runtime dependencies — stdlib only.
  # jsonschema is test-only (nativeCheckInputs below).
  propagatedBuildInputs = [];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    jsonschema
  ];

  pythonImportsCheck = [
    "sourceos_syncd.cli"
    "sourceos_syncd.content_sync"
    "sourceos_syncd.katello_client"
    "sourceos_syncd.daemon"
    "sourceos_syncd.receipt_store"
  ];

  meta = {
    description = "SourceOS content-view sync daemon: polls Katello, applies NixOS updates, emits SyncCycleReceipts.";
    license = lib.licenses.mit;
    mainProgram = "sourceos-syncd";
    platforms = lib.platforms.linux;
  };
}
