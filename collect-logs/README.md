# Collect Logs Action

This action collects logs from a Docker container after a test.

## Current version

`magf/actions/collect-logs@collect-logs/v1.0.0`

## Usage

```yaml
- name: Collect logs
  uses: magf/actions/collect-logs@collect-logs/v1
```

Use optional parameters:

```yaml
- name: Collect logs
  uses: magf/actions/collect-logs@collect-logs/v1
  with:
    log_dir: /mnt/logs
    params: |
      gpAdminLogs d gpAdminLogs
      gpdb_src/gpAux/gpdemo/datadirs d pg_log
```

## Inputs

| Input | Description | Required | Default |
| --- | --- | --- | --- |
| `log_dir` | Log directory in the container | No | `/logs` |
| `log_path_prefix` | Archive name prefix | No | `github.job` |
| `docker_host` | Docker host string (for example, `ssh://qemu-vm`) | No | (empty) |
| `params` | Parameters for `find` | No | See below |

Default `params`:

```text
gpAdminLogs d gpAdminLogs
gpdb_src/src/test f *.diffs
gpdb_src/src/test d results
gpdb_src/gpAux/gpdemo/datadirs d log
gpdb_src/gpAux/gpdemo/datadirs d pg_log
```

Each line has this format: `<path> <type> <name>`.

- `path`: The base is the container `$PWD` (WORKDIR) by default.
  If the path starts with `/`, the action uses the absolute path.
- `name`: You can use `find` wildcards (for example, `*.diffs`).
  The action removes wildcard and invalid characters from the archive suffix.
  Example: `*.diffs` gives `{log_path_prefix}_diffs.tar`.

## Procedure

The action does these steps:

1. Starts the Docker container if it is stopped. Ignores errors.
2. Runs `find` in the container for each `params` entry.
3. Makes a tar archive for each `params` entry.
   The archive name is `{log_path_prefix}_{name}.tar`.
   The action removes wildcard and invalid characters from `{name}`.
4. Sets permissions with `chmod -R a+rwX {log_dir}`.

## When to use

Use this action after a test step. Add `if: always()` to the step.
Then the action collects logs when the test fails or stops.

Example:

```yaml
- name: Run tests
  uses: magf/actions/tests/regression@collect-logs/v1
  with:
    image: ${{ env.IMAGE }}
    optimizer: ${{ matrix.optimizer }}
    target_os: ${{ inputs.target_os }}

- name: Collect logs
  if: always()
  uses: magf/actions/collect-logs@collect-logs/v1
  with:
    log_path_prefix: "regression_ggdb${{ inputs.version }}_${{ inputs.target_os }}${{ inputs.target_os_version }}_${{ matrix.optimizer }}"

- name: Upload artifacts
  if: always()
  uses: actions/upload-artifact@v7
  with:
    name: logs-${{ matrix.optimizer }}
    path: /mnt/logs
```

## Design

The action is a separate step. It is not part of the test step.
If the test step fails, the log collection step still runs.
The container stays available for log extraction.
This procedure prevents loss of diagnostic logs.
