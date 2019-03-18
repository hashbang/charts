#!/bin/bash

minikube_version="0.30.0"
declare -A minikube_hashes=(
	["linux"]="f6fcd916adbdabc84fceb4ff3cadd58586f0ef6e576233b1bd03ead1f8f04afa"
	["darwin"]="e09789c4eb751969f712947a43effd79cf73488163563e79d98bc3d15d06831e"
)
kubectl_version="1.12.2"
declare -A kubectl_hashes=(
	["linux"]="40807b5817e5a6a64a96eb219963a48f79ae96e1ee9a7f20ae9fbab2fc048ac7"
	["darwin"]="72792bf322d9b3e7648670f430d2eeee2db8f42900733d60094b0943533bbb19"
)
helm_version="2.11.0"
declare -A helm_hashes=(
	["linux"]="02a4751586d6a80f6848b58e7f6bd6c973ffffadc52b4c06652db7def02773a1"
	["darwin"]="551b13a398749ae3e0a5c54d3078f6e3bee552c5d6a0bf6f338cab64ce38ab0f"
)

[[ "$OSTYPE" =~ "linux" ]] && os=linux
[[ "$OSTYPE" =~ "darwin" ]] && os=darwin

[ -z $os ] && echo "$OSTYPE" is not supported && exit

function sha256() { openssl sha256 "$@" | awk '{print $2}'; }

minikube_host="https://github.com/kubernetes/minikube/releases/download"
minikube_path="v${minikube_version}/minikube-${os}-amd64"
minikube_url="${minikube_host}/${minikube_path}"
minikube_file="minikube-${os}-amd64-${minikube_version}"

kubectl_host="https://storage.googleapis.com/kubernetes-release/release"
kubectl_path="v${kubectl_version}/bin/${os}/amd64/kubectl"
kubectl_url="${kubectl_host}/${kubectl_path}"
kubectl_file="kubectl-${os}-amd64-${kubectl_version}"

helm_host="https://storage.googleapis.com/kubernetes-helm"
helm_path="helm-v${helm_version}-${os}-amd64.tar.gz"
helm_url="${helm_host}/${helm_path}"
helm_file="helm-${os}-amd64-${helm_version}"
tiller_file="tiller-${os}-amd64-${helm_version}"
helm_archive="${helm_file}.tar.gz"
helm_archive_path="${os}-amd64"

dir=$(dirname "${BASH_SOURCE[0]}")
temp_dir="${dir}/../.tmp"
download_dir="${temp_dir}/downloads"
release_dir="${temp_dir}/releases"
bin_dir="${temp_dir}/bin"
mkdir -p "${download_dir}" "${release_dir}" "${bin_dir}"

if [ ! -f "${release_dir}/${minikube_file}" ]; then
	wget "$minikube_url" -O "${download_dir}/${minikube_file}"
	minikube_hash="$(sha256 "${download_dir}/${minikube_file}")"
	[[ "${minikube_hashes[${os}]}" == "$minikube_hash" ]] || \
		{ ( >&2 echo "Invalid hash for ${minikube_file}"); exit 1; }
	mv "${download_dir}/${minikube_file}" "${release_dir}/${minikube_file}"
	ln -s "$PWD/${release_dir}/${minikube_file}" "${bin_dir}/minikube"
	chmod +x "${bin_dir}/minikube"
fi

if [ ! -f "${release_dir}/${kubectl_file}" ]; then
	wget "$kubectl_url" -O "${download_dir}/${kubectl_file}"
	kubectl_hash="$(sha256 "${download_dir}/${kubectl_file}")"
	[[ "${kubectl_hashes[${os}]}" == "$kubectl_hash" ]] || \
		{ ( >&2 echo "Invalid hash for ${kubectl_file}"); exit 1; }
	mv "${download_dir}/${kubectl_file}" "${release_dir}/${kubectl_file}"
	ln -s "$PWD/${release_dir}/${kubectl_file}" "${bin_dir}/kubectl"
	chmod +x "${bin_dir}/kubectl"
fi

if [ ! -f "${release_dir}/${helm_file}" ]; then
	wget "$helm_url" -O "${download_dir}/${helm_archive}"
	helm_hash="$(sha256 "${download_dir}/${helm_archive}")"
	[[ "${helm_hashes[${os}]}" == "$helm_hash" ]] || \
		{ ( >&2 echo "Invalid hash for ${helm_archive}"); exit 1; }
	temp_dir=$(mktemp -d)
	tar xvf "${download_dir}/${helm_archive}" -C "${temp_dir}"
	mv "${temp_dir}/${helm_archive_path}/helm" "${release_dir}/${helm_file}"
	mv "${temp_dir}/${helm_archive_path}/tiller" "${release_dir}/${tiller_file}"
	ln -s "$PWD/${release_dir}/${helm_file}" "${bin_dir}/helm"
	ln -s "$PWD/${release_dir}/${tiller_file}" "${bin_dir}/tiller"
	chmod +x "${bin_dir}/helm"
	chmod +x "${bin_dir}/tiller"
fi

export PATH="$PWD/${bin_dir}:$PATH"
