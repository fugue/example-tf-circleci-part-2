#!/bin/sh

# Check these Terraform project directories.
PROJECTS=(
  "project"
  "project/remote_state"
  "project/staging"
)

REGULA_RESULTS_PASS=""

# Generate JSON plan for each Terraform project.
for i in ${PROJECTS[@]}; do
  echo "Checking $i"
  pushd ~/$i > /dev/null 2>&1

  # Move backend file out of the way temporarily.
  if [ -f backend.tf ]; then mv backend.tf backend.tf.backup; fi
  
  # Run Regula on plan and generate JSON file
  /opt/regula/bin/regula . /opt/regula/lib /opt/regula/rules > regula-output-json.json

  # Set flag if any rule failed
  REGULA_PROJECT_RESULTS=$(jq -r '.result[].expressions[].value.summary.valid' regula-output-json.json)

  if [ "$REGULA_PROJECT_RESULTS" == "false" ]; then
    REGULA_RESULTS_PASS="false"
  fi

  # Parse JSON results and create human-friendly output
  echo "--- $i RESULTS ---:" >> ~/project/regula-output.txt
  jq -r '.result[].expressions[].value | "\(.message)"' regula-output-json.json >> ~/project/regula-output.txt
  printf "\n" >> ~/project/regula-output.txt

  # Move backend file back.
  if [ -f backend.tf.backup ]; then mv backend.tf.backup backend.tf; fi
  popd > /dev/null 2>&1
done

# Print output file
printf "\n"
cat ~/project/regula-output.txt

# Fail build if any Regula test failed
if [ "$REGULA_RESULTS_PASS" == "false" ]; then
  printf "\nRegula tests failed; compliance violation(s) detected. Build failed."
  exit 1

else
  printf "\nAll Regula tests passed!"
fi