# Installation Scripts

The installation scripts are intended for WinCollect 10 only.

We have included serveral script examples to show how to use an XML formatted document (script) as part of a command-line install. The scripts cover all the different "sources" supported by WinCollect.  This replaces the paragraph install command of WinCollect 7 which only supported Windows Events.

## Installation cmd

The installation command will need the WC_SCRIPT parameter which includes the path to the installation script.

 

    msiexec.exe /q /i wincollect-10.x.x-xxx.x64.msi WC_SCRIPT="c:\wincollectinstall\update_<InstallScriptName>.xml"

> All scripts used as part of the WinCollect install must start with
> "update_" and be in XML format. Examples to follow.

  

## Installation Cmd Parameters


The WC_DEST parameter can be used with the install scripts to pass a QRadar hostname/IP into the install script. You can either use the WC_DEST parameter or you set the hostname/IP directly in the updated script

Example  
  

    msiexec.exe /q /i wincollect-10.x.x-xxx.x64.msi WC_DEST="<QRadar Hostname/IP>"  WC_SCRIPT="c:\wincollectinstall\update_<InstallScriptName>.xml"

## Author  Jamie Wheaton

## Copyright (c) 2020 IBM  
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.