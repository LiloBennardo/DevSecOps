package main

# Refuse un conteneur qui tourne en root (runAsNonRoot != true ou runAsUser == 0)

deny[msg] {
  input.kind == "Deployment"
  c := input.spec.template.spec.containers[_]
  not c.securityContext.runAsNonRoot
  msg := sprintf("Container '%s' doit definir securityContext.runAsNonRoot=true", [c.name])
}

deny[msg] {
  input.kind == "Deployment"
  c := input.spec.template.spec.containers[_]
  c.securityContext.runAsUser == 0
  msg := sprintf("Container '%s' ne doit pas tourner en UID 0 (root)", [c.name])
}

deny[msg] {
  input.kind == "Deployment"
  c := input.spec.template.spec.containers[_]
  c.securityContext.allowPrivilegeEscalation == true
  msg := sprintf("Container '%s' ne doit pas autoriser allowPrivilegeEscalation", [c.name])
}
