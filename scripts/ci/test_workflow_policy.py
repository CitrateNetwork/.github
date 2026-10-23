#!/usr/bin/env python3
"""Policy pins for the org reusable workflows (stdlib only, no network).

Two halves:

* ``GuardrailNegativeControls`` proves ``workflow-guardrails.sh`` still catches
  each class it exists for. Each case copies the repo's workflow tree into a
  fresh temp dir, injects one bad pattern and asserts the guardrail exits
  non-zero naming the right check. Without these, a guardrail that silently
  stopped matching would keep reporting PASS.
* ``ReusableWorkflowPolicy`` pins the properties the guardrail does not look
  at: the blocking dependency audit in every language pipeline, the reusable
  secret scan, blocking behaviour when a requested script is missing, Slither
  on by default, SHA-pinned actions, Dependabot config location, the caller
  snippets and the public-surface install lines.

Run: ``python3 -m unittest discover -s scripts/ci -p 'test_*.py'``
"""

from __future__ import annotations

import re
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
WF = ROOT / ".github" / "workflows"
GUARD = ROOT / "scripts" / "ci" / "workflow-guardrails.sh"


def read(rel: str) -> str:
    return (ROOT / rel).read_text(encoding="utf-8")


def strip_comments(text: str) -> str:
    return "\n".join(l for l in text.splitlines() if not l.lstrip().startswith("#"))


def step_block(workflow: str, name_prefix: str) -> str:
    """Return the text of the first step whose `- name:` starts with name_prefix."""
    lines = strip_comments(workflow).splitlines()
    for i, line in enumerate(lines):
        m = re.match(r"^(\s*)- name:\s*(.+)$", line)
        if m and m.group(2).strip().startswith(name_prefix):
            indent = len(m.group(1))
            out = [line]
            for nxt in lines[i + 1 :]:
                if nxt.strip() and (len(nxt) - len(nxt.lstrip())) <= indent:
                    break
                out.append(nxt)
            return "\n".join(out)
    raise AssertionError(f"no step named {name_prefix!r}")


def input_default(workflow: str, name: str) -> str:
    lines = strip_comments(workflow).splitlines()
    for i, line in enumerate(lines):
        if re.match(rf"^\s{{6}}{re.escape(name)}:\s*$", line):
            for nxt in lines[i + 1 :]:
                if re.match(r"^\s{6}\S", nxt):
                    break
                m = re.match(r"^\s+default:\s*(.+?)\s*$", nxt)
                if m:
                    return m.group(1).strip("'\"")
    raise AssertionError(f"input {name!r} has no default")


class GuardrailNegativeControls(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = Path(tempfile.mkdtemp(prefix="wfpol-"))
        shutil.copytree(ROOT / ".github", self.tmp / ".github")

    def tearDown(self) -> None:
        shutil.rmtree(self.tmp)

    def run_guard(self) -> subprocess.CompletedProcess:
        return subprocess.run(
            ["bash", str(GUARD), str(self.tmp)], capture_output=True, text=True
        )

    def mutate(self, rel: str, old: str, new: str) -> None:
        p = self.tmp / rel
        t = p.read_text()
        self.assertIn(old, t, f"fixture anchor missing in {rel}")
        p.write_text(t.replace(old, new, 1))

    def assert_caught(self, check: str) -> None:
        r = self.run_guard()
        self.assertNotEqual(r.returncode, 0, r.stdout)
        self.assertIn(f"FAIL[{check}]", r.stdout)

    def test_clean_tree_passes(self) -> None:
        r = self.run_guard()
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)

    def test_c1_workflow_outside_dispatch_dir(self) -> None:
        (self.tmp / "workflows").mkdir()
        (self.tmp / "workflows" / "gate.yml").write_text(
            "name: gate\non:\n  push:\njobs: {}\n"
        )
        self.assert_caught("C1")

    def test_c2_continue_on_error(self) -> None:
        self.mutate(
            ".github/workflows/reusable-js-ci.yml",
            "      - name: Lint\n",
            "      - name: Lint\n        continue-on-error: true\n",
        )
        self.assert_caught("C2")

    def test_c2_exit_code_swallow(self) -> None:
        self.mutate(
            ".github/workflows/reusable-python-ci.yml",
            "            ruff check .\n",
            "            ruff check . || true\n",
        )
        self.assert_caught("C2")

    def test_c3_mutable_branch_action(self) -> None:
        self.mutate(
            ".github/workflows/reusable-rust-ci.yml",
            "dtolnay/rust-toolchain@6bed0761d98439e5a578e2877258200ad565ba87",
            "dtolnay/rust-toolchain@master",
        )
        self.assert_caught("C3")

    def test_c3_mutable_cross_repo_ref(self) -> None:
        p = self.tmp / ".github/workflows/reusable-canon-guardrail.yml"
        t = re.sub(r"ref: [0-9a-f]{40}", "ref: main", p.read_text(), count=1)
        p.write_text(t)
        self.assert_caught("C3")

    def test_c4_template_expansion_in_run(self) -> None:
        self.mutate(
            ".github/workflows/reusable-rust-ci.yml",
            "sudo apt-get install -y $APT_PACKAGES",
            "sudo apt-get install -y ${{ inputs.apt-packages }}",
        )
        self.assert_caught("C4")


