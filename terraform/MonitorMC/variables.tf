variable "concourse_allowlist" {
  type        = list(string)
  description = "set of CIDRs that are allowed to access the jumpbox"
  default     = ["14.142.206.80/28", "62.219.90.8/29", "23.63.99.32/28",
    "155.56.68.208/28", "169.145.89.192/26", "169.145.92.70/31",
    "169.145.92.72/30", "169.145.120.31/32", "169.145.120.32/31",
    "169.145.120.34/32", "193.16.224.0/28", "193.16.224.32/28",
    "193.57.20.13/32", "193.57.20.14/31", "194.56.233.0/24",
    "195.93.234.0/25", "202.80.51.232/29", "203.13.146.0/24",
    "203.193.11.16/29", "212.157.40.8/29", "213.69.154.72/29",
    "172.16.0.0/24", "35.242.222.72/32", "35.198.69.232/32",
    "116.236.68.16/28", "116.246.0.64/28", "116.246.0.163/32",
    "116.246.0.164/31", "116.246.0.166/32", "116.236.68.12/30",
    "58.33.44.192/28","180.168.214.36/30", "116.236.68.224/27",
    "116.246.0.160/28", "180.166.22.224/28", "180.168.214.64/29",
    "52.58.182.214/32", "35.242.233.46/32", "35.198.152.45/32",
    "35.246.242.60/32", "35.198.163.26/32", "35.198.109.138/32",
    "34.89.171.174/32", "35.198.187.150/32", "34.89.169.109/32"]
}

variable "ssh_user" {
    type = string
    description = "name of user for which terraform deploys an ssh key"
    default = "root"
}

variable "ssh_public_key_path" {
  type = string
  description = "path to public key file"
  default = "./../../ssh/id_rsa.pub"
}

variable "ssh_private_key_path" {
  type = string
  description = "path to private key file"
  default = "./../../ssh/id_rsa"
}

variable "public_ip" {
  type = string
  description = "public cidr ip"
  default = "35.198.78.103"
}

variable "server_target_dir" {
  description = "Path to concourse directory"
  default     = "/server-files"
}

variable "project_id" {
    type = string
    description = "id of the project"
    default = "sap-gcp-cfi-dev"
}

variable "hostname" {
    type = string
    description = "hostname in FQDN"
    default = "minecraftserver"
}

variable "concourse_users" {
  description = "List of initial concourse users that will be automatically created; if user has public key(s) in GitHub under the given name, the public key(s) will be fetched and provisioned; alternatively you can supply the full public key (only one) after the user name and this public key will then be provisioned; example with three users, the second providing a public key: d012345, d054321 ssh-rsa AA...5Q== John Doe, i999999"
  default     = "tomatenbrot69 CodedInMyHead"
}

variable "key_file_path" {
  description = "Path to key pair that will be uploaded/used to access the concourse (supply path to private key, but public key will be required as well by adding '.pub')"
  default     = "/concourse/ssh/id_rsa"
}

variable "target_dir" {
    default = "/server-files"
}

variable "zone" {
    default = "europe-west3"
}