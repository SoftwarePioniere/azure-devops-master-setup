# Software Pioniere Azure DevOps Master Setup

Wofür dieses Projekt? In diesem Projekt werden Tools zur Verwaltung des Azure DevOps Systems bereit gestellt.
Hier finden sich ebenfalls Templates, die in andere Projekten verwendet werden können.

Terraform kann Infrastruktur bereit stellen. Diese wird in einer eigenen Sprache deklarativ beschrieben. Der beschriebende Endzustand wird mittels Provider angewendet. Der Zustand des zu erzeugenden Systems wird in einer State Datei gespeichert. Dieser State kann z.B. im Azure Storage liegen und in verteilten Pipelines oder Workflows verwendet werden.

Es gibt einen Provider für Azure und Azure DevOps. Mittels Azure DevOps Provider kann die eigene Azure DevOps Umgebung konfiguriert und eingerichtet werden. So können z.B. die Projekte, Repositories, Pipelines, Service Connection, Security etc. as a code beschrieben werden.

Die Idee ist nun, dass in jeder Organisation wird ein DevOps Master Projekt angelegt wird. Darin werden dann alle DevOps Resourcen für die gesamte Organisation beschrieben und mit Terraform angelegt. 

Die angelegten Projekte stellen ebenfalls eigene Resourcen bereit. Vielleicht wird es auch eine Projekt Setup Pipeline geben....

Das Master Projekt an sich wird mit der Azure CLI erzeugt. Hier gab es ein Versuch, dieses teilweise mit Terraform anzulegen... 

Folgendes wird per Azure CLI erledigt:
* DevOps Master Projekt anlegen
* Azure Resourcen für Master Projekt anlegen:
    * Resource Group
    * Storage Account in Resource Group für den späteren Terraform State
    * Azure KeyVault in Resource Group zum speichern des PAT und der Service Principal Secrets 
* Speichern des AzureDevOps PAT im KeyVault
* Anlage der Service Principals im AzureAd und speichern der Infos im KeyVault
* Anlage der Service Connection im Master Projekt
* Anlage der Master Pipeline für das Root Setup 

Folgendes wird per Terraform erledigt
* Anlage der Service 


## Vorgehensweise

Zuerst wird eine neue Organisation im Azure DevOps angelegt.

Dann wird das Skript setup-master-project.ps1 ausgeführt. Hierzu einfach mit dem richtigen Account einloggen und die Variablen Werte verändern.

Jetzt das Git Repository des neuen Projekts auschecken.



# Vorbereitungen

Folgende Software muss installiert sein:

* Azure CLI mit DevOps extensions
* PowerShell Core
* Terraform

```powershell

choco install pwsh -y
choco install terraform -y
choco install azure-cli -y
az extension add --name azure-devops -y

choco upgrade pwsh -y
choco upgrade terraform -y
choco upgrade azure-cli -y
az extension update --name azure-devops

```

# Links

* https://www.terraform.io/docs/providers/azuredevops/index.html
* https://www.terraform.io/docs/providers/azurerm/guides/azure_cli.html
