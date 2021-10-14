module "slocko-app" {
  source = "./modules/slocko-app"
  vpc = "vpc-024ac7fda7df61b45"
  name = "AlexSMartins"
  subnet_cidr = "10.0.102.0/24"
  tags = {
    Env = "Prod"
    Project = "Slacko"
    Customer = "Alex_LTDA"
    }
  Key_name = "slacko-app-key"
  public_key = "ssh-rsa xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}