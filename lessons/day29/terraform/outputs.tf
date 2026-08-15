output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_region" {
  description = "AWS region"
  value       = var.region
}

output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}

output "argocd_server_url" {
  description = "ArgoCD Server LoadBalancer URL (run command to get)"
  value       = "kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
}

output "argocd_admin_password_command" {
  description = "Command to get ArgoCD admin password"
  value       = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
}

output "application_url_command" {
  description = "Command to get application frontend URL"
  value       = "kubectl get svc frontend -n 3tirewebapp-dev -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
}

output "demo_instructions" {
  description = "Instructions for demo"
  value       = <<-EOT
    ========================================
    🎉 GitOps Demo Environment Ready!
    ========================================
    
    1. Configure kubectl:
       aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}
    
    2. ArgoCD UI:
       Get URL with: kubectl get svc argocd-server -n argocd
       Username: admin
       Password: Run this command:
         kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
    
    3. Application Frontend:
       Wait 2-3 minutes for ArgoCD to sync, then run:
         kubectl get svc frontend -n 3tirewebapp-dev
       
    4. Check ArgoCD Application Status:
       kubectl get applications -n argocd
    
    ========================================
  EOT
}
