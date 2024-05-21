locals {
  ec2_user_data_filepath = "scripts/ec2-init-script.sh"
  cw_agent_policy_filepath = "iam-policies/cw_agent_config.json"
  role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]
}