class ReusableWorkflowPolicy(unittest.TestCase):
    def test_every_language_pipeline_has_a_blocking_dep_audit(self) -> None:
        cases = {
            "reusable-rust-ci.yml": ("cargo audit", r"cargo audit -D warnings"),
            "reusable-js-ci.yml": ("Dependency audit", r"npm audit --audit-level=high"),
            "reusable-python-ci.yml": ("Dependency audit", r"^\s*pip-audit\s*$"),
        }
        for wf, (step, cmd) in cases.items():
            with self.subTest(wf=wf):
                text = read(f".github/workflows/{wf}")
                self.assertEqual(input_default(text, "dep-audit"), "true")
                block = step_block(text, step)
                self.assertRegex(block, re.compile(cmd, re.M))
                self.assertNotIn("continue-on-error", block)

    def test_secret_scan_is_a_callable_blocking_workflow(self) -> None:
        text = strip_comments(read(".github/workflows/reusable-secret-scan.yml"))
        self.assertRegex(text, r"(?m)^on:\s*\n\s+workflow_call:")
        self.assertIn("sha256sum -c -", text)
        self.assertRegex(text, r"gitleaks detect --source \.")
        self.assertNotIn("continue-on-error", text)

    def test_missing_requested_js_script_fails_the_job(self) -> None:
        text = read(".github/workflows/reusable-js-ci.yml")
        for step in ("Lint", "Build", "Test"):
            with self.subTest(step=step):
                block = step_block(text, step)
                after_else = block.split("else", 1)[1]
                self.assertRegex(after_else, r"exit 1")
                self.assertNotIn("::warning::", block)

    def test_js_package_manager_is_allowlisted(self) -> None:
        block = step_block(read(".github/workflows/reusable-js-ci.yml"), "Detect lockfile")
        self.assertRegex(block, r"npm\|pnpm\|yarn\) ;;")
        self.assertRegex(block, r"\*\) .*exit 1")

    def test_slither_runs_by_default(self) -> None:
        text = read(".github/workflows/reusable-solidity-ci.yml")
        self.assertEqual(input_default(text, "run-slither"), "true")

    def test_every_remote_action_is_sha_pinned(self) -> None:
        bad = []
        for f in sorted(WF.glob("*.yml")):
            for n, line in enumerate(strip_comments(f.read_text()).splitlines(), 1):
                m = re.search(r"uses:\s*([^\s#]+)", line)
                if not m or m.group(1).startswith("./"):
                    continue
                if not re.search(r"@[0-9a-f]{40}$", m.group(1)):
                    bad.append(f"{f.name}:{n}: {m.group(1)}")
        self.assertEqual(bad, [])

    def test_dependabot_config_lives_where_dependabot_reads_it(self) -> None:
        self.assertTrue((ROOT / ".github/dependabot.yml").is_file())
        cfg = read(".github/dependabot.yml")
        self.assertRegex(cfg, r'package-ecosystem:\s*"github-actions"')
        # The root copy is a template only; its header must say GitHub does
        # NOT inherit it (the old header claimed org-wide inheritance).
        header = " ".join(read("dependabot.yml").splitlines()[:4]).lower()
        self.assertRegex(header, r"does not inherit")

    def test_documented_caller_snippets_pin_a_sha(self) -> None:
        for doc in ("README.md", "profile/README.md"):
            with self.subTest(doc=doc):
                for line in read(doc).splitlines():
                    m = re.search(r"uses:\s*\S+/reusable-[a-z-]+\.yml@(\S+)", line)
                    if m:
                        self.assertNotIn(m.group(1), ("main", "master"), line)

    def test_public_install_lines_constrain_protocol(self) -> None:
        for line in read("README.md").splitlines():
            if re.search(r"curl\b.*\|\s*(ba)?sh\b", line):
                self.assertIn("--proto '=https'", line)
                self.assertIn("--tlsv1.2", line)

    def test_security_policy_points_at_a_reachable_channel(self) -> None:
        text = read("SECURITY.md")
        self.assertNotIn("citrate-monorepo-archive", text)
        self.assertIn("private vulnerability reporting", text.lower())

    def test_repo_self_checks(self) -> None:
        self.assertTrue((ROOT / "AUDIT_TIER.md").is_file())
        ci = read(".github/workflows/ci.yml")
        for needle in ("workflow-guardrails.sh", "test-canon-guardrail.sh"):
            self.assertIn(needle, ci)

    def test_readme_lists_every_reusable_workflow(self) -> None:
        # Every reusable workflow must have its own row in the README table
        # (a mention in prose elsewhere does not count).
        rows = {
            m.group(1)
            for m in re.finditer(r"(?m)^\|\s*`(reusable-[a-z-]+\.yml)`\s*\|", read("README.md"))
        }
        for f in sorted(WF.glob("reusable-*.yml")):
            self.assertIn(f.name, rows, f.name)


if __name__ == "__main__":
    unittest.main()
