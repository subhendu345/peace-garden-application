# peace-garden-application
Deployment and security configuration for a cloud-based application using AWS, Terraform, Kibana, Grafana, and cost optimisation strategies
# Peace Garden Application – Qatar 🌿

### 🌟 Overview
The Peace Garden Application is a cloud-based project deployed on **AWS** with a focus on **security**, **cost optimisation**, and **monitoring**. As part of the team, I contributed to the deployment and management of infrastructure.

---

### 🛠 Tech Stack
- **Cloud Platforms**: AWS (S3, EC2, CloudWatch)
- **IaC Tools**: Terraform
- **Monitoring Tools**: Kibana, Grafana
- **Security Tools**: Honeypot deployment, OpenVPN configuration

---

### 💡 Key Contributions
1. **Deployment**:
   - Implemented infrastructure as code using **Terraform**.
   - Deployed application components on **AWS**, ensuring scalability and fault tolerance.

2. **Cloud Security**:
   - Configured **Openvpn** for secure remote access.
   - Set up **honeypots** to monitor and detect potential threats.

3. **Monitoring**:
   - Integrated **Kibana** and **Grafana** dashboards for real-time log and performance monitoring.

4. **Cost Optimization**:
   - Conducted resource utilisation analysis to minimise cloud expenses.

---

### 📖 Documentation

peace-garden-app/
├── main.tf
├── variables.tf
├── outputs.tf
├── provider.tf
├── terraform.tfvars
│
├── modules/
│   ├── ec2/
│   ├── vpn/
│   ├── honeypot/
│   ├── dynamodb/
│   └── monitoring/
│
├── scripts/
│   ├── setup_openvpn.sh
│   ├── honeypot_deploy.sh
│   └── cloudwatch_agent.sh
│
├── docs/
│   ├── user_guide.md
│   ├── architecture.png
│   └── cost_optimization.md

docs/user_guide.md – Deployment Manual

Peace Garden Application – Cloud Deployment Manual 🚀
Purpose:
This guide helps you deploy and manage a secure, scalable Peace Garden Application using AWS, Terraform, and monitoring tools.

🔧 Prerequisites
Tool	Version
AWS CLI	v2+
Terraform	v1.5+
Git	v2+
SSH Key	Pre-generated
AWS Account	IAM User with Admin Access

📂 Module Highlights
✅ EC2 Module (modules/ec2)
Launches EC2 with auto-healing via ASG

Installs Apache and deploys a static frontend

✅ VPN Module (modules/vpn)
Sets up Openvpn using a shell script

Allows secure access to app servers

✅ Honeypot Module
Deploys a fake vulnerable service (e.g., port 2222)

Log suspicious IPS to CloudWatch

✅ Monitoring Module
Configures the CloudWatch agent

Sends logs to centralised dashboards

You can manually connect Grafana/Kibana to this log group

✅ Dynamodb Module

resource "aws_dynamodb_table" "peace_data" {
  name         = "peace-garden"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Env = "prod"
  }
}

Cost Optimization

| Feature         | Description                     |
| --------------- | ------------------------------- |
| OpenVPN         | Restrict SSH & dashboard access |
| Honeypots       | Detect brute-force attackers    |
| Security Groups | Locked to VPN IP only           |
| IAM Roles       | Fine-grained access             |

Turn off unused EC2 at night

Use auto-scaling with spot fallback

Monitor billing via CloudWatch alarm

Use Dynamodb PAY_PER_REQUEST mode
