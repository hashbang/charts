# #! Infrastructure

This repo is WIP, but aims to be the new home for all of the needed tooling
and configuration to deploy or maintain hashbang infrastructure.

This is intended to superseed the "admin-tools" repo to a get us to immutable
infrastructure-as-code using terraform to provision resources and helm/k8s to
manage services.

It is also a goal of this effort to be able to deploy any part of the #!
infrastructure locally so anyone can participate in helping maintain/improve
our systems with or without access to the production cluster.

## Requirements

  * x86_64 Linux or macOS workstaton with 2GB+ of memory

## Setup

1. Clone repo

```
git clone git@github.com/hashbang/infra
```

3. Source our toolchain

```
source scripts/tools.sh
```

## Testing ##

1. Start Minikube Ingress and Helm

    ```
    minikube start
    minikube addons enable ingress
    helm init
    ```

2. Install Helm dependencies

    ```
    helm dependency update
    ```

3. Install Helm chart for a #! Service you want to test

    ```
    helm install helm/hashbang.sh
    ```
