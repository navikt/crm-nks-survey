# crm-nks-survey

[![Build](https://github.com/navikt/XXXXXXXXXXXXX/workflows/%5BPUSH%5D%20Create%20Package/badge.svg)](https://github.com/navikt/XXXXXXXXXXXXX/actions?query=workflow%3Acreate)
[![MIT License](https://img.shields.io/apm/l/atomic-design-ui.svg?)](https://github.com/navikt/XXXXXXXXXXXXX/blob/master/LICENSE)

Dette repoet er opprettet for å ta i bruk Salesforce Survey funksjonaliteten for NKS.

### Avhengigheter

Dette repoet er avhengig av følgende pakker:

-   [crm-platform-base](https://github.com/navikt/crm-platform-base)
-   [crm-henvendelse-base](https://github.com/navikt/crm-henvendelse-base)

# Komme i gang

## Installation

1. Install [npm](https://nodejs.org/en/download/)
1. Install [Salesforce DX CLI](https://developer.salesforce.com/tools/sfdxcli)
    - Alternative: `npm install sfdx-cli --global`
1. Clone this repository ([GitHub Desktop](https://desktop.github.com) is recommended for non-developers)
1. Run `npm install` from the project root folder
1. Install [SSDX](https://github.com/navikt/ssdx)
    - **Non-developers may stop after this step**
1. Install [VS Code](https://code.visualstudio.com) (recommended)
    - Install [Salesforce Extension Pack](https://marketplace.visualstudio.com/items?itemName=salesforce.salesforcedx-vscode)
    - **Install recommended plugins!** A notification should appear when opening VS Code. It will prompt you to install recommended plugins.
1. Install [AdoptOpenJDK](https://adoptopenjdk.net) (only version 8 or 11)
1. Open VS Code settings and search for `salesforcedx-vscode-apex`
1. Under `Java Home`, add the following:
    - macOS: `/Library/Java/JavaVirtualMachines/adoptopenjdk-[VERSION_NUMBER].jdk/Contents/Home`
    - Windows: `C:\\Program Files\\AdoptOpenJDK\\jdk-[VERSION_NUMBER]-hotspot`

## Build

To build locally without using SSDX, do the following:

1. If you haven't authenticated a DX user to production / DevHub, run `sfdx auth:web:login -d -a production` and log in
    - Ask `#crm-platform-team` on Slack if you don't have a user
    - If you change from one repo to another, you can change the default DevHub username in `.sfdx/sfdx-config.json`, but you can also just run the command above
1. Create a scratch org, install dependencies and push metadata:

```bash
sfdx force:org:create -f ./config/project-scratch-def.json --setalias scratch_org --durationdays 1 --setdefaultusername
echo y | sfdx plugins:install sfpowerkit@2.0.1
keys="" && for p in $(sfdx force:package:list --json | jq '.result | .[].Name' -r); do keys+=$p":[PACKAGE KEY] "; done
sfdx sfpowerkit:package:dependencies:install -u scratch_org -r -a -w 60 -k ${keys}
sfdx force:source:push
sfdx force:org:open
```

# Henvendelser

Enten:
Spørsmål knyttet til koden eller prosjektet kan stilles som issues her på GitHub

Eller:
Spørsmål knyttet til koden eller prosjektet kan stilles til teamalias@nav.no

## For NAV-ansatte

Interne henvendelser kan sendes via Slack i kanalen `#crm-nks`.
