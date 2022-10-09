package main

is_configmap {
	input.kind = "ConfigMap"
}

deny["missing data"] {
	is_configmap
	not input.data
}
