#!/bin/bash
# THIS FILE IS PART OF THE CYLC SUITE ENGINE.
# Copyright (C) 2008-2015 NIWA
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
# Test that we don't get lots of redundant state dumps with queued tasks.
. $(dirname $0)/test_header
#-------------------------------------------------------------------------------
set_test_number 4
install_suite $TEST_NAME_BASE $TEST_NAME_BASE
#-------------------------------------------------------------------------------
TEST_NAME=$TEST_NAME_BASE-validate
run_ok $TEST_NAME cylc validate $SUITE_NAME
SUITE_DIR=$(cylc get-global-config --print-run-dir)/$SUITE_NAME
#-------------------------------------------------------------------------------
TEST_NAME=$TEST_NAME_BASE-run
suite_run_ok $TEST_NAME cylc run --reference-test --debug $SUITE_NAME
run_ok $TEST_NAME-n-dumps test $(find $SUITE_DIR/state -type f -name "state*" | wc -l) -eq 7
grep 'person' $SUITE_DIR/state/state >$TEST_NAME.state
cmp_ok $TEST_NAME.state <<'__STATE__'
person_a.1 : status=succeeded, spawned=true
person_b.1 : status=succeeded, spawned=true
__STATE__
#-------------------------------------------------------------------------------
purge_suite $SUITE_NAME
exit