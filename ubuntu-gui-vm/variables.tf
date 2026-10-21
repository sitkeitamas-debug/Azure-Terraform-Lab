variable "regions" {
  type        = list(string)
  description = "Elsődleges és tartalék régiók, ha az elsőben kapacitáshiány lenne."
  default     = ["francecentral", "germanywestcentral", "northeurope", "westeurope"]
}

variable "my_ip" {
  type        = string
  description = "A te nyilvános IP-címed /32-es formátumban."
}