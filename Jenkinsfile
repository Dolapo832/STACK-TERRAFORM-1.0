pipeline {
    agent any
    environment {
        PATH = "${PATH}:${getTerraformPath()}"
    }
    stages{
         stage('terraform init'){
             steps {
                 sh "terraform init"
        }
         }
         stage('terraform force-unlock 9ad38819-3e15-fd5a-23fe-e10c433a86d4'){
             steps {
                 sh "terraform force-unlock 9ad38819-3e15-fd5a-23fe-e10c433a86d4"
         }
         }
    }
}
def getTerraformPath(){
        def tfHome= tool name: 'terraform-40', type: 'terraform'
        return tfHome
    }