output "ecr_repos_outputs" {
  value = {
    for repo_name, repo in module.ecr_repos : repo_name => {
      repository_arn = repo.repository_arn
      repository_url = repo.repository_url
    }
  }
}