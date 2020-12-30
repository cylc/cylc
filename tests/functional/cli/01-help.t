#!/usr/bin/env bash
# THIS FILE IS PART OF THE CYLC SUITE ENGINE.
# Copyright (C) NIWA & British Crown (Met Office) & Contributors.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#-------------------------------------------------------------------------------
# cylc help and basic invocation.

. "$(dirname "$0")/test_header"
# Number of tests depends on the number of 'cylc' commands.
set_test_number $(( 23 + $(find "${CYLC_REPO_DIR}/bin" -name 'cylc-*' | wc -l) ))

# Top help
run_ok "${TEST_NAME_BASE}-0" cylc
run_ok "${TEST_NAME_BASE}-help" cylc help
run_ok "${TEST_NAME_BASE}---help" cylc --help
for FILE in \
    "${TEST_NAME_BASE}-help.stdout" \
    "${TEST_NAME_BASE}---help.stdout"
do
    cmp_ok "${FILE}" "${TEST_NAME_BASE}-0.stdout"
done

# Sub-command - no match
run_fail "${TEST_NAME_BASE}-aardvark" cylc aardvark
cmp_ok "${TEST_NAME_BASE}-aardvark.stderr" <<'__STDERR__'
Error: cylc aardvark: unknown utility. Abort.
Type "cylc help all" for a list of utilities.
__STDERR__

# Sub-command - many matches
run_fail "${TEST_NAME_BASE}-get" cylc get
cmp_ok "${TEST_NAME_BASE}-get.stderr" <<'__STDERR__'
cylc get: is ambiguous for:
    cylc get-directory
    cylc get-site-config
    cylc get-suite-config
    cylc get-suite-contact
    cylc get-suite-version
__STDERR__

# Sub-command help
run_ok "${TEST_NAME_BASE}-validate--help" cylc validate --help
run_ok "${TEST_NAME_BASE}-validate-h" cylc validate -h
run_ok "${TEST_NAME_BASE}-help-validate" cylc help validate
run_ok "${TEST_NAME_BASE}-help-va" cylc help va
for FILE in \
    "${TEST_NAME_BASE}-validate-h.stdout" \
    "${TEST_NAME_BASE}-help-validate.stdout" \
    "${TEST_NAME_BASE}-help-va.stdout"
do
    cmp_ok "${FILE}" "${TEST_NAME_BASE}-validate--help.stdout"
done

# Version
run_ok "${TEST_NAME_BASE}-version" cylc version
run_ok "${TEST_NAME_BASE}---version" cylc --version
run_ok "${TEST_NAME_BASE}-V" cylc -V
run_ok "${TEST_NAME_BASE}-version.stdout" \
    test -n "${TEST_NAME_BASE}-version.stdout"
cmp_ok "${TEST_NAME_BASE}-version.stdout" "${TEST_NAME_BASE}---version.stdout"
cmp_ok "${TEST_NAME_BASE}-version.stdout" "${TEST_NAME_BASE}-V.stdout"

# Check "cylc version --long" output is correct.
cylc version --long > long1
WHICH="$(which cylc)"
PARENT1="$(dirname "${WHICH}")"
PARENT2="$(dirname "${PARENT1}")"
echo "$(cylc version) (${PARENT2})" > long2
# the concise version of the above is a shellcheck quoting nightmare:
# echo "$(cylc version) ($(dirname $(dirname $(which cylc))))" > long2
cmp_ok long1 long2

# --help with no DISPLAY
while read -r ITEM; do
    run_ok "${TEST_NAME_BASE}-no-display-${ITEM}--help" \
        env DISPLAY= cylc "${ITEM#cylc-}" --help
done < <(cd "${CYLC_REPO_DIR}/bin" && ls 'cylc-'*)

exit