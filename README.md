#Example of Code Delivery via AWS CodeDeploy


##Terraform

[codedeploy_deployment_group](https://www.terraform.io/docs/providers/aws/r/codedeploy_deployment_group.html)

##CodeDeploy

###Deploy revision

In the AWS CodeDeploy console of your application chose deployment group which you need and in actions list chose "Deploy new revision"

###Triggers

You can use triggers for notification via SNS

###For private github repos

Use "Reconnect to GitHub" on "Create New Deployment" page and you have to add in github repo settings (Webhooks & services) a service "AWS CodeDeploy"

###Deploy previous revision

If you need to deploy previous revision (for example during instance bootstrap) when you have previous successful deployment you can use [custom ruby script](scripts/deploy_previous_revision.rb)

