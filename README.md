# UI Application Deployment on EKS - CI/CD Pipeline

This project documents an end-to-end deployment of a user interface (UI) application leveraging modern DevOps tools and cloud-native technologies. The core infrastructure is built on AWS Elastic Kubernetes Service (EKS), integrated with a CI/CD pipeline powered by Jenkins.

---

## 🛠 Tools & Technologies Used

* **Terraform** – Infrastructure as Code for provisioning AWS resources (Jenkins, SonarQube, EKS, ECR, VPC).
* **Jenkins** – CI/CD server to automate build, test, and deployment pipelines.
* **SonarQube** – Static code analysis and code quality scanning.
* **Docker** – Containerization of application code.
* **AWS CLI** – Command-line interface for managing AWS resources.
* **Helm** – Package manager for Kubernetes to deploy and manage applications.
* **Amazon EKS** – Managed Kubernetes service for application deployment.
* **Amazon ECR** – Private container registry to store Docker images.
* **Maven** – Java-based build automation tool.

---

## 🧱 Project Architecture

* **Infrastructure Setup**:

  * Created Terraform scripts for provisioning:

    * Jenkins
    * SonarQube
    * Kubernetes (EKS cluster, node groups, VPC)
    * Elastic Container Registry (ECR)
  * Bootstrapped installation scripts for Jenkins and SonarQube.

* **Jenkins Configuration**:

  * The required tools: `Maven`, `Terraform`, `Docker`, `AWS CLI`, `Helm` were installed on the Jenkins sever.
  * Configured credentials: AWS access key, secret key, and AWS account ID.
  * Installed necessary plugins on the Jenkins UI: Docker, Kubernetes, SonarQube.
  * Integrated SonarQube into Jenkins using authentication tokens.
  * Created a webhook in SonarQube for Jenkins integration.

* **Source Control & Build Pipeline**:

  * Source code pushed to remote Git repository (e.g., GitHub or GitTurB).
  * Jenkinsfile created to define CI/CD stages:

    * Maven build and test
    * SonarQube code scanning
    * Docker image creation
    * Push image to AWS ECR
    * Helm-based deployment to EKS

* **Kubernetes Deployment**:

  * Jenkins uses AWS CLI to authenticate and update kubeconfig.
  * Helm is used to deploy the container image to EKS.
  * EKS is configured with a private and public VPC setup:

    * Control plane and worker nodes (node groups) reside in private subnets.
    * NAT Gateway handles internet-bound traffic.
    * LoadBalancer service (in public subnet) exposes the application publicly.

* **Domain & Security**:

  * Configured a custom domain name (e.g., `www.anikeamunidara.click`).
  * Integrated SSL certificate using AWS Certificate Manager and ALB listeners.
  * HTTP to HTTPS redirection configured.

---

## 🔐 Security Best Practices

* **Bastion Host**: The Jenkins server was also used as a bastion host as the the K8S control plane was cretaed withing the private subnet.
* **Shift-Left Security**: Code scanning via SonarQube occurs early in the pipeline.
* **Secrets Management**: Sensitive information such as credentials are excluded from version control.
* **HTTPS Encryption**: Application is served over HTTPS with SSL.

---

## 🚀 CI/CD Workflow Summary

1. Developer pushes code to Git.
2. Jenkins pipeline is triggered.
3. Code is built and tested using Maven.
4. SonarQube scans the codebase.
5. Docker image is built and pushed to AWS ECR.
6. Helm deploys the application to EKS.
7. Load balancer exposes the app via a secure HTTPS endpoint.

---

## 🌍 Environments

The architecture supports multiple deployment environments:

* **Development**
* **Testing**
* **Production**

Each environment can be provisioned using environment-specific Helm values and Terraform workspaces.

---

## ✅ Conclusion

This project demonstrates a scalable, secure, and automated CI/CD pipeline for deploying containerized UI applications to AWS using modern DevOps tools and cloud-native infrastructure. The setup ensures code quality, secure delivery, and high availability.
