module "ec2" {
  source            = "./modules/ec2"
  public_subnet_id  = module.network.public_subnet_ids[0]
  private_subnet_id = module.network.private_subnet_ids[0]
  ami_id            = "ami-0f88e80871fd81e91"
  instance_type     = "t3.micro"
  vpc_id            = module.network.vpc_id
}