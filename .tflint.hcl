config {
  plugin_dir = "~/.tflint.d/plugins"
}

plugin "aws" {
  enabled = true
  version = "0.27.0" # Check latest version on GitHub
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}