# Installation Scripts

The installation scripts are intended for WinCollect 10 only.

# Purpose of InstallWC10Agent.ps1

This powershell script can be used to install WinCollect 10 on a target endpoint from a remote share. The script will start a PSSession and then copy over the installation file to the temp directory of the target machine and then run the installer.  The installer will run the "Quick" install method that just captures the Security, Application and System event channels from the target machine and will then send them to the desire destination configured using the "WC_DEST" parameter

# Parameters

The $file parameter is used to specify the path to where the WinCollect 10 agent MSI file is located.
The $computerName parameter is used to specify the target endpoint where you want to install the agent.
The WC_DEST parameter is use to specify the QRadar appliance you want to send the events to.
The ADMIN_GROUP is required on systems that are not a domain controller.  This command line parameter must be specified with either a true or false value. A value of true adds the WinCollect virtual account to the Administrators group, whereas a value of false does not. This parameter can be omitted when WinCollect 10 is being installed on a domain controller.

## Author  Team WinCollect

## Copyright (c) 2023 IBM  
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
