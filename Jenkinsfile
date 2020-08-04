#!/usr/bin/env groovy

def releaseNumber = "${env.RELEASE_NUMBER}"

stage('Checkout') {
  node {
    deleteDir()

    checkout scm

    currentBuild.displayName = "#${env.BUILD_NUMBER}:${releaseNumber}"
  }
}

stage('Build') {
  node {
    sh 'make'
  }
}
