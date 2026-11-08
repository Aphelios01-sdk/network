"""Validate public issue routing contracts: uv run --with pyyaml python -m unittest discover -s tests."""

from pathlib import Path
import unittest

import yaml


FORMS = Path(__file__).resolve().parents[1] / ".github" / "ISSUE_TEMPLATE"


class IssueFormTests(unittest.TestCase):
    def form(self, name):
        with (FORMS / name).open() as stream:
            return yaml.safe_load(stream)

    def options(self, form, field):
        return next(item["attributes"]["options"] for item in form["body"] if item.get("id") == field)

    def test_sdk_and_node_forms_cover_networks_and_roles(self):
        for name in ("sdk-cli.yml", "node-bug.yml", "access.yml"):
            form = self.form(name)
            self.assertIn("status:triage", form["labels"])
            self.assertEqual(self.options(form, "network"), ["devnet", "testnet"])
        self.assertEqual(self.options(self.form("sdk-cli.yml"), "component"), ["TypeScript SDK", "Python SDK", "CLI"])
        requests = self.options(self.form("access.yml"), "request")
        self.assertIn("devnet miner sponsorship (automatic sponsorship full)", requests)
        self.assertIn("validator access", requests)
        self.assertIn("operator key quota (several miners)", requests)

    def test_all_form_labels_exist(self):
        with (FORMS.parent / "labels.yml").open() as stream:
            labels = {label["name"] for label in yaml.safe_load(stream)}
        for path in FORMS.glob("*.yml"):
            if path.name != "config.yml":
                self.assertTrue(set(self.form(path.name)["labels"]) <= labels, path.name)
