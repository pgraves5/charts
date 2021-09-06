import com.emc.pipelines.artifactory.*

pipeline {
    agent {
            label 'sc_ci_devkit && location_us'
        }

    environment {
        PWD = pwd()
        GH_CREDS = ''
    }

    options {
        timeout(time: 60, unit: 'MINUTES')
    }

    stages {
        stage('Make') {
            steps {
                script {
                    loader.loadFrom('pipelines': [common: 'common',
                                                  github: 'github',
                                                  git_operations: 'infra/git_operations',],)
                    GH_CREDS = common.PUBLIC_GITHUB_RW_CRED_ID;
                    github.postStatus('ssh://git@github.com:22/EMCECS/charts.git',
                                         "$GIT_COMMIT",
                                         [state: github.COMMIT_BUILD_STATUSES.IN_PROGRESS])
                    success = false
                }

                script {
                    common.withPeakitContainer() {
                        sshagent([GH_CREDS]) {

                           sh('''
                                make dep
                                PATH=/tmp:$PATH
                                make charts-dep
                                make test
                                make build
                                make package
                                make generate-issues-events-all
                           ''')
                        }
                    }
                }
            }
        }
        stage('Publish') {
            steps {
                script {
                    loader.loadFrom('pipelines': [
                        artifactory : 'infra/artifactory',
                        common: 'common',
                        ])

                    success = true
                }
            }
        }
    }

    post {
        always {
            deleteDir()
            script {
                status = success ? github.COMMIT_BUILD_STATUSES.SUCCESSFUL : github.COMMIT_BUILD_STATUSES.FAILED;
                github.postStatus('ssh://git@github.com:22/EMCECS/charts.git', "$GIT_COMMIT", [
                    state: status,
                    description: status,
                ])
            }
        }
    }
}
