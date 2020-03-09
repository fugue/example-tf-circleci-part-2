#!/bin/sh

# Check these Terraform project directories.
PROJECTS=(
  "project"
  "project/remote_state"
  "project/staging"
)

# Hide the output of a command only if it succeeds.
function silently {
  local log="$(mktemp -t silently.XXXXXXX)"
  local exit_code=""
  1>&2 echo "${1+$@}"
  ${1+"$@"} >"$log" 2>&1 || exit_code=$?
  if [[ ! -z $exit_code ]]; then
    1>&2 echo "${1+$@} failed; output ($log):"
    1>&2 cat "$log"
    exit $exit_code
  fi
  rm "$log"
}

# Generate JSON plan for each Terraform project.
for i in ${PROJECTS[@]}; do
  echo "Checking $i"
  pushd ~/$i > /dev/null 2>&1

  # Move backend file out of the way temporarily.
  if [ -f backend.tf ]; then mv backend.tf backend.tf.backup; fi

  # Use project directory name in output filename.
  REGULA_OUTPUT=${PWD##*/}

  # Generate JSON plan.
  silently terraform init -input=false -backend=false
  silently terraform plan -input=false -refresh=false -out=plan.tfplan
  terraform show -json plan.tfplan > ~/project/regula-plan-$REGULA_OUTPUT.json

  # Move backend file back.
  if [ -f backend.tf.backup ]; then mv backend.tf.backup backend.tf; fi
  popd > /dev/null 2>&1
done

# Run conftest on all JSON plans.
cd ~/project
conftest test regula-plan-*.json