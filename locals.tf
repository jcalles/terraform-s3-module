locals {
  control_object_ownership = {
    for key, value in var.buckets :
    key => value.control_object_ownership
    if lookup(value, "control_object_ownership", false)
  }
}
