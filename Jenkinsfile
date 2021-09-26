import com.emc.pipelines.artifactory.*

String releaseSlice
String versionSlicePath = 'version_slice.json'

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

        stage('Startup') {
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
            }
        }

        stage('Get version slice') {
            steps {
                script {
                    relVersion = sh(script: "grep -E 'appVersion:' objectscale-manager/Chart.yaml | cut -d ' ' -f2 |cut -d '.' -f1-2",
                                           returnStdout: true).trim()

                    print("Going with version ${relVersion}")

                    releaseSlice = common.getSliceForProductAcceptance(product: 'objectscale',
                                                                       releaseVersion: relVersion)
                }
            }
        }

        //
        // Note: all commands should be executed inside peakit container, but it is also required
        // to format output as separate stages.
        // Currently it is not clear how it is possible to execute stages inside peakit,
        // and pipeline does not allow common.withPeakitContainer above stage()
        // So unfortunately it is required to start each command with 'make dep' because
        // OS settings made by each 'make dep' are not saved between stages
        //
        // TODO think about how this can be improved
        //

        stage('Make test') {
            steps {
                script {
                    common.withPeakitContainer() {
                        sshagent([GH_CREDS]) {

                           sh('''
                                make dep
                                PATH=/tmp:$PATH
                                make charts-dep
                                make test
                           ''')
                        }
                    }
                }
            }
        }

        stage('Resolve versions') {
            steps {
                script {
                    common.withPeakitContainer() {
                        sshagent([GH_CREDS]) {

                           // adding file version slice
                           writeFile(file: versionSlicePath, text: releaseSlice)

                           sh('''
                                make dep
                                PATH=/tmp:$PATH
                                make decksver
                                make flexver
                                make resolve-versions
                           ''')
                        }
                    }
                }
            }
        }


        stage('Make build & package') {
            steps {
                script {
                    common.withPeakitContainer() {
                        sshagent([GH_CREDS]) {

                           sh('''
                                make dep
                                PATH=/tmp:$PATH
                                make build
                                make package
                           ''')
                        }
                    }
                }
            }
        }

        stage('Make package with service id') {
            steps {
                script {
                    common.withPeakitContainer() {
                        sshagent([GH_CREDS]) {

                           Random random = new Random()
                           String nonDefService = "svc" + random.nextInt(99999)

                           sh("""
                                make dep
                                PATH=/tmp:$PATH
                                make package SERVICE_ID=${nonDefService}
                           """)
                        }
                    }
                }
            }
        }

        stage('Generate events table') {
            steps {
                script {
                    common.withPeakitContainer() {
                        sshagent([GH_CREDS]) {

                           sh('''
                                make dep
                                PATH=/tmp:$PATH
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
