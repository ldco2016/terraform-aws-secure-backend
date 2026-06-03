# Terraform AWS Secure Backend (Healthcare-Oriented)

![Terraform](https://img.shields.io/badge/Terraform-IaC-623CE4?logo=terraform)
![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazon-aws)
![S3](https://img.shields.io/badge/S3-State%20Backend-569A31?logo=amazon-s3)
![DynamoDB](https://img.shields.io/badge/DynamoDB-State%20Locking-4053D6?logo=amazon-dynamodb)
![KMS](https://img.shields.io/badge/KMS-Encryption-yellow)

---

## Overview
This project implements a **Secure Terraform remote backend architecture on AWS**, designed with strong encryption, state integrity, and infrastructure safety printciples commonly used in regulated environments.
It demonstrates how to build a **production-style Terraform backend** using AWS-native security services.

---

## Architecture Diagram
```mermaid
flowchart LR

A[Terraform CLI / Developer ] --> |plan/apply| B[S3 Backend Bucket]

B --> C[KMS Customer Managed Key]

A --> D[DynamoDB State Lock Table]

B -->|Encrypted State Storage| E[(Terraform State File)]
D -->|Lock/Unlock State| E

C -->|Encrypt/Decrypt| B
