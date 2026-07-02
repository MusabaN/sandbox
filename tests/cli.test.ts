import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const repoRoot = join(import.meta.dir, "..");

describe("sandbox --version", () => {
  let binPath: string;
  let workDir: string;

  beforeAll(async () => {
    workDir = mkdtempSync(join(tmpdir(), "sandbox-cli-test-"));
    binPath = join(workDir, "sandbox");

    const result = await Bun.build({
      entrypoints: [join(repoRoot, "src/cli.ts")],
      compile: { outfile: binPath },
    });

    if (!result.success) {
      throw new AggregateError(result.logs, "failed to compile sandbox binary");
    }
  });

  afterAll(() => {
    rmSync(workDir, { recursive: true, force: true });
  });

  test("prints a version string and exits 0", () => {
    const proc = Bun.spawnSync({
      cmd: [binPath, "--version"],
      stdout: "pipe",
      stderr: "pipe",
    });

    expect(proc.exitCode).toBe(0);
    expect(proc.stdout.toString().trim()).toMatch(/^sandbox \d+\.\d+\.\d+$/);
  });
});
