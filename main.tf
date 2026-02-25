provider "aws" {
  region = "us-east-1" # Puedes cambiarla si prefieres otra región
}

variable "github_token" {
  description = "Token personal de GitHub"
  type        = string
  sensitive   = true
}

resource "aws_amplify_app" "vite_app" {
  name       = "VRomo"
  repository = "https://github.com/ByRovicYT/VRomo.git"
  # Aquí pasamos el token para que AWS pueda conectarse a GitHub
  access_token = var.github_token

  # Especificaciones de construcción para un proyecto Vite (Node.js)
  build_spec = <<-EOT
    version: 1
    frontend:
      phases:
        preBuild:
          commands:
            - npm install
        build:
          commands:
            - npm run build
      artifacts:
        baseDirectory: dist
        files:
          - '**/*'
      cache:
        paths:
          - node_modules/**/*
  EOT
}

# Conectamos la rama 'main' de tu repositorio
resource "aws_amplify_branch" "main" {
  app_id            = aws_amplify_app.vite_app.id
  branch_name       = "main"
  enable_auto_build = true
}

# Esto imprimirá la URL de tu aplicación web al terminar
output "amplify_app_url" {
  value = "https://${aws_amplify_branch.main.branch_name}.${aws_amplify_app.vite_app.default_domain}"
}