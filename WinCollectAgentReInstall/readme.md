# ReinstallWinCollect.ps1

The ReInstallWinCollect.ps1 PowerShell utility is intended to assist administrators with upgrades to Wincollect V7.3.0 on Windows hosts. The attached utility automates the install process to copy existing installation values and reinstall agents using the WinCollect V7.3.0 EXE for administrators who have large deployments of WinCollect agents.  

## Notices
* The ReinstallWinCollect.ps1 PowerShell utility is provided as-is to assist administrators to upgrade managed or stand-alone WinCollect agents.
* Administrators are encouraged to review and validate the contents of the attached PowerShell utility to ensure it does not contain harmful code and conforms to your corporate security policies.

## Before you begin
* For Managed agents:
  * Administrators must copy the existing WinCollect authorized service token from Admin > Authorized Services before you use the ReinstallWinCollect.ps1 utility.
    **Note:** The authorized service token cannot be expired and is assigned the User Role 'WinCollect' in the user interface.
  * Administrators with QRadar Managed WinCollect agents must install the WinCollect 7.3.0 SFS file on their QRadar Console before you run ReinstallWinCollect.ps1.
   * For QRadar 7.4.x: [Download the WinCollect SFS](http://www.ibm.com/support/fixcentral/swg/quickorder?parent=IBM%20Security&product=ibm/Other+software/IBM+Security+QRadar+SIEM&release=7.4.0&platform=All&function=fixId&fixids=7.4.0-QRADAR-740_QRadar_wincollectupdate-7.3.0-24.sfs&includeSupersedes=0&source=fc)
   * For QRadar 7.3.x: [Download the WinCollect SFS](http://www.ibm.com/support/fixcentral/swg/quickorder?parent=IBM%2520Security&product=ibm/Other+software/IBM+Security+QRadar+SIEM&release=7.3.0&platform=All&function=fixId&fixids=7.3.0-QRADAR-730_QRadar_wincollectupdate-7.3.0-24.sfs&includeSupersedes=0&source=fc)
* PowerShell must be run as local admin with **Set-ExecutionPolicy RemoteSigned**.
* This script can be run on any Windows host installed with Windows Vista or later.
* The utility is intended to run from a system drive, such as C:\, D:\, or E:\. The utility locates WinCollect installations and updates all required files.
* Backups of the following files are created in the current system directory:
  * AgentConfig.xml and install_config.txt 


## Required files
1. ReinstallWinCollect.ps1
2. Download a WinCollect agent install file for your Windows hosts (Required access to IBM Fix Central):
   1. 64-bit installer: [QRADAR-AGENT-wincollect-7.3.0-24.x64.exe](https://www.ibm.com/support/fixcentral/swg/downloadFixes?parent=IBM%20Security&product=ibm/Other+software/IBM+Security+QRadar+Vulnerability+Manager&release=All&platform=All&function=fixId&fixids=7.3.0-QRADAR-AGENT-wincollect-7.3.0-24.x64.exe&includeRequisites=1&includeSupersedes=0&downloadMethod=http)
   2. 32-bit installer: [QRADAR-AGENT-wincollect-7.3.0-24.x86.exe](https://www.ibm.com/support/fixcentral/swg/downloadFixes?parent=IBM%20Security&product=ibm/Other+software/IBM+Security+QRadar+Vulnerability+Manager&release=All&platform=All&function=fixId&fixids=7.3.0-QRADAR-AGENT-wincollect-7.3.0-24.x86.exe&includeRequisites=1&includeSupersedes=0&downloadMethod=http)


## Installation

1. Copy the utility and the WinCollect agent installer to the system drive of your Windows host, such as C:\.
2. Launch Microsoft Powershell as an administrator.  
**Note**: If you are logged in as a local admin, type the following command to open PowerShell as an administrator: **start-process PowerShell -verb runas**
3. Type **Set-ExecutionPolicy RemoteSigned**.  
4. If prompted to update the policy, press **Y** to continue.  
![Options displayed when setting the execution policy in PowerShell](https://github.com/ibm-security-intelligence/wincollect/blob/master/WinCollectAgentReInstall/setpolicy.png)
For more information on Set-ExecutionPolicy, see [https:/go.microsoft.com/fwlink/?LinkID=135170](https:/go.microsoft.com/fwlink/?LinkID=135170).  
5. Run the **ReinstallWinCollect.ps1** utility.
 1. Managed:  .\ReInstallWinCollect.ps1 -Authtoken 0e32xxx-xxxx-xxx-xxxx-xxxxxxxx814b
 2. Stand Alone:  .\ReInstallWinCollect.ps1
**Note**: If you experience errors running the ReInstallWinCollect.ps1 file, you might need to review the Security field properties. Right-click on the file and select Properties. In the Security field check **Unblock** and click **Apply**, then run the ReInstallWinCollect file.
![Administrators might be required to unblock a downloaded file](https://github.com/ibm-security-intelligence/wincollect/blob/master/WinCollectAgentReInstall/unblockfile.png)
6. Wait for the upgrade to complete.

**Results**  
The WinCollect agent is updated to V7.3.0. Administrators can verify their version by reviewing the logs in C:\Program Files\IBM\WinCollect\logs\wincollect.log. 

## Author
Jamie Wheaton


## Copyright (c) 2020 IBM

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.