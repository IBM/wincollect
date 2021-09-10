# Installation Scripts

The installation scripts are intended for WinCollect 10 only.

## Purpose of MassAgentUpdate.ps1

This powershell script can be used to change the agent configuration on multiple agents at a time.

## Parameters

The $computers parameter is used to specify a file that has a list of machines in a .txt file.

The $source parameter is used to specify the "update_" script you want to use to change on your agents.

The $destination parameter is used to specify where to drop the "update_" script to change the configuration for your agents.  The default location is used here, but if you installed your agent in a different location make sure this is changed accordingly.

## Author  Team WinCollect

## Copyright (c) 2021 IBM  
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.