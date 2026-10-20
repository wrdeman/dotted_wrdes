# Terraform + 1Password workflow (`tfp` / `tfa`)

Generic replacement for a per-project `login.sh` + `Makefile` combo (AWS SSO
login across a set of accounts, then `terraform plan`/`apply`). All the
project-specific bits — which AWS accounts to log into, which TF_VAR_*
secrets to export — live in a 1Password vault, so adding a new project is
"create a vault with the right items", not "write a new script".

Functions live in `.aliases`: `tfp`, `tfa`, and the private helper
`_tf_1p_secrets`.

## Prerequisites

On the machine, already outside install.sh's remit (install manually, or ask
to have them added if you want them managed there too):

- `op` — 1Password CLI, signed in (`op account list` to check)
- `aws` — AWS CLI v2, with SSO configured
- `terraform`
- `jq` (already installed by `install.sh`)
- `terraform-visual` (npm, optional) — if missing, `tfp` skips the HTML plan
  visualization and just leaves `plan.json`

## Vault schema

Each project points at one 1Password vault (the `<vault>` argument to `tfp`
/ `tfa`). The vault needs two kinds of item:

### 1. `AWS_ACCOUNTS` — one item, one field per environment

A single item titled `AWS_ACCOUNTS`, with one custom text field per
environment name (`dev`, `staging`, `PROD`, or whatever you call them). Each
field's value is a space-separated list of `account_id` or
`account_id:profile_name`:

```
dev:     111111111111 222222222222:MyCustomProfile 333333333333
staging: 444444444444 555555555555 333333333333
PROD:    666666666666 777777777777 333333333333
```

If `:profile_name` is omitted, `tfp` defaults to
`AWSAdministratorAccess-<account_id>` (matches a common SSO permission-set
naming convention). `tfp <vault> <env>` runs `aws sso login` once per
account in that field.

Create/update it with the CLI, e.g.:

```sh
op item create --category "Secure Note" --vault myproject --title AWS_ACCOUNTS \
  "dev[text]=111111111111 222222222222 333333333333" \
  "staging[text]=444444444444 555555555555 333333333333" \
  "PROD[text]=666666666666 777777777777 333333333333"
```

(`op item edit AWS_ACCOUNTS --vault <vault> "dev[text]=..."` to update a
field later.)

### 2. `TF_VAR_*` items — one per terraform secret

For every secret the terraform run needs (Cloudflare API token, etc.),
create an item whose **title is the exact env var name** terraform expects
(e.g. `TF_VAR_cloudflare_api_token`), with the secret in the default
password/`credential` field:

```sh
op item create --category Password --vault myproject \
  --title TF_VAR_cloudflare_api_token \
  password="..."
```

`tfp`/`tfa` list every item in the vault whose title starts with `TF_VAR_`
and `export` each one (reading `op://<vault>/<title>/credential`). No
per-project code needed — just add an item and it's picked up.

## Usage

From inside the terraform project directory:

```sh
tfp myproject dev      # SSO login to dev's accounts, export TF_VAR_*, plan + visualize
tfp myproject          # skip login (e.g. already logged in), export TF_VAR_*, plan + visualize
tfa myproject          # re-export TF_VAR_*, apply plan.out (prompts to confirm)
```

`tfp` sets `TF_WORKSPACE` to `<env>` when an env is given, writes
`plan.out` + `plan.json`, and opens `terraform-visual-report/index.html` if
`terraform-visual` is installed. `tfa` requires `plan.out` to exist (i.e.
run `tfp` first) and types `yes` to confirm before applying.

## Setting up a new project

1. Pick or create a 1Password vault for the project.
2. Add an `AWS_ACCOUNTS` item (see above) if the project spans multiple AWS
   accounts — skip it if `tfp <vault>` (no env) is enough.
3. Add a `TF_VAR_<name>` item for every secret the terraform config
   references via `variable "<name>"` / `TF_VAR_<name>`.
4. `cd` into the project's terraform directory and run `tfp <vault> <env>`.

Migrating an existing project that already does AWS SSO login + terraform
plan/apply via a `login.sh` + `Makefile` combo: copy the account IDs from
the login script's env-list lines into `AWS_ACCOUNTS` fields, and add a
`TF_VAR_<name>` item next to any existing secret item (same value) so `tfp`
picks it up — then the `make tf-*` targets and this can run side by side
until you're ready to drop the Makefile.
