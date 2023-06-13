# Installation Scripts

The installation scripts are intended for WinCollect 10 only.

## Purpose of MassAgentUpdate.ps1

This powershell script can be used to change the agent configuration on multiple agents at a time.

## Parameters

The $computers parameter is used to specify a file that has a list of machines in a .txt file.

The $source parameter is used to specify the "update_" script you want to use to change on your agents.

The $destination parameter is used to specify where to drop the "update_" script to change the configuration for your agents.  The default location is used here, but if you installed your agent in a different location make sure this is changed accordingly.

## Purpose of SetClientCertThumbprint.ps1

This powershell script can be used to search the local machine's Windows certificate stores for a client certificate and store that certificate's thumbprint as an environment variable. This environment variable can be used in update scripts to update destinations to use the certificate.

## Parameters

The $hostname parameter is used to specify the hostname that the certificate was issued to. The default value for this is the name of the computer the script is running from.

## Author  Team WinCollect

## Copyright (c) 2021 IBM  
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
