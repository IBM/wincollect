
![Example EPS rate report for several Windows hosts](reportsample.png?raw=true "Screenshot")

ABOUT
=====

The Get Event Log Report script allows administrators to chart the EPS rate of a local or remote Windows host based by polling the Event Log. The PowerShell script must be run as an administrator and is capable of creating EPS rate reports for local, remote, or all Windows hosts within the domain where the script is run.  


REQUIREMENTS
===========
 - PowerShell v3.0 or v4.0 is required. For more information on PowerShell or downloads, see the following website: <https://technet.microsoft.com/en-us/scriptcenter/dd742419.aspx>
 - PowerShell must be run as local admin & users must run **Set-ExecutionPolicy RemoteSigned** to use this script. 
 - To use option 3 for domain scans, Powershell domain cmdlets must be installed.
  - This script can be run on any Windows host at Windows XP or above. 
  - For Windows 2003 Server and Windows XP, remote EPS data collection uses WMI to remotely read the Windows Event Log. If there are network firewalls between Windows hosts, then standard WMI ports might need to be opened to prevent connection error messages. 


DETAILED DESCRIPTION
===========

This Powershell script includes three options for data collection:
 - **Local Host**: Scan the event log(s) of the local host to create a report of the Events Per Second (EPS) rate.
 - **IP List**:  Scan a list of IP addresses provided by the user. The remote systems are scanned and a report is created for each IP address.
 - **Domain**:  Scan the local domain where the script is run to create an EPS rate report for all of the Windows hosts within the domain. Powershell domain cmdlets must be installed to use this option.

Instructions
===========
1. Download the Powershell script.
2. Copy the script to a Windows host.
3. Launch Microsoft Powershell as an administrator.
4. Type **Set-ExecutionPolicy RemoteSigned**.
5. If prompted to update the policy, select **Yes**. 
   - For more information on Set-ExecutionPolicy, see <https://technet.microsoft.com/en-us/library/ee176961.aspx>
4. Open GetEventLogReports.ps1 in Powershell.
5. Run the GetEventLogReports.ps1 script.
6. Select one of the following options: 
   - **Local Host**
   -- Creates a CSV file of EPS rate data for the local host.
   - **IP List**
   -- Creates a CSV report for the list of IP addresses specified.
   - **Domain** 
   -- The script must be run within the Domain specified. 
7. Follow the on-screen prompts to create the EPS report.
8. Select a location to save the report data.
9. A summary details an success or error messages and the location of the report.



Version information
===========
 - Version: 1.0
 - Authors: Jamie Wheaton & William Delong


LICENSE
===========
Copyright (c) 2015 IBM

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
See the License for the specific language governing permissions and limitations under the License.


