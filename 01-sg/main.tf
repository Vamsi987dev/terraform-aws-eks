module "ingress_alb_sg" {
  source       = "git::https://github.com/Vamsi987dev/project-terraform-infrastructure.git//modules/sg?ref=main"
  vpc_id       = data.aws_ssm_parameter.vpc_id.value
  project_name = var.project_name
  environment  = var.environment
  sg_name = "ingress-alb-sg"
}
resource "aws_security_group_rule" "public_HTTPS_ingress_alb" {
    type = "ingress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = module.ingress_alb_sg.id
}
resource "aws_security_group_rule" "ingress_alb_worker_node" {
    type = "ingress"
    from_port = 30000
    to_port = 32767
    protocol = "tcp"
    source_security_group_id = module.ingress_alb_sg.id
    security_group_id = module.worker_node_sg.id    
}


module "eks_control_plane_sg" {
  source       = "git::https://github.com/Vamsi987dev/project-terraform-infrastructure.git//modules/sg?ref=main"
  vpc_id       = data.aws_ssm_parameter.vpc_id.value
  project_name = var.project_name
  environment  = var.environment
  sg_name = "eks-control-plane-sg"
}
resource "aws_security_group_rule" "eks_control_plane_worker_node" {
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    source_security_group_id = module.eks_control_plane_sg.id
    security_group_id = module.worker_node_sg.id    
}

module "worker_node_sg" {
  source       = "git::https://github.com/Vamsi987dev/project-terraform-infrastructure.git//modules/sg?ref=main"
  vpc_id       = data.aws_ssm_parameter.vpc_id.value
  project_name = var.project_name
  environment  = var.environment
  sg_name = "worker-node-sg"
}
resource "aws_security_group_rule" "worker_node_eks_control_plane" {
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    source_security_group_id = module.worker_node_sg.id
    security_group_id = module.eks_control_plane_sg.id    
}
resource "aws_security_group_rule" "vpc_worker_node" {
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["10.0.0.0/16"]
    security_group_id = module.worker_node_sg.id    
}

module "mysql_sg" {
  source       = "git::https://github.com/Vamsi987dev/project-terraform-infrastructure.git//modules/sg?ref=main"
  vpc_id       = data.aws_ssm_parameter.vpc_id.value
  project_name = var.project_name
  environment  = var.environment
  sg_name = "mysql-sg"
}

#Bastion:
module "bastion_sg" {
  source       = "git::https://github.com/Vamsi987dev/project-terraform-infrastructure.git//modules/sg?ref=main"
  vpc_id       = data.aws_ssm_parameter.vpc_id.value
  project_name = var.project_name
  environment  = var.environment
  sg_name = "bastion-sg"
}
resource "aws_security_group_rule" "bastion_to_worker_node" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    source_security_group_id = module.bastion_sg.id
    security_group_id = module.worker_node_sg.id
}
resource "aws_security_group_rule" "bastion_to_eks_control_plane" {
    type = "ingress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    source_security_group_id = module.bastion_sg.id
    security_group_id = module.eks_control_plane_sg.id
}
resource "aws_security_group_rule" "bastion_to_mysql" {
    type = "ingress"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    source_security_group_id = module.bastion_sg.id
    security_group_id = module.mysql_sg.id    
}

resource "aws_security_group_rule" "public_bastion" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = module.bastion_sg.id
}