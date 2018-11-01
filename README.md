# #! Infrastructure

This repo is WIP, but aims to be the new home for all of the needed tooling
and configuration to deploy or maintain hashbang infrastructure.

This is intended to supersede the "admin-tools" repo to a get us to immutable
infrastructure-as-code using terraform to provision resources and helm/k8s to
manage services.

It is also a goal of this effort to be able to deploy any part of the #!
infrastructure locally so anyone can participate in helping maintain/improve
our systems with or without access to the production cluster.

## Requirements

  * x86_64 Linux or macOS workstation
  * 2GB+ of memory
  * VT-x/AMD-v virtualization must be enabled in BIOS
  * Internet connection on first run
  * Linux
    * [VirtualBox](https://www.virtualbox.org/wiki/Downloads) or [KVM](https://github.com/kubernetes/minikube/blob/master/docs/drivers.md#kvm-driver)
    * **NOTE:** Minikube also supports a `--vm-driver=none` option that runs the Kubernetes components on the host and not in a VM. Docker is required to use this driver but no hypervisor. If you use `--vm-driver=none`, be sure to specify a [bridge network](https://docs.docker.com/network/bridge/#configure-the-default-bridge-network) for docker. Otherwise it might change between network restarts, causing loss of connectivity to your cluster.
  * macOS
    * [Hyperkit driver](https://github.com/kubernetes/minikube/blob/master/docs/drivers.md#hyperkit-driver), [xhyve driver](https://github.com/kubernetes/minikube/blob/master/docs/drivers.md#xhyve-driver), [VirtualBox](https://www.virtualbox.org/wiki/Downloads), or [VMware Fusion](https://www.vmware.com/products/fusion)

## Setup

1. Clone repo

    ```
    git clone git@github.com:hashbang/infra
    ```

2. Source our toolchain

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
    helm install -n site charts/site
    ```

4. Wait for pod to become healthy

    ```
    kubectl describe pods
    ```

5. Verify you can reach site via https using curl

    ```
    curl -H "Host: hashbang.sh" -k https://$(minikube ip)
    ```
