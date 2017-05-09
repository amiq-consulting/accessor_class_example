#!/bin/bash
#/******************************************************************************
# * (C) Copyright 2017 AMIQ Consulting
# * Licensed under the Apache License, Version 2.0 (the "License");
# * you may not use this file except in compliance with the License.
# * You may obtain a copy of the License at
# *
# * http://www.apache.org/licenses/LICENSE-2.0
# *
# * Unless required by applicable law or agreed to in writing, software
# * distributed under the License is distributed on an "AS IS" BASIS,
# * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# * See the License for the specific language governing permissions and
# * limitations under the License.
# *
# *
# *******************************************************************************/

# Go to the root directory of the project
cd $(cd `dirname $0` && pwd)/.. && export PROJECT_HOME=`pwd`

cd ./scripts/

# Remove the working directory and create a new one
rm -rf ./work && mkdir ./work && cd ./work

# Run the simulation
irun -f $PROJECT_HOME/scripts/irun.options -run -exit

cd ..

# Exit if successful
if [[ $? == 0 ]]; then
    exit 0
fi

# Exit and return error code if unsuccessful
printf "\n\nSIMULATION UNSUCCESSFUL\n\n\n"

exit $?

