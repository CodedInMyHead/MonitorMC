#!/bin/bash
#!/bin/bash -e

install_sap_certificates() {
  local os_cert_path="/usr/local/share/ca-certificates"

  # install certs for OS-based clients like curl
  mkdir -p "${os_cert_path}/sap.com" "${os_cert_path}/verizon"
  wget -q --no-check-certificate --no-cache http://aia.pki.co.sap.com/aia/SAPNetCA_G2.crt              -O "${os_cert_path}/sap.com/SAPNetCA_G2.crt.download"
  wget -q --no-check-certificate --no-cache http://aia.pki.co.sap.com/aia/SAP%20Global%20Root%20CA.crt -O "${os_cert_path}/sap.com/SAP_Global_Root_CA.crt.download"
  wget -q --no-check-certificate --no-cache https://de.ssl-tools.net/certificates/f326e9f894088fb560a001aa2c0ea8b1c20e6c35.pem -O "${os_cert_path}/verizon/Verizon_Public_SureServer_CA_G14-SHA2.crt.download"

  # check if downloaded files exist and are non-empty
  if [ ! -s "${os_cert_path}/sap.com/SAPNetCA_G2.crt.download" ] || \
     [ ! -s "${os_cert_path}/sap.com/SAP_Global_Root_CA.crt.download" ] || \
     [ ! -s "${os_cert_path}/verizon/Verizon_Public_SureServer_CA_G14-SHA2.crt.download" ]
  then
    error "Downloaded certificates in ${os_cert_path} are empty or missing. Aborting."
    grep -q '172.18.4.23' /etc/resolv.conf || error "Check DNS settings in /etc/resolv.conf. SAP DNS 172.18.4.23 not found."
    return 1
  fi

  mv "${os_cert_path}/sap.com/SAPNetCA_G2.crt.download" "${os_cert_path}/sap.com/SAPNetCA_G2.crt"
  mv "${os_cert_path}/sap.com/SAP_Global_Root_CA.crt.download" "${os_cert_path}/sap.com/SAP_Global_Root_CA.crt"
  mv "${os_cert_path}/verizon/Verizon_Public_SureServer_CA_G14-SHA2.crt.download" "${os_cert_path}/verizon/Verizon_Public_SureServer_CA_G14-SHA2.crt"
  update-ca-certificates

  return 0
}

# Install additional software
apt-get -y update -qq
apt-get -y install tree wget git

# Install docker & compose
sudo apt-get -y update
sudo apt-get -y install \
  ca-certificates \
  curl \
  gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get -y update
VERSION_STRING=5:20.10.13~3-0~ubuntu-jammy
sudo apt-get -y install docker-ce=$VERSION_STRING docker-ce-cli=$VERSION_STRING containerd.io docker-buildx-plugin docker-compose-plugin

# Download and install sap certs
install_sap_certificates

set -ex

cd  "$(realpath $(dirname "$0"))/.."

docker compose up -d