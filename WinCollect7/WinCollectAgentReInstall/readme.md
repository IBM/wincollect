# ReinstallWinCollect.ps1

**NOTE:**
The ReinstallWinCollect.ps1 PowerShell utility is no longer needed with the release of 7.3.0 Patch 1 (7.3.0-41).
Uninstalling the Agent and then installing a fresh copy is not longer necessary.  The new installer will upgrade your Agent in place.  You can perform an upgrade one of two ways

**GUI Installation**
When you run the executable the UI will prompt if you would like to "Perform and upgrade of WinCollect", when you click "Yes", the agent will be upgraded in place.

**Cmd Line Installation**
Run the following cmd, which will upgrade the Agent.
**wincollect-7.3.0-41.x64.exe /S /v/qn**




## Author
Jamie Wheaton


## Copyright (c) 2020 IBM

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.