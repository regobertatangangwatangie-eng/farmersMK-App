// ── farmersMK Jenkins Seed Job ────────────────────────────────────────────────
// Run this once in Jenkins via: Manage Jenkins → Script Console, or as a
// freestyle "seed job" that executes this file via the Job DSL plugin.
//
// What it creates:
//   1. A Multibranch Pipeline "farmersmk-pipeline" pointing at your GitHub repo
//   2. A "farmersmk-seed" freestyle job that re-runs this script on demand
// ─────────────────────────────────────────────────────────────────────────────

// ── 1. Multibranch Pipeline ───────────────────────────────────────────────────
multibranchPipelineJob('farmersmk-pipeline') {
    displayName('farmersMK CI/CD Pipeline')
    description('Builds, tests, and deploys all farmersMK microservices')

    branchSources {
        github {
            id('farmersmk-github-source')
            // CHANGE: set your GitHub org/user and repo name
            repoOwner(System.getenv('GITHUB_OWNER') ?: 'YOUR_GITHUB_USERNAME')
            repository(System.getenv('GITHUB_REPO') ?: 'farmersMK-App')
            // Credential ID must match what you add in Jenkins credentials store
            // (GitHub personal access token with repo + admin:repo_hook scope)
            credentialsId('GITHUB_TOKEN')
            traits {
                gitHubBranchDiscovery {
                    strategyId(1) // 1 = exclude forks
                }
                gitHubPullRequestDiscovery {
                    strategyId(1)
                }
                gitHubForkPullRequestDiscovery {
                    strategyId(1)
                    trust { gitHubTrustPermissions() }
                }
                cloneOptionTrait {
                    extension {
                        shallow(true)
                        noTags(false)
                        depth(1)
                        reference('')
                        timeout(10)
                    }
                }
            }
        }
    }

    factory {
        workflowBranchProjectFactory {
            // Path to Jenkinsfile inside the repo
            scriptPath('ci-cd/jenkins/Jenkinsfile')
        }
    }

    orphanedItemStrategy {
        discardOldItems {
            numToKeep(5)
        }
    }

    triggers {
        // Re-scan every 5 minutes (webhook is the primary trigger — this is a fallback)
        periodicFolderTrigger {
            interval('5m')
        }
    }
}

// ── 2. Seed job (re-runs this DSL) ───────────────────────────────────────────
freeStyleJob('farmersmk-seed') {
    displayName('farmersMK Seed Job')
    description('Regenerates all farmersMK Jenkins jobs from seed-job.groovy')
    steps {
        jobDsl {
            targets('ci-cd/jenkins/seed-job.groovy')
            removedJobAction('IGNORE')
            removedViewAction('IGNORE')
            lookupStrategy('SEED_JOB')
        }
    }
    scm {
        git {
            remote {
                url("https://github.com/${System.getenv('GITHUB_OWNER') ?: 'YOUR_GITHUB_USERNAME'}/farmersMK-App.git")
                credentials('GITHUB_TOKEN')
            }
            branch('*/master')
        }
    }
}

println '✅  farmersMK Jenkins jobs created/updated successfully.'
