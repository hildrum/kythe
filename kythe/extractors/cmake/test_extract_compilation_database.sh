#!/bin/bash -e

# Copyright 2014 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This script checks that extract_compilation_database.sh works on a simple
# compilation database.
BASE_DIR="$TEST_SRCDIR/kythe/extractors/cmake"
OUT_DIR="$TEST_TMPDIR"
EXTRACT="${BASE_DIR}/extract_compilation_database.sh"
EXPECTED_FILE_HASH="deac66ccb79f6d31c0fa7d358de48e083c15c02ff50ec1ebd4b64314b9e6e196"
KINDEX_TOOL="${TEST_SRCDIR}/kythe/cxx/tools/kindex_tool"
export KYTHE_EXTRACTOR="${TEST_SRCDIR}/kythe/cxx/extractor/cxx_extractor"
export JQ="${TEST_SRCDIR}/third_party/jq/jq"
cd "${BASE_DIR}/testdata"
KYTHE_CORPUS=test_corpus KYTHE_ROOT_DIRECTORY="${BASE_DIR}" \
    KYTHE_OUTPUT_DIRECTORY="${OUT_DIR}" \
    "${EXTRACT}" "${BASE_DIR}/testdata/compilation_database.json"
[[ $(ls -1 "${OUT_DIR}"/*.kindex | wc -l) -eq 1 ]]
INDEX_PATH=$(ls -1 "${OUT_DIR}"/*.kindex)
"${KINDEX_TOOL}" -canonicalize_hashes -suppress_details -explode \
    "${INDEX_PATH}"
sed "s|signature: \"cu.*\"|signature: \"\"|" "${INDEX_PATH}_UNIT" > \
    "${INDEX_PATH}_UNIT_NS"
sed "s:TEST_CWD:${PWD}/:
s:TEST_EXTRACTOR:${KYTHE_EXTRACTOR}:" "${BASE_DIR}/testdata/expected.unit" | \
    diff - "${INDEX_PATH}_UNIT_NS"
diff "${BASE_DIR}/testdata/expected.file" "${INDEX_PATH}_${EXPECTED_FILE_HASH}"
