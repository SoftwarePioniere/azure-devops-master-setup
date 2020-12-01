# xxx-devops-master

# Vorbereitungen

* Azure Devops Organization erzeugen
* Azure Active Directory konfigurieren
* GitHub Repos anlegen
* Terraform Cloud konfigurieren

## Azure DevOps

Organization in Azure DevOps über die Webseite anlegen

```
Benutzer: xxx@xx.onmicrosoft.com
$org: https://dev.azure.com/xxx
```

Personal Access Token erzeugen mit Full Access

## Azure Active Directory

Service Principal im Azure Active Directory anlegen

```
$principalName = "xxx-devops-master"
```

Berechtigungen konfigurieren:

Permissions:
- Azure Active Directory Graph: 
  - Directory.Read.All

Grant Permissions!!

Azure Ad Rollen:
- User Administrator
- Application Administrator


Links:
- https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/guides/service_principal_configuration


## GitHub

Github
- devops-master repo anlegen


Links:
- https://www.terraform.io/docs/cloud/vcs/github.html


## Terraform Cloud

Terraform 
- Konto und Organization anlegen
- Team Token beziehen

- github vcs connection einrichten
- azure devops vcs_connection einrichten

- den master workspace einrichten per cli
- die variablen speichern per cli